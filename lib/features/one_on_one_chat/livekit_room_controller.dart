// // lib/features/one_on_one_chat/livekit_room_controller.dart
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:livekit_client/livekit_client.dart' hide ConnectionState;

// /// 토큰 공급자 인터페이스 (원하는 구현체를 주입)
// abstract class LiveKitTokenRepository {
//   Future<String> fetchToken({required String roomName, required String identity});
// }

// /// LiveKit 룸 제어 전담 서비스
// class LiveKitRoomController {
//   final String url; // 예: wss://YOUR-LIVEKIT-URL
//   final LiveKitTokenRepository tokenRepo;

//   Room? _room;
//   EventsListener<RoomEvent>? _listener;

//   /// 연결 여부
//   final ValueNotifier<bool> connected = ValueNotifier<bool>(false);

//   Room? get room => _room;

//   LiveKitRoomController({
//     required this.url,
//     required this.tokenRepo,
//   });

//   /// 접속
//   Future<void> connect({
//     required String roomName,
//     required String identity,
//   }) async {
//     // 토큰 확보
//     final token = await tokenRepo.fetchToken(roomName: roomName, identity: identity);

//     // 룸 생성 및 이벤트 리스너 등록
//     final r = Room();
//     _room = r;

//     _listener?.dispose();
//     _listener = r.createListener()
//       ..on<RoomDisconnectedEvent>((e) {
//         connected.value = false;
//       })
//       ..on<ParticipantConnectedEvent>((e) {
//         _markDirty();
//       })
//       ..on<ParticipantDisconnectedEvent>((e) {
//         _markDirty();
//       })
//       ..on<TrackSubscribedEvent>((e) {
//         _markDirty();
//       })
//       ..on<TrackUnsubscribedEvent>((e) {
//         _markDirty();
//       });

//     // 접속
//     await r.connect(url, token);

//     // 카메라 & 마이크 ON (전면)
//     await r.localParticipant?.setCameraEnabled(
//       true,
//       cameraCaptureOptions:
//           const CameraCaptureOptions(cameraPosition: CameraPosition.front),
//     );
//     await r.localParticipant?.setMicrophoneEnabled(true);

//     connected.value = true;
//   }

//   /// 종료
//   Future<void> disconnect() async {
//     try {
//       await _room?.disconnect();
//     } catch (_) {}
//     connected.value = false;
//   }

//   /// 카메라 on/off
//   Future<void> setCameraEnabled(bool enable, {CameraCaptureOptions? options}) async {
//     final lp = _room?.localParticipant;
//     if (lp == null) return;
//     await lp.setCameraEnabled(enable,
//         cameraCaptureOptions: options ??
//             const CameraCaptureOptions(cameraPosition: CameraPosition.front));
//   }

//   /// 마이크 on/off
//   Future<void> setMicrophoneEnabled(bool enable) async {
//     final lp = _room?.localParticipant;
//     if (lp == null) return;
//     await lp.setMicrophoneEnabled(enable);
//   }

//   /// 첫 로컬 일반 비디오 트랙 (화면공유 제외)
//   VideoTrack? firstLocalVideoTrack() {
//     final lp = _room?.localParticipant;
//     if (lp == null) return null;
//     for (final pub in lp.videoTrackPublications) {
//       final t = pub.track;
//       if (t != null && !pub.isScreenShare) {
//         return t;
//       }
//     }
//     return null;
//   }

//   /// 첫 원격 일반 비디오 트랙 (화면공유 제외)
//   VideoTrack? firstRemoteVideoTrack() {
//     final values = _room?.remoteParticipants.values;
//     if (values == null || values.isEmpty) return null;
//     final rp = values.first;
//     for (final pub in rp.videoTrackPublications) {
//       if (pub.subscribed && !pub.isScreenShare) {
//         final t = pub.track;
//         if (t != null) return t;
//       }
//     }
//     return null;
//   }

