
// import 'dart:convert';
// import 'package:livekit_client/livekit_client.dart' as lk;

// class AudioRoomController {
//   lk.Room? _room;
//   lk.Room? get room => _room;

//   // 🔧 여기: StreamSubscription 대신 취소 함수 & 리스너 보관
//   lk.EventsListener<lk.RoomEvent>? _listener;
//   lk.CancelListenFunc? _cancelListen;

//   Future<void> connect({required String wsUrl, required String token}) async {
//     await disconnect();
//     final room = lk.Room();
//     await room.connect(wsUrl, token);
//     await room.localParticipant?.setMicrophoneEnabled(true);
//     _room = room;

//     _startEventListener();
//   }

//   Future<void> disconnect() async {
//     // 🔧 등록해둔 리스너 해제
//     _cancelListen?.call();
//     _cancelListen = null;
//     await _listener?.dispose();
//     _listener = null;

//     await _room?.disconnect();
//     await _room?.dispose();
//     _room = null;
//   }

//   /// 2.2.0: reliable(bool) 사용
//   Future<void> publishJson(
//     Map<String, dynamic> m, {
//     String topic = 'grp',
//     bool reliable = true,
//     List<String>? toIdentities,
//   }) async {
//     final r = _room;
//     final lp = r?.localParticipant;
//     if (r == null || lp == null) return;

//     final bytes = utf8.encode(json.encode(m));
//     await lp.publishData(
//       bytes,
//       topic: topic,
//       reliable: reliable,
//       destinationIdentities: toIdentities,
//     );
//   }

//   /// 외부 콜백
//   void Function({
//     required String fromIdentity,
//     required Map<String, dynamic> payload,
//     String? topic,
//     bool reliable,
//   })? onData;

//   void _startEventListener() {
//     final r = _room;
//     if (r == null) return;

//     _listener = r.createListener();

//     // 🔧 listen() 이 반환하는 건 CancelListenFunc
//     _cancelListen = _listener!.listen((dynamic event) {
//       // 버전별 타입명이 달라질 수 있으니 동적 파싱
//       final typeName = event.runtimeType.toString();
//       if (!typeName.contains('Data') || !typeName.contains('Received')) return;

//       try {
//         final participant = (event as dynamic).participant;
//         final identity = (participant?.identity ?? '') as String;

//         final List<int> raw = (event as dynamic).data as List<int>;
//         final topic = (event as dynamic).topic as String?;
//         final bool rel = ((event as dynamic).reliable as bool?) ?? true;

//         final payload = json.decode(utf8.decode(raw)) as Map<String, dynamic>;
//         onData?.call(
//           fromIdentity: identity,
//           payload: payload,
//           topic: topic,
//           reliable: rel,
//         );
//       } catch (_) {
//         // 디코딩 실패 시 무시
//       }
//     });
//   }
// }
// audio_room_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // ✅ debugPrint
import 'package:livekit_client/livekit_client.dart' as lk;

class AudioRoomController {
  lk.Room? _room;
  lk.Room? get room => _room;

  lk.EventsListener<lk.RoomEvent>? _listener;
  lk.CancelListenFunc? _cancelListen;

  Future<void> connect({required String wsUrl, required String token}) async {
    await disconnect();
    // debugPrint('[AUDIO] connect() -> $wsUrl');
    final room = lk.Room();
    await room.connect(wsUrl, token);
    await room.localParticipant?.setMicrophoneEnabled(true);
    _room = room;

    // ✅ 현재 참가자 로그
    final lp = room.localParticipant;
    // debugPrint('[AUDIO] connected. me=${lp?.identity} name=${lp?.name} meta=${lp?.metadata}');
    // debugPrint('[AUDIO] remote count=${room.remoteParticipants.length}');

    _startEventListener();
  }

