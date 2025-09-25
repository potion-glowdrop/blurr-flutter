// lib/features/group_chat/group_room_page.dart
import 'dart:convert';

import 'package:blurr/features/group_chat/control_bar.dart';
import 'package:blurr/features/group_chat/group_room_done.dart';
import 'package:blurr/features/group_chat/participant_avatar.dart';
import 'package:blurr/features/group_chat/participant_row.dart';
import 'package:blurr/features/group_chat/session_info_card.dart';
import 'package:blurr/livekit/audio_room_controller.dart';
import 'package:blurr/net/group_api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'face_tracker_service.dart'; // ⭐ 새 서비스 import

class GroupRoomPage extends StatefulWidget {
  final String topic;
  final bool myTurn; // 내 차례인지 여부
  final String turn;

  const GroupRoomPage({
    super.key,
    required this.topic,
    this.turn = "",
    this.myTurn = false,
  });

  @override
  State<GroupRoomPage> createState() => _GroupRoomPageState();
}

class _GroupRoomPageState extends State<GroupRoomPage> {
  // === 단순 상태 ===
  String turn = "새싹";
  String myName = "";
  String? _myBadge = '';
  final List<String> _emojis = const ['☀️','☁️','☔️','⚡️','🌪️','🌈','❄️'];
  final Map<String, List<String>> emojiSets = {
    '날씨': ['☀️','☁️','☔️','⚡️','🌪️','🌈','❄️'],
    '감정': ['😊','😢','😡','😱','😌','😐','😭'],
    '리액션': ['👍','👎','👏','💬','❓','😮','❤️'],
    '에너지': ['💪','😴','🥱','🤯','🔥','🌱','🚀'],
    '공감': ['🫂','🤝','🙌','💖','👂','😔','🫶'],
  };
  double _badgeOpacity = 1.0;
  final _audio = AudioRoomController();
  bool _connecting = true;
  static const String kRoomName = 'kim-sangdam';

  // === AR 서비스 ===
  final FaceTrackerService _tracker = FaceTrackerService();

  @override
  void initState() {
    super.initState();
    _initAr();
    _connect();
  }
  Future<void> _connect() async {
  setState(() => _connecting = true);
  try {
    final api = GroupApiClient('https://blurr.world');

    // 1) 같은 이름의 활성 방 최신순으로 뽑기
    final all = await api.listRooms();
    final candidates = all
        .where((e) => e['roomName'] == kRoomName && e['active'] == true)
        .toList()
      ..sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));

    Map<String, dynamic>? joinData;
    int? pickedId;

    // 2) 차례대로 tryJoin (정원 초과 ER002면 다음 후보로)
    for (final r in candidates) {
      final rid = (r['id'] as num).toInt();
      final res = await api.tryJoin(rid);
      if (res['ok'] == true) {
        joinData = res['data'] as Map<String, dynamic>;
        pickedId = rid;
        break;
      }
      if (res['code'] != 'ER002') {
        throw 'POST /rooms/$rid/join -> ${res['status']}: ${res['message']}';
      }
    }

    // 3) 전부 만석이면 새 방 생성 → 조인
    if (joinData == null) {
      final created = await api.addRoomFull(kRoomName, duration: 'MIN15', maxCap: 8);
      if (created['ok'] != true) {
        throw 'POST /rooms/add -> ${created['status']}: ${created['message']}';
      }
      pickedId = created['roomId'] as int;
      final res = await api.tryJoin(pickedId!);
      if (res['ok'] != true) {
        throw 'POST /rooms/$pickedId/join -> ${res['status']}: ${res['message']}';
      }
      joinData = res['data'] as Map<String, dynamic>;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기존 방이 만석이라 새 방을 열었습니다.')),
        );
      }
    }

    // 4) LiveKit connect (+ randomName UI 반영)
    // joinData 확보 후
    final wsUrl = '${joinData['wsUrl']}';
    final token = '${joinData['token']}';

    // 1순위: 응답 바디의 randomName
    String? rn = joinData['randomName'] as String?;
    // 2순위: JWT에서 randomName/name (혹시 바디에 없을 때 대비)
    rn ??= _extractNameFromJwt(token);

    // 여기서 즉시 반영!  (connect 전에)
    if (rn != null && mounted) {
      setState(() => myName = rn!);
    }

    // 그리고 나서 LiveKit 연결
    await _audio.connect(wsUrl: wsUrl, token: token);

        // 선택: 입장 직후 내 닉네임 브로드캐스트 (타인 표시명 동기화용)
        _announceMe();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('입장 실패: $e')));
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

