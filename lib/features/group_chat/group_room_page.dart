// lib/features/group_chat/group_room_page.dart
import 'package:blurr/features/group_chat/control_bar.dart';
import 'package:blurr/features/group_chat/group_room_done.dart';
import 'package:blurr/features/group_chat/mouth_state.dart';
import 'package:blurr/features/group_chat/participant_avatar.dart';
import 'package:blurr/features/group_chat/participant_row.dart';
import 'package:blurr/features/group_chat/session_info_card.dart';
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
    this.turn = "바람",
    this.myTurn = false,
  });

  @override
  State<GroupRoomPage> createState() => _GroupRoomPageState();
}

class _GroupRoomPageState extends State<GroupRoomPage> {
  // === 단순 상태 ===
  String turn = "새싹";
  final String myName = "나비";
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

  // === AR 서비스 ===
  final FaceTrackerService _tracker = FaceTrackerService();

  @override
  void initState() {
    super.initState();
    _initAr();
  }

  Future<void> _initAr() async {
    await _tracker.init();
    // 초기값: 켜진 상태로 시작하고 싶다면
    await _tracker.start();
    setState(() {}); // arOn 반영
  }

  @override
  void dispose() {
    _tracker.dispose();
    super.dispose();
  }

  Future<void> _toggleAr() async {
    await _tracker.toggle();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                  const SessionInfoCard(
                    text:
                        '이번 세션의 당신의 닉네임은 나비입니다. 그룹 대화 방에서는 음성과 표정으로 소통할 수 있습니다.',
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
              onTap:(){
                Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const GroupDone(),
                      transitionDuration: const Duration(milliseconds: 220),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 180),
                      transitionsBuilder: (_, a, __, child) =>
                          FadeTransition(opacity: a, child: child),
                    ),
                  );

              },
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