  Future<void> disconnect() async {
    // debugPrint('[AUDIO] disconnect()');
    _cancelListen?.call();
    _cancelListen = null;
    await _listener?.dispose();
    _listener = null;

    await _room?.disconnect();
    await _room?.dispose();
    _room = null;
  }

  Future<void> publishJson(
    Map<String, dynamic> m, {
    String topic = 'grp',
    bool reliable = true,
    List<String>? toIdentities,
  }) async {
    final r = _room;
    final lp = r?.localParticipant;
    if (r == null || lp == null) {
      // debugPrint('[AUDIO] publishJson skipped (room/local null)');
      return;
    }

    // ✅ 송신 로그
    // debugPrint('[AUDIO→] topic=$topic reliable=$reliable to=${toIdentities?.join(",") ?? "-"} payload=$m');

    final bytes = utf8.encode(json.encode(m));
    await lp.publishData(
      bytes,
      topic: topic,
      reliable: reliable,
      destinationIdentities: toIdentities,
    );
  }

  void Function({
    required String fromIdentity,
    required Map<String, dynamic> payload,
    String? topic,
    bool reliable,
  })? onData;

  // void _startEventListener() {
  //   final r = _room;
  //   if (r == null) return;

  //   _listener = r.createListener();
  //   debugPrint('[AUDIO] event listener started');

  //   _cancelListen = _listener!.listen((dynamic event) {
  //     final typeName = event.runtimeType.toString();

  //     // ✅ 모든 이벤트 타입 로깅 (필요시 주석 처리)
  //     debugPrint('[AUDIO EVT] $typeName');

  //     if (!typeName.contains('Data') || !typeName.contains('Received')) return;

  //     try {
  //       final participant = (event as dynamic).participant;
  //       final identity = (participant?.identity ?? '') as String;

  //       final List<int> raw = (event as dynamic).data as List<int>;
  //       final topic = (event as dynamic).topic as String?;
  //       final bool rel = ((event as dynamic).reliable as bool?) ?? true;

  //       final payload = json.decode(utf8.decode(raw)) as Map<String, dynamic>;

  //       // ✅ 수신 로그
  //       debugPrint('[AUDIO←] from=$identity topic=${topic ?? ""} reliable=$rel payload=$payload');

  //       onData?.call(
  //         fromIdentity: identity,
  //         payload: payload,
  //         topic: topic,
  //         reliable: rel,
  //       );
  //     } catch (e) {
  //       debugPrint('[AUDIO] decode error: $e');
  //     }
  //   });
  // }
void _startEventListener() {
  final r = _room;
  if (r == null) return;

  // 중복 리스너 정리
  _cancelListen?.call();
  _cancelListen = null;
  _listener?.dispose();

  _listener = r.createListener();
  debugPrint('[AUDIO] event listener started');

  // (옵션) 모든 이벤트 타입 로깅
  _cancelListen = _listener!.listen((ev) {
    debugPrint('[AUDIO EVT] ${ev.runtimeType}');
  });

  // ✅ LiveKit 2.2.0: 데이터는 모두 DataReceivedEvent 하나로 옴
  _listener!.on<lk.DataReceivedEvent>((e) {
    try {
      final topic = e.topic;
      if (topic != null && topic != 'grp') return; // 우리 토픽만 처리

      // participant는 nullable → null-safe
      final fromId = e.participant?.identity ?? '';

      // payload 디코딩
      final payload = json.decode(utf8.decode(e.data)) as Map<String, dynamic>;

      // 로깅 (reliable 플래그는 2.2.0에서 노출 X → true로 통일)
      debugPrint('[AUDIO←] from=$fromId topic=${topic ?? ""} reliable=true payload=$payload');

      onData?.call(
        fromIdentity: fromId,
        payload: payload,
        topic: topic,
        reliable: true, // 2.2.0은 구분값 없음 → 의미상 true로 전달
      );
    } catch (err) {
      debugPrint('[AUDIO] decode error: $err');
    }
  });
}


}