//   void _markDirty() {
//     // 외부에서 ValueListenableBuilder로 사용한다면 setState 유도용
//     connected.value = connected.value;
//   }

//   Future<void> dispose() async {
//     _listener?.dispose();
//     _listener = null;
//     await _room?.dispose();
//     _room = null;
//   }
// }
// lib/features/one_on_one_chat/livekit_room_controller.dart
// lib/features/one_on_one_chat/livekit_room_controller.dart
// lib/features/one_on_one_chat/livekit_room_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'http_livekit_token_repository.dart'; // JoinNotFoundException, CreateRoomReq 등

class LiveKitRoomController {
  final LiveKitTokenRepository tokenRepo;

  LiveKitRoomController({required this.tokenRepo});

  final ValueNotifier<bool> connected = ValueNotifier(false);
  Room? _room;
  EventsListener<RoomEvent>? _listener;

  Room? get room => _room;

  Future<void> dispose() async {
    _listener?.dispose();
    await _room?.dispose();
  }

  // 필요하면 외부에서 쓰는 헬퍼들
  VideoTrack? firstLocalVideoTrack() {
    final lp = _room?.localParticipant;
    if (lp == null) return null;
    for (final pub in lp.videoTrackPublications) {
      final t = pub.track;
      if (t != null && !pub.isScreenShare) return t;
    }
    return null;
  }

  VideoTrack? firstRemoteVideoTrack() {
    final rps = _room?.remoteParticipants.values ?? const Iterable.empty();
    final rp = rps.isNotEmpty ? rps.first : null;
    if (rp == null) return null;
    for (final pub in rp.videoTrackPublications) {
      if (pub.subscribed && !pub.isScreenShare) {
        final t = pub.track;
        if (t != null) return t;
      }
    }
    return null;
  }

  /// roomId가 없으면 404 → 방 생성 → join 재시도
  Future<void> connect({
    required int roomId,
    required String identity,
  }) async {
    // 1) 자격 증명 얻기 (404면 생성 후 재시도)
    LiveKitCredentials creds;
    try {
      creds = await tokenRepo.fetchCredentials(roomId: roomId, identity: identity);
    } on JoinNotFoundException {
      // 방이 없으므로 생성
      // 서버 정책에 맞게 값 조정 (duration, maxCapacity)
      final created = await tokenRepo.createRoom(
        const CreateRoomReq(roomName: '1:1 상담방', duration: 'MIN15', maxCapacity: 2),
      );
      // 보통 서버는 생성된 roomId를 반환합니다. 원하는 roomId와 다를 수 있으니
      // 스펙에 맞게 사용하세요. 여기서는 "요청한 roomId로 다시 join" 방식이라
      // 서버가 동일 roomId로 생성하는지/매핑하는지 확인 필요.
      // 안전하게는 created.roomId로 join하는 편이 맞습니다.
      roomId = created.roomId;

      creds = await tokenRepo.fetchCredentials(roomId: roomId, identity: identity);
    }

    // 2) LiveKit 연결
    final room = Room();
    _room = room;

    _listener = room.createListener()
      ..on<RoomDisconnectedEvent>((_) => connected.value = false)
      ..on<ParticipantConnectedEvent>((_) => connected.value = true)
      ..on<TrackSubscribedEvent>((_) => connected.value = true)
      ..on<TrackUnsubscribedEvent>((_) => connected.value = true);

    await room.connect(creds.wsUrl, creds.token);

    // 3) 기본 캡처 ON (필요시 UI측에서 제어)
    await room.localParticipant?.setCameraEnabled(
      true,
      cameraCaptureOptions: const CameraCaptureOptions(cameraPosition: CameraPosition.front),
    );
    await room.localParticipant?.setMicrophoneEnabled(true);

    connected.value = true;
  }

  Future<void> setCameraEnabled(bool enabled, {CameraCaptureOptions? options}) async {
    final lp = _room?.localParticipant;
    if (lp == null) return;
    await lp.setCameraEnabled(enabled, cameraCaptureOptions: options);
  }
}
