// lib/features/group_chat/group_room_page.dart
import 'dart:async';
import 'dart:convert';

import 'package:blurr/features/group_chat/control_bar.dart';
import 'package:blurr/features/group_chat/group_room_done.dart';
import 'package:blurr/features/group_chat/mouth_state.dart';
import 'package:blurr/features/group_chat/participant_avatar.dart';
import 'package:blurr/features/group_chat/participant_row.dart';
import 'package:blurr/features/group_chat/session_info_card.dart';
import 'package:blurr/livekit/audio_room_controller.dart';
import 'package:blurr/net/group_api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:livekit_client/livekit_client.dart'; // 상단 import 필요

import 'face_tracker_service.dart'; // ⭐ 새 서비스 import

enum Reliability { reliable, fast } // fast = 비신뢰형(빠른 전송)

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
  // id <-> name
  final Map<String, String> _id2name = {};
  final Map<String, String> _name2id = {};

  // 피어별 실시간 표정 notifier
  final Map<String, ValueNotifier<FaceExpression>> _peerNoti = {};
  ValueNotifier<FaceExpression> _notiForPeer(String id) =>
    _peerNoti[id] ??= ValueNotifier<FaceExpression>(FaceExpression.neutral);
  Timer? _whoHeartbeat;
void _startWhoHeartbeat() {
  // 3초 동안 500ms 간격으로 6회 재공지 (패킷 도착 순서 경쟁 대비)
  _whoHeartbeat?.cancel();
  int count = 0;
  _whoHeartbeat = Timer.periodic(const Duration(milliseconds: 500), (t) {
    if (count++ >= 6) { t.cancel(); return; }
    _announceMe();
  });
}
void _hydrateMappingsFromRoom() {
  final room = _audio.room;
  if (room == null) return;

  // 1) 전체 참가자 배열 만들기
  final all = <Participant>[];

  // local 먼저
  final lp = room.localParticipant;
  if (lp != null) all.add(lp);

  // 2) 원격 참가자: 최신 SDK는 remoteParticipants 사용
  //    (예전 버전은 participants 였음)
  all.addAll(room.remoteParticipants.values); // ✅ 이 줄로 교체

  for (final p in all) {
    final id = p.identity;
    String? nameFromMeta;
    try {
      if (p.metadata != null && p.metadata!.isNotEmpty) {
        final md = json.decode(p.metadata!) as Map<String, dynamic>;
        nameFromMeta = (md['randomName'] as String?) ?? (md['name'] as String?);
      }
    } catch (_) {}
    final name = nameFromMeta ?? p.name;
    if (name != null && name.isNotEmpty) {
      _id2name[id] = name;
      _name2id[name] = id;
    }
  }
  if (mounted) setState(() {});
}


  // 내 identity (루프백 필터용)
  String? _selfIdentity;
    final Map<String, FaceExpression> _peerExpr = {};
  // State 안에: 좌표/에셋을 이름으로 매핑 (기존 값 그대로)
  ({double? top,double? left,double? right,double? bottom,String image,String turnImage}) _avatarPos(String name){
    switch(name){
      case '새싹': return (top: (turn=='새싹'?255.w:275.w), left:0, right:0, bottom:null,
        image:'assets/images/group/saessak.png', turnImage:'assets/images/group/saessak_turn.png');
      case '파도': return (top: (turn=='파도'?354.w:374.w), left:250.w, right:0, bottom:null,
        image:'assets/images/group/pado.png', turnImage:'assets/images/group/pado_turn.png');
      case '나비': return (top: (turn=='나비'?354.w:374.w), left:0, right:250.w, bottom:null,
        image:'assets/images/group/nabi.png', turnImage:'assets/images/group/nabi_turn.png');
      case '이슬': return (top: (turn=='이슬'?495.w:510.w), left:140.w, right:0, bottom:null,
        image:'assets/images/group/iseul.png', turnImage:'assets/images/group/iseul_turn.png');
      case '바람': return (top: (turn=='바람'?485.w:500.w), left:0, right:150.w, bottom:null,
        image:'assets/images/group/baram.png', turnImage:'assets/images/group/baram_turn.png');
      default:     return (top:null,left:null,right:null,bottom:null,
        image:'assets/images/group/nabi.png', turnImage:'assets/images/group/nabi_turn.png');
    }
  }
// 3) 그리기: 타인도 Builder로
// Widget _renderAvatar(String name){
//   final isSelf = (name == myName);
//   final pos = _avatarPos(name);