// GroupRoomPageState
bool _leaving = false;

Future<void> _leaveRoomAndExit() async {
  if (_leaving) return;               // 중복 탭 방지
  setState(() => _leaving = true);

  try {
    // 1) LiveKit 끊기 (타임아웃 가드)
    await _audio.disconnect().timeout(const Duration(seconds: 3), onTimeout: () {});

    // 2) AR 멈추기 (이미 dispose에서도 하지만, 즉시 끊어주는 편이 깔끔)
    await _tracker.stop();
  } catch (_) {
    // 굳이 에러를 막 표출하진 않고, 로그만 남기고 진행해도 OK
  } finally {
    if (!mounted) return;
    // 3) 화면 전환
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const GroupDone(),
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }
}
String? _extractNameFromJwt(String jwt) {
  try {
    final parts = jwt.split('.');
    if (parts.length != 3) return null;
    final normalized = base64Url.normalize(parts[1]);
    final payload = json.decode(utf8.decode(base64Url.decode(normalized))) as Map<String, dynamic>;

    // 서버가 randomName를 주는 게 우선, 없으면 name fallback
    return (payload['randomName'] as String?) ?? (payload['name'] as String?);
  } catch (_) {
    return null;
  }
}



void _announceMe() {
  // 데이터채널로 {t:'who', name:'...'} 한번 보내는 로직을 여기에 (앞서 안내했던 방식)
}



  Future<void> _initAr() async {
    await _tracker.init();
    // 초기값: 켜진 상태로 시작하고 싶다면
    await _tracker.start();
    setState(() {}); // arOn 반영
  }

  @override
  void dispose() {
    _tracker.stop();
    _tracker.dispose();
    _audio.disconnect();
    super.dispose();
  }

  Future<void> _toggleAr() async {
    await _tracker.toggle();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if(_connecting){
      return const Scaffold(body: Center(child: CircularProgressIndicator(strokeWidth: 2,),),);
    }
    return Scaffold(
      body: Stack(
        children: [
          // 배경
          Positioned.fill(
            child: Image.asset(
              'assets/illustrations/one_on_one_bgd.png',
              fit: BoxFit.cover,
            ),
          ),

          // 상단 카드 + 참여자
          Positioned(
            top: 100.h,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  SessionInfoCard(
                    text:
                        '이번 세션의 당신의 닉네임은 ${myName.isEmpty?"...":myName}입니다. 그룹 대화 방에서는 음성과 표정으로 소통할 수 있습니다.',
                  ),
                  SizedBox(height: 11.h),
                  ParticipantsRow(
                    participants: const ['이슬', '나비', '바람', '새싹', '파도'],
                    activeName: turn,
                  ),
                ],
              ),
            ),
          ),

          // 원형 테이블/센터 피스
          Positioned(
            top: 300.h,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  SizedBox(
                    width: 258.w,
                    height: 258.w,
                    child: OverflowBox(
                      maxWidth: 310.w,
                      maxHeight: 310.w,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.w),
                        child: Image.asset(
                          'assets/images/group/round_table.png',
                          width: 310.w,
                          height: 310.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Image.asset(
                        'assets/images/group/glow.png',
                        width: 150.w,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: SizedBox(
                        width: 72.w,
                        height: 72.w,
                        child: OverflowBox(
                          maxWidth: 198.w,
                          maxHeight: 198.w,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.w),
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/images/group/center_piece.png',
                                  width: 198.w,
                                  height: 198.w,
                                ),
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Center(child: Text('15', style: TextStyle(fontFamily: 'IBMPlexSansKR', fontSize: 40.sp, fontWeight: FontWeight.w200, color: Color(0xFF17A1FA)), )))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
          ),

          // --- 참가자들 ---
          ParticipantAvatar(
            name: '새싹',
            image: 'assets/images/group/saessak.png',
            turnImage: 'assets/images/group/saessak_turn.png',
            turn: turn,
            top: turn == '새싹' ? 255.w : 275.w,
            left: 0,
            right: 0,
            badge: '새싹' == myName? _myBadge: null,
            arOn : _tracker.arOn && ('새싹'==myName),
            isSelf: '새싹'==myName,
          ),
          ParticipantAvatar(
            name: '파도',
            image: 'assets/images/group/pado.png',
            turnImage: 'assets/images/group/pado_turn.png',
            turn: turn,
            top: turn == '파도' ? 354.w : 374.w,
            left: 250.w,
            right: 0,
            badge: '파도' == myName? _myBadge: null,
            arOn : _tracker.arOn && ('파도'==myName),
            isSelf: '파도'==myName,
          ),

          // ⭐ 내 아바타만 실시간 표정 덮어쓰기
          ValueListenableBuilder(
            valueListenable: _tracker.expression,
            builder: (context, exp, _) {
              return ParticipantAvatar(
                name: '나비',
                image: 'assets/images/group/nabi.png',
                turnImage: 'assets/images/group/nabi_turn.png',
                turn: turn,
                top: turn == '나비' ? 354.w : 374.w,
                left: 0,
                right: 250.w,
                badge: '나비' == myName? _myBadge: null,
                arOn : _tracker.arOn && ('나비'==myName),
                isSelf: '나비'==myName,
                mouthStateOverride: exp.mouth,
                mouthOpenRatioOverride: exp.mouthOpenRatio,
                leftEyeOpenOverride: exp.leftEyeOpen,
                rightEyeOpenOverride: exp.rightEyeOpen,
              );
            },
          ),

          ParticipantAvatar(
            name: '이슬',
            image: 'assets/images/group/iseul.png',
            turnImage: 'assets/images/group/iseul_turn.png',
            turn: turn,
            top: turn == '이슬' ? 495.w : 510.w,
            left: 140.w,
            right: 0,
            badge: '이슬' == myName? _myBadge: null,
            arOn : _tracker.arOn && ('이슬'==myName),
            isSelf: '이슬'==myName,
          ),
          ParticipantAvatar(
            name: '바람',
            image: 'assets/images/group/baram.png',
            turnImage: 'assets/images/group/baram_turn.png',
            turn: turn,
            top: turn == '바람' ? 485.w : 500.w,
            left: 0,
            right: 150.w,
            badge: '바람' == myName? _myBadge: null,
            arOn : _tracker.arOn && ('바람'==myName),
            isSelf: '바람'==myName,
          ),

          // 하단 컨트롤 바
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: ControlBar(
                myTurn: turn == myName,
                arOn: _tracker.arOn,
                onToggleAr: _toggleAr,
                onPass: () {},        
                onProlong: () {},     
                onEnd: () {},
                emojis : emojiSets['감정']!,
                selectedEmoji: _myBadge,
                onEmojiSelected: (e) {
                  setState(() {
                    _myBadge = e;
                    _badgeOpacity = 1.0; // 처음엔 보여지도록
                  });

                  Future.delayed(const Duration(seconds: 4), () {
                    if (mounted && _myBadge == e) {
                      setState(() => _badgeOpacity = 0.0); // 서서히 사라지게
                    }
                  });

                  Future.delayed(const Duration(seconds: 5), () {
                    if (mounted && _myBadge == e) {
                      setState(() => _myBadge = null); // 완전히 제거
                    }
                  });
                }
                
              ),
            ),
          ),

          // 뒤로가기
          Positioned(
            left: 23.w,
            top: 53.h,
            child: GestureDetector(
              onTap:_leaveRoomAndExit,
              child: SizedBox(
                width: 44.w,
                height: 44.w,
                child: Image.asset(
                  'assets/images/icons/back_btn.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// AR on/off 토글 버튼 (이미지 스위치)
class _ArToggleButton extends StatelessWidget {
  final bool arOn;
  final VoidCallback onTap;

  const _ArToggleButton({
    required this.arOn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44.w,
      height: 44.w,
      child: OverflowBox(
        maxWidth: 104.w,
        maxHeight: 104.w,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.w),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Image.asset(
                  arOn
                      ? 'assets/images/icons/ar_filter_on.png'
                      : 'assets/images/icons/ar_filter_off.png',
                  key: ValueKey(arOn),
                  width: 104.w,
                  height: 104.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 단순 아이콘 버튼(이미지) 래퍼
class _IconButtonImage extends StatelessWidget {
  final String asset;

  const _IconButtonImage({required this.asset});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44.w,
      height: 44.w,
      child: OverflowBox(
        maxWidth: 104.w,
        maxHeight: 104.w,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.w),
          child: Image.asset(
            asset,
            width: 104.w,
            height: 104.w,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