//   if (isSelf) {
//     return ValueListenableBuilder(
//       valueListenable: _tracker.expression,
//       builder: (_, exp, __) => ParticipantAvatar(
//         name: name, image: pos.image, turnImage: pos.turnImage, turn: turn,
//         top: pos.top, left: pos.left, right: pos.right, bottom: pos.bottom,
//         arOn: _tracker.arOn, isSelf: true,
//         mouthStateOverride: exp.mouth,
//         mouthOpenRatioOverride: exp.mouthOpenRatio,
//         leftEyeOpenOverride: exp.leftEyeOpen,
//         rightEyeOpenOverride: exp.rightEyeOpen,
//       ),
//     );
//   } else {
//     final id = _name2id[name];
//     if (id == null) {
//       // 아직 WHO 안 온 경우: 정적 표시
//       return ParticipantAvatar(
//         name: name, image: pos.image, turnImage: pos.turnImage, turn: turn,
//         top: pos.top, left: pos.left, right: pos.right, bottom: pos.bottom,
//       );
//     }
//     return ValueListenableBuilder<FaceExpression>(
//       valueListenable: _notiForPeer(id),
//       builder: (_, exp, __) => ParticipantAvatar(
//         name: name, image: pos.image, turnImage: pos.turnImage, turn: turn,
//         top: pos.top, left: pos.left, right: pos.right, bottom: pos.bottom,
//         isSelf: false, arOn: false, // 타인은 토글 무시
//         mouthStateOverride: exp.mouth,
//         mouthOpenRatioOverride: exp.mouthOpenRatio,
//         leftEyeOpenOverride: exp.leftEyeOpen,
//         rightEyeOpenOverride: exp.rightEyeOpen,
//       ),
//     );
//   }
// }
Widget _renderAvatar(String name){
  final isSelf = (name == myName);
  final pos = _avatarPos(name);

  if (isSelf) {
    return ValueListenableBuilder(
      valueListenable: _tracker.expression,
      builder: (_, exp, __) => ParticipantAvatar(
        name: name, image: pos.image, turnImage: pos.turnImage, turn: turn,
        top: pos.top, left: pos.left, right: pos.right, bottom: pos.bottom,
        arOn: _tracker.arOn, isSelf: true,
        // ✅ 내 뱃지 넘기기
        badge: _myBadge,
        mouthStateOverride: exp.mouth,
        mouthOpenRatioOverride: exp.mouthOpenRatio,
        leftEyeOpenOverride: exp.leftEyeOpen,
        rightEyeOpenOverride: exp.rightEyeOpen,
      ),
    );
  } else {
    final id = _name2id[name];
    final peerBadge = (id != null) ? _peerBadgeById[id] : null;

    if (id == null) {
      return ParticipantAvatar(
        name: name, image: pos.image, turnImage: pos.turnImage, turn: turn,
        top: pos.top, left: pos.left, right: pos.right, bottom: pos.bottom,
        // ✅ WHO 이전에도 혹시 표시할 게 있으면(보통 없음) 넘길 수 있음
        badge: peerBadge,
      );
    }
    return ValueListenableBuilder<FaceExpression>(
      valueListenable: _notiForPeer(id),
      builder: (_, exp, __) => ParticipantAvatar(
        name: name, image: pos.image, turnImage: pos.turnImage, turn: turn,
        top: pos.top, left: pos.left, right: pos.right, bottom: pos.bottom,
        isSelf: false, arOn: false,
        // ✅ 타인 뱃지 표시
        badge: _peerBadgeById[id],
        mouthStateOverride: exp.mouth,
        mouthOpenRatioOverride: exp.mouthOpenRatio,
        leftEyeOpenOverride: exp.leftEyeOpen,
        rightEyeOpenOverride: exp.rightEyeOpen,
      ),
    );
  }
}

Widget _renderPeerAvatar(String name, {
  required String image, required String turnImage,
  double? top, double? left, double? right, double? bottom,
}) {
  final id = _name2id[name];
  if (id == null) {
    // WHO 미수신 시 정적 표시
    return ParticipantAvatar(
      name: name, image: image, turnImage: turnImage, turn: turn,
      top: top, left: left, right: right, bottom: bottom,
    );
  }
  return ValueListenableBuilder<FaceExpression>(
    valueListenable: _notiForPeer(id),
    builder: (_, exp, __) => ParticipantAvatar(
      name: name, image: image, turnImage: turnImage, turn: turn,
      top: top, left: left, right: right, bottom: bottom,
      isSelf: false, arOn: false, // 타인은 내 토글과 무관
      mouthStateOverride: exp.mouth,
      mouthOpenRatioOverride: exp.mouthOpenRatio,
      leftEyeOpenOverride: exp.leftEyeOpen,
      rightEyeOpenOverride: exp.rightEyeOpen,
    ),
  );
}
  // 클래스 필드에 추가
  final Map<String, String?> _peerBadgeById = {}; // id -> badge(이모지)

  // 수신한 피어 표정 찾기 (id↔name 매핑은 onData(who)에서 채움)
  FaceExpression? _exprForName(String name){
    if(name==myName) return _tracker.expression.value; // 내 표정은 로컬 실시간
    final id = _name2id[name];
    if(id==null) return null;
    return _peerExpr[id];
  }
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
  DateTime _lastExprSent = DateTime.fromMillisecondsSinceEpoch(0);

  void _wireExpressionBroadcast() {
    _tracker.expression.addListener(() {
      final now = DateTime.now();
      if (now.difference(_lastExprSent).inMilliseconds < 80) return; // ~12.5fps
      _lastExprSent = now;

      final e = _tracker.expression.value;
      _sendJson({
        't': 'expr',
        'm': e.mouth.index,
        'r': e.mouthOpenRatio,
        'l': e.leftEyeOpen,
        'rr': e.rightEyeOpen,
      }, reliability: Reliability.fast); // 비신뢰형(저지연) 채널
    });
  }

  // === AR 서비스 ===
  final FaceTrackerService _tracker = FaceTrackerService();
  Widget _buildAvatar({
    required String name,
    required String image,
    required String turnImage,
    double? top, double? left, double? right, double? bottom,
  }) {
    final isTurn = (turn == name);
    final isSelf = (name == myName);
    final expr = _exprForName(name);

    return ParticipantAvatar(
      name: name,
      image: image,
      turnImage: turnImage,
      turn: turn,
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      badge: name == myName ? _myBadge : null,
      arOn: _tracker.arOn && isSelf,
      isSelf: isSelf,
      mouthStateOverride: expr?.mouth,
      mouthOpenRatioOverride: expr?.mouthOpenRatio,
      leftEyeOpenOverride: expr?.leftEyeOpen,
      rightEyeOpenOverride: expr?.rightEyeOpen,
    );
  }
@override
void initState() {
  super.initState();

  _audio.onData = ({
    required String fromIdentity,
    required Map<String, dynamic> payload,
    String? topic,
    bool reliable = true,
  }) {
    final type = payload['t'];
    switch (type) {
    case 'who': {
      final name = payload['name'] as String?;
      if (name != null && name.isNotEmpty) {
        _id2name[fromIdentity] = name;
        _name2id[name] = fromIdentity;

        // ✅ 매핑 변경 → 빌드 트리에서 해당 이름 아바타를
        //    정적 → ValueListenableBuilder 로 전환시키려면 반드시 리빌드 필요
        if (mounted) setState(() {});
      }
      break;
    }
    case 'badge': {
      final b = payload['value'] as String?;
      _peerBadgeById[fromIdentity] = (b != null && b.trim().isNotEmpty) ? b : null;
      if (mounted) setState(() {}); // 드물게 바뀌니 setState로 충분
      break;
    }

      case 'ar': {
        // 필요 시 상태 반영
        break;
      }

      case 'expr': {
        // 내가 보낸 패킷 루프백이면 무시
        if (_selfIdentity != null && fromIdentity == _selfIdentity) break;

        // 안전 파싱
        final mi = (payload['m'] as num?)?.toInt() ?? 0;
        final ri = (payload['r'] as num?)?.toDouble() ?? 0.0;
        final l  = payload['l'] == true;
        final rr = payload['rr'] == true;

        final mouth = (mi >= 0 && mi < MouthState.values.length)
            ? MouthState.values[mi] : MouthState.neutral;
        final ratio = ri.isFinite ? ri.clamp(0.0, 0.5) : 0.0;

        // ✅ setState() 대신, 해당 피어 notifier에 값만 넣음
        _notiForPeer(fromIdentity).value = FaceExpression(
          mouth: mouth,
          mouthOpenRatio: ratio,
          leftEyeOpen: l,
          rightEyeOpen: rr,
        );
        break;
      }

      default:
        debugPrint('[DATA] unknown payload: $payload');
    }
  };

  _initAr();
  _wireExpressionBroadcast(); // 내 표정 주기 송출(60~100ms)

  _connect();  // 아래 3 참고: 여기서 _selfIdentity 채우기
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
    _selfIdentity = _audio.room?.localParticipant?.identity;

    _hydrateMappingsFromRoom(); // ⭐ 바로 스냅샷으로 매핑 선점
    _startWhoHeartbeat();       // ⭐ 몇 초간 WHO 재공지
    _announceMe();              // 기존 1회 공지 그대로 유지


    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('입장 실패: $e')));
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _sendJson(
    Map<String, dynamic> m, {
    String topic = 'grp',
    Reliability reliability = Reliability.reliable,
  }) async {
    // AudioRoomController가 이미 room/마이크 상태 체크함
    final isReliable = (reliability == Reliability.reliable);
    await _audio.publishJson(
      m,
      topic: topic,
      reliable: isReliable,
    );
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
    if(myName.isEmpty) return;
    _sendJson({'t':'who','name':myName},reliability:Reliability.reliable);
  }



  Future<void> _initAr() async {
    await _tracker.init();
    // 초기값: 켜진 상태로 시작하고 싶다면
    await _tracker.start();
    setState(() {}); // arOn 반영
  }

  @override
  void dispose() {
    for(final n in _peerNoti.values){n.dispose();}
    _peerNoti.clear();
    _audio.onData = null;
    _tracker.stop();
    _tracker.dispose();
    _audio.disconnect();
    super.dispose();
  }

  Future<void> _toggleAr() async {
    await _tracker.toggle();
    setState(() {});
    _sendJson({'t':'ar','on':_tracker.arOn}, reliability:Reliability.reliable);
  }

  @override
  Widget build(BuildContext context) {
    final exprSaessak = _exprForName('새싹');
    final exprPado = _exprForName('파도');
    final exprIseul = _exprForName('이슬');
    final exprBaram = _exprForName('바람');

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

          // // --- 참가자들 ---
          // ParticipantAvatar(
          //   name: '새싹',
          //   image: 'assets/images/group/saessak.png',
          //   turnImage: 'assets/images/group/saessak_turn.png',
          //   turn: turn,
          //   top: turn == '새싹' ? 255.w : 275.w,
          //   left: 0,
          //   right: 0,
          //   badge: '새싹' == myName? _myBadge: null,
          //   arOn : _tracker.arOn && ('새싹'==myName),
          //   isSelf: '새싹'==myName,
          // ),
          // ParticipantAvatar(
          //   name: '파도',
          //   image: 'assets/images/group/pado.png',
          //   turnImage: 'assets/images/group/pado_turn.png',
          //   turn: turn,
          //   top: turn == '파도' ? 354.w : 374.w,
          //   left: 250.w,
          //   right: 0,
          //   badge: '파도' == myName? _myBadge: null,
          //   arOn : _tracker.arOn && ('파도'==myName),
          //   isSelf: '파도'==myName,
          // ),

          // // ⭐ 내 아바타만 실시간 표정 덮어쓰기
          // ValueListenableBuilder(
          //   valueListenable: _tracker.expression,
          //   builder: (context, exp, _) {
          //     return ParticipantAvatar(
          //       name: '나비',
          //       image: 'assets/images/group/nabi.png',
          //       turnImage: 'assets/images/group/nabi_turn.png',
          //       turn: turn,
          //       top: turn == '나비' ? 354.w : 374.w,
          //       left: 0,
          //       right: 250.w,
          //       badge: '나비' == myName? _myBadge: null,
          //       arOn : _tracker.arOn && ('나비'==myName),
          //       isSelf: '나비'==myName,
          //       mouthStateOverride: exp.mouth,
          //       mouthOpenRatioOverride: exp.mouthOpenRatio,
          //       leftEyeOpenOverride: exp.leftEyeOpen,
          //       rightEyeOpenOverride: exp.rightEyeOpen,
          //     );
          //   },
          // ),

          // ParticipantAvatar(
          //   name: '이슬',
          //   image: 'assets/images/group/iseul.png',
          //   turnImage: 'assets/images/group/iseul_turn.png',
          //   turn: turn,
          //   top: turn == '이슬' ? 495.w : 510.w,
          //   left: 140.w,
          //   right: 0,
          //   badge: '이슬' == myName? _myBadge: null,
          //   arOn : _tracker.arOn && ('이슬'==myName),
          //   isSelf: '이슬'==myName,
          // ),
          // ParticipantAvatar(
          //   name: '바람',
          //   image: 'assets/images/group/baram.png',
          //   turnImage: 'assets/images/group/baram_turn.png',
          //   turn: turn,
          //   top: turn == '바람' ? 485.w : 500.w,
          //   left: 0,
          //   right: 150.w,
          //   badge: '바람' == myName? _myBadge: null,
          //   arOn : _tracker.arOn && ('바람'==myName),
          //   isSelf: '바람'==myName,
          // ),
          // --- 참가자들 ---
// --- 참가자들 ---

// // 1) 새싹 (피어 표현 반영)
// ParticipantAvatar(
//   name: '새싹',
//   image: 'assets/images/group/saessak.png',
//   turnImage: 'assets/images/group/saessak_turn.png',
//   turn: turn,
//   top: turn == '새싹' ? 255.w : 275.w,
//   left: 0,
//   right: 0,
//   badge: '새싹' == myName ? _myBadge : null,
//   arOn: _tracker.arOn && ('새싹' == myName),
//   isSelf: '새싹' == myName,
//   mouthStateOverride: exprSaessak?.mouth,
//   mouthOpenRatioOverride: exprSaessak?.mouthOpenRatio,
//   leftEyeOpenOverride: exprSaessak?.leftEyeOpen,
//   rightEyeOpenOverride: exprSaessak?.rightEyeOpen,
// ),

// // 2) 파도 (피어 표현 반영)
// ParticipantAvatar(
//   name: '파도',
//   image: 'assets/images/group/pado.png',
//   turnImage: 'assets/images/group/pado_turn.png',
//   turn: turn,
//   top: turn == '파도' ? 354.w : 374.w,
//   left: 250.w,
//   right: 0,
//   badge: '파도' == myName ? _myBadge : null,
//   arOn: _tracker.arOn && ('파도' == myName),
//   isSelf: '파도' == myName,
//   mouthStateOverride: exprPado?.mouth,
//   mouthOpenRatioOverride: exprPado?.mouthOpenRatio,
//   leftEyeOpenOverride: exprPado?.leftEyeOpen,
//   rightEyeOpenOverride: exprPado?.rightEyeOpen,
// ),

// // 3) 나비 = ✅ "내 아바타"만 실시간 리빌드 (ValueListenableBuilder)
// ValueListenableBuilder(
//   valueListenable: _tracker.expression,
//   builder: (context, exp, _) {
//     // 좌표/사이즈 절대 동일 유지 (이전 코드 그대로)
//     return ParticipantAvatar(
//       name: '나비',
//       image: 'assets/images/group/nabi.png',
//       turnImage: 'assets/images/group/nabi_turn.png',
//       turn: turn,
//       top: turn == '나비' ? 354.w : 374.w,
//       left: 0,
//       right: 250.w,
//       badge: '나비' == myName ? _myBadge : null,
//       arOn: _tracker.arOn && ('나비' == myName),
//       isSelf: '나비' == myName,
//       // 내 표정은 여기서 직접 주입 (리슨너가 매 프레임 리빌드)
//       mouthStateOverride: exp.mouth,
//       mouthOpenRatioOverride: exp.mouthOpenRatio,
//       leftEyeOpenOverride: exp.leftEyeOpen,
//       rightEyeOpenOverride: exp.rightEyeOpen,
//     );
//   },
// ),

// // 4) 이슬 (피어 표현 반영)
// ParticipantAvatar(
//   name: '이슬',
//   image: 'assets/images/group/iseul.png',
//   turnImage: 'assets/images/group/iseul_turn.png',
//   turn: turn,
//   top: turn == '이슬' ? 495.w : 510.w,
//   left: 140.w,
//   right: 0,
//   badge: '이슬' == myName ? _myBadge : null,
//   arOn: _tracker.arOn && ('이슬' == myName),
//   isSelf: '이슬' == myName,
//   mouthStateOverride: exprIseul?.mouth,
//   mouthOpenRatioOverride: exprIseul?.mouthOpenRatio,
//   leftEyeOpenOverride:exprIseul?.leftEyeOpen,
//   rightEyeOpenOverride: exprIseul?.rightEyeOpen,
// ),

// // 5) 바람 (피어 표현 반영)
// ParticipantAvatar(
//   name: '바람',
//   image: 'assets/images/group/baram.png',
//   turnImage: 'assets/images/group/baram_turn.png',
//   turn: turn,
//   top: turn == '바람' ? 485.w : 500.w,
//   left: 0,
//   right: 150.w,
//   badge: '바람' == myName ? _myBadge : null,
//   arOn: _tracker.arOn && ('바람' == myName),
//   isSelf: '바람' == myName,
//   mouthStateOverride: exprBaram?.mouth,
//   mouthOpenRatioOverride: exprBaram?.mouthOpenRatio,
//   leftEyeOpenOverride: exprBaram?.leftEyeOpen,
//   rightEyeOpenOverride: exprBaram?.rightEyeOpen,
// ),
        // --- 참가자들 (순서/좌표 동일 유지) ---
        _renderAvatar('새싹'),
        _renderAvatar('파도'),
        _renderAvatar('나비'),
        _renderAvatar('이슬'),
        _renderAvatar('바람'),

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

                  _sendJson({'t':'badge','value':e},reliability: Reliability.reliable);

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
