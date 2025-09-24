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
// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:livekit_client/livekit_client.dart';
// import 'http_livekit_token_repository.dart'; // JoinNotFoundException, CreateRoomReq 등
// import 'package:livekit_client/livekit_client.dart' as lk;

// class LiveKitRoomController {
//   final LiveKitTokenRepository tokenRepo;

//   LiveKitRoomController({required this.tokenRepo});

//   final ValueNotifier<bool> connected = ValueNotifier(false);
//   Room? _room;
//   EventsListener<RoomEvent>? _listener;

//   Room? get room => _room;
//   final remoteVideoTrack = ValueNotifier<VideoTrack?>(null);

//   Future<void> dispose() async {
//     _listener?.dispose();
//     await _room?.dispose();
//   }

//   // 필요하면 외부에서 쓰는 헬퍼들
//   VideoTrack? firstLocalVideoTrack() {
//     final lp = _room?.localParticipant;
//     if (lp == null) return null;
//     for (final pub in lp.videoTrackPublications) {
//       final t = pub.track;
//       if (t != null && !pub.isScreenShare) return t;
//     }
//     return null;
//   }

//   VideoTrack? firstRemoteVideoTrack() {
//     final rps = _room?.remoteParticipants.values ?? const Iterable.empty();
//     final rp = rps.isNotEmpty ? rps.first : null;
//     if (rp == null) return null;
//     for (final pub in rp.videoTrackPublications) {
//       if (pub.subscribed && !pub.isScreenShare) {
//         final t = pub.track;
//         if (t != null) return t;
//       }
//     }
//     return null;
//   }

//   // /// roomId가 없으면 404 → 방 생성 → join 재시도
//   // Future<void> connect({
//   //   required int roomId,
//   //   required String identity,
//   // }) async {
//   //   // 1) 자격 증명 얻기 (404면 생성 후 재시도)
//   //   LiveKitCredentials creds;
//   //   try {
//   //     creds = await tokenRepo.fetchCredentials(roomId: roomId, identity: identity);
//   //   } on JoinNotFoundException {
//   //     // 방이 없으므로 생성
//   //     // 서버 정책에 맞게 값 조정 (duration, maxCapacity)
//   //     final created = await tokenRepo.createRoom(
//   //       const CreateRoomReq(roomName: '1:1 상담방', duration: 'MIN15', maxCapacity: 2),
//   //     );
//   //     // 보통 서버는 생성된 roomId를 반환합니다. 원하는 roomId와 다를 수 있으니
//   //     // 스펙에 맞게 사용하세요. 여기서는 "요청한 roomId로 다시 join" 방식이라
//   //     // 서버가 동일 roomId로 생성하는지/매핑하는지 확인 필요.
//   //     // 안전하게는 created.roomId로 join하는 편이 맞습니다.
//   //     roomId = created.roomId;

//   //     creds = await tokenRepo.fetchCredentials(roomId: roomId, identity: identity);
//   //   }
// // livekit_room_controller.dart (핵심부만 교체)
// Future<void> connect({
//   required int roomId,
//   required String identity,
// }) async {
//   // 1) 자격증명
//   LiveKitCredentials creds;
//   try {
//     creds = await tokenRepo.fetchCredentials(roomId: roomId, identity: identity);
//   } on JoinNotFoundException {
//     final created = await tokenRepo.createRoom(
//       const CreateRoomReq(roomName: '1:1 상담방', duration: 'MIN15', maxCapacity: 2),
//     );
//     roomId = created.roomId; // ← 생성된 roomId로 이어서 진행 (둘 다 같은 roomId 써야 함)
//     creds = await tokenRepo.fetchCredentials(roomId: roomId, identity: identity);
//   }

//   // 2) 방 객체 & 이벤트 한번만 연결
//   final room = Room();
//   _room = room;
//   _listener?.dispose();
// _listener = room.createListener()
//   ..on<ParticipantConnectedEvent>((e) async {
//     for (final pub in e.participant.videoTrackPublications) {
//       if (!pub.isScreenShare && !pub.subscribed) {
//         try { await pub.subscribe(); } catch (_) {}
//       }
//     }
//   })
//   ..on<TrackPublishedEvent>((e) async {
//     if (!e.publication.isScreenShare && !e.publication.subscribed) {
//       try { await e.publication.subscribe(); } catch (_) {}
//     }
//   })
//   ..on<TrackSubscribedEvent>((e) {
//     connected.value = true;
//     if (e.track is VideoTrack && !e.publication.isScreenShare) {
//       remoteVideoTrack.value = e.track as VideoTrack;
//     }
//   })
//   ..on<TrackUnsubscribedEvent>((e) {
//     if (remoteVideoTrack.value?.sid == e.track.sid) {
//       remoteVideoTrack.value = null;
//     }
//   })
//   ..on<RoomDisconnectedEvent>((_) => connected.value = false);

//   // 3) 단 한 번의 connect
//   await room.connect(
//     creds.wsUrl,
//     creds.token,
//     connectOptions: const ConnectOptions(autoSubscribe: true),
//     roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
//   );

//   // 4) 내 카메라/마이크 ON (딱 한 번)
//   await room.localParticipant?.setCameraEnabled(
//     true,
//     cameraCaptureOptions: const CameraCaptureOptions(
//       cameraPosition: CameraPosition.front,
//     ),
//   );
//   await room.localParticipant?.setMicrophoneEnabled(true);

//   connected.value = true;
// }


// // final remoteVideoTrack = ValueNotifier<lk.VideoTrack?>(null);

// void _wireRoomEvents(lk.Room room) {
//   _listener = room.createListener()
//     ..on<lk.ParticipantConnectedEvent>((e) async {
//       // 새로 들어온 참가자가 이미 발행한 비디오가 있으면 구독 시도
//       for (final pub in e.participant.videoTrackPublications) {
//         if (!pub.isScreenShare && !pub.subscribed) {
//           try { await pub.subscribe(); } catch (_) {}
//         }
//       }
//     })
//     ..on<lk.TrackPublishedEvent>((e) async {
//       // 일부 버전에선 kind enum이 달라서 타입 체크/구독만 수행
//       if (!e.publication.isScreenShare && !e.publication.subscribed) {
//         try { await e.publication.subscribe(); } catch (_) {}
//       }
//     })
//     ..on<lk.TrackSubscribedEvent>((e) {
//       // ⬅️ 여기! enum 대신 타입으로 체크
//       final t = e.track;
//       if (t is lk.VideoTrack && !e.publication.isScreenShare) {
//         remoteVideoTrack.value = t;
//       }
//     })
//     ..on<lk.TrackUnsubscribedEvent>((e) {
//       if (remoteVideoTrack.value?.sid == e.track.sid) {
//         remoteVideoTrack.value = null;
//       }
//     })
//     ..on<lk.RoomDisconnectedEvent>((_) {
//       remoteVideoTrack.value = null;
//       connected.value = false;
//     });
// }

//     // 2) LiveKit 연결
//     final room = Room();
//     _room = room;
//     _wireRoomEvents(room);

//     await room.connect(
//       creds.wsUrl,
//       creds.token,
//       connectOptions: const lk.ConnectOptions(autoSubscribe: true),
//       roomOptions: const lk.RoomOptions(adaptiveStream: true, dynacast: true),
//     );

//     // 입장 직후 발행 보장 (양쪽 모두)
//     await room.localParticipant?.setCameraEnabled(
//       true,
//       cameraCaptureOptions: const lk.CameraCaptureOptions(
//         cameraPosition: lk.CameraPosition.front,
//       ),
//     );
//     await room.localParticipant?.setMicrophoneEnabled(true);


//     _listener = room.createListener()
//       ..on<RoomDisconnectedEvent>((_) => connected.value = false)
//       ..on<ParticipantConnectedEvent>((_) => connected.value = true)
//       ..on<TrackSubscribedEvent>((_) => connected.value = true)
//       ..on<TrackUnsubscribedEvent>((_) => connected.value = true);

//     await room.connect(creds.wsUrl, creds.token, roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true,), connectOptions: const ConnectOptions(autoSubscribe: true));

//     // 3) 기본 캡처 ON (필요시 UI측에서 제어)
//     await room.localParticipant?.setCameraEnabled(
//       true,
//       cameraCaptureOptions: const CameraCaptureOptions(cameraPosition: CameraPosition.front),
//     );
//     await room.localParticipant?.setMicrophoneEnabled(true);

//     connected.value = true;
//   }

//   Future<void> setCameraEnabled(bool enabled, {CameraCaptureOptions? options}) async {
//     final lp = _room?.localParticipant;
//     if (lp == null) return;
//     await lp.setCameraEnabled(enabled, cameraCaptureOptions: options);
//   }
// }
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'http_livekit_token_repository.dart'; // JoinNotFoundException, CreateRoomReq 등
import 'package:livekit_client/livekit_client.dart' as lk;



lk.EventsListener<lk.RoomEvent>? _logListener;

void wireTrackLogging(lk.Room room) {
  String pid(lk.Participant p) => '${p.identity}(${p.sid.substring(0,6)})';

  _logListener = room.createListener()
    ..on<lk.ParticipantConnectedEvent>((e) {
      debugPrint('👤 Connected: ${pid(e.participant)}');
      for (final pub in e.participant.videoTrackPublications) {
        debugPrint('  has video pub: ${pub.sid} subscribed=${pub.subscribed}');
      }
    })
    ..on<lk.ParticipantDisconnectedEvent>((e) {
      debugPrint('👋 Disconnected: ${pid(e.participant)}');
    })
    ..on<lk.TrackPublishedEvent>((e) async {
      debugPrint('📣 Published from ${pid(e.participant)} '
                 'pub=${e.publication.sid} screenShare=${e.publication.isScreenShare}');
      if (!e.publication.isScreenShare && !e.publication.subscribed) {
        try { await e.publication.subscribe(); debugPrint('✅ subscribe ok: ${e.publication.sid}'); }
        catch (err) { debugPrint('❗ subscribe failed: ${e.publication.sid} err=$err'); }
      }
    })
    ..on<lk.TrackSubscribedEvent>((e) {
      final kind = e.track.runtimeType.toString(); // VideoTrack/AudioTrack
      debugPrint('✅ Subscribed track=${e.track.sid} kind=$kind from ${pid(e.publication.participant)}');
    })
    ..on<lk.TrackUnsubscribedEvent>((e) {
      debugPrint('🚫 Unsubscribed track=${e.track.sid} from ${pid(e.publication.participant)}');
    })
    ..on<lk.RoomDisconnectedEvent>((_) {
      debugPrint('🔌 RoomDisconnected');
    });
}
void dumpRoom(lk.Room room) {
  debugPrint('===== SNAPSHOT =====');
  debugPrint('local: ${room.localParticipant?.identity}');
  for (final rp in room.remoteParticipants.values) {
    debugPrint('remote: ${rp.identity}(${rp.sid})');
    for (final p in rp.videoTrackPublications) {
      debugPrint('  videoPub ${p.sid} subscribed=${p.subscribed} muted=${p.muted} track=${p.track?.sid}');
    }
  }
  debugPrint('====================');
}

class LiveKitRoomController {
  final LiveKitTokenRepository tokenRepo;

  LiveKitRoomController({required this.tokenRepo});

  final ValueNotifier<bool> connected = ValueNotifier(false);

  // 원격 비디오 트랙 (UI에서 구독할 수 있도록 노출)
  final remoteVideoTrack = ValueNotifier<VideoTrack?>(null);

  Room? _room;
  EventsListener<RoomEvent>? _listener;

  Room? get room => _room;

  Future<void> dispose() async {
    _listener?.dispose();
    await _room?.dispose();
  }
void dumpLocalPublish(lk.Room room) {
  final lp = room.localParticipant;
  if (lp == null) {
    debugPrint('❓ localParticipant = null');
    return;
  }
  final vids = lp.videoTrackPublications;
  final auds = lp.audioTrackPublications;
  debugPrint('----- LOCAL PUBLISH -----');
  debugPrint('video pubs: ${vids.length}, audio pubs: ${auds.length}');
  for (final p in vids) {
    debugPrint('🎥 videoPub sid=${p.sid} subscribed(N/A) muted=${p.muted} '
               'track=${p.track?.sid} isScreenShare=${p.isScreenShare}');
  }
  for (final p in auds) {
    debugPrint('🎙️ audioPub sid=${p.sid} muted=${p.muted} track=${p.track?.sid}');
  }
  debugPrint('-------------------------');
}

  /// 내 로컬 비디오 트랙 반환
  VideoTrack? firstLocalVideoTrack() {
    final lp = _room?.localParticipant;
    if (lp == null) return null;
    for (final pub in lp.videoTrackPublications) {
      final t = pub.track;
      if (t != null && !pub.isScreenShare) return t;
    }
    return null;
  }

  /// 기본 연결 로직
  Future<void> connect({
    required int roomId,
    required String identity,
  }) async {
    // 1) 토큰 가져오기 (없으면 방 생성 후 재시도)
    LiveKitCredentials creds;
    try {
      creds = await tokenRepo.fetchCredentials(roomId: roomId, identity: identity);
    } on JoinNotFoundException {
      final created = await tokenRepo.createRoom(
        const CreateRoomReq(roomName: '1:1 상담방', duration: 'MIN15', maxCapacity: 2),
      );
      roomId = created.roomId;
      creds = await tokenRepo.fetchCredentials(roomId: roomId, identity: identity);
    }

    // 2) Room 객체 생성 + 이벤트 연결
    final room = lk.Room();
    _room = room;
    _wireRoomEvents(room);
    // _wireLogging(room);

    await room.connect(
      creds.wsUrl,
      creds.token,
      connectOptions: const lk.ConnectOptions(autoSubscribe: true),
      roomOptions: const lk.RoomOptions(adaptiveStream: true, dynacast: true),
    );

    // 3) 로컬 카메라/마이크 발행
    await room.localParticipant?.setCameraEnabled(
      true,
      cameraCaptureOptions: const lk.CameraCaptureOptions(cameraPosition: lk.CameraPosition.front),
    );
    await room.localParticipant?.setMicrophoneEnabled(true);

    connected.value = true;
  // connect() 끝부분
  await room.localParticipant?.setCameraEnabled(
    true,
    cameraCaptureOptions: const lk.CameraCaptureOptions(
      cameraPosition: lk.CameraPosition.front,
    ),
  );
  await room.localParticipant?.setMicrophoneEnabled(true);

  // 1~2초 후 로컬 발행 상태 덤프
  Future.delayed(const Duration(seconds: 2), () => dumpLocalPublish(room));

  }

  /// 이벤트 바인딩
  void _wireRoomEvents(Room room) {
    _listener?.dispose();
    _listener = room.createListener()
      ..on<lk.ParticipantConnectedEvent>((e) async {
        // 새 참가자가 들어오면 발행된 트랙 구독
        for (final pub in e.participant.videoTrackPublications) {
          if (!pub.isScreenShare && !pub.subscribed) {
            try { await pub.subscribe(); } catch (_) {}
          }
        }
      })
      ..on<lk.TrackPublishedEvent>((e) async {
        // 트랙이 발행되면 구독 시도
        if (!e.publication.isScreenShare && !e.publication.subscribed) {
          try { await e.publication.subscribe(); } catch (_) {}
        }
      })
      ..on<lk.TrackSubscribedEvent>((e) {
        // 실제로 구독되면 remoteVideoTrack에 저장
        if (e.track is lk.VideoTrack && !e.publication.isScreenShare) {
          remoteVideoTrack.value = e.track as VideoTrack;
        }
      })
      ..on<lk.TrackUnsubscribedEvent>((e) {
        if (remoteVideoTrack.value?.sid == e.track.sid) {
          remoteVideoTrack.value = null;
        }
      })
      ..on<lk.RoomDisconnectedEvent>((_) {
        remoteVideoTrack.value = null;
        connected.value = false;
      });
  }

  /// 카메라 ON/OFF 제어
  Future<void> setCameraEnabled(bool enabled, {CameraCaptureOptions? options}) async {
    final lp = _room?.localParticipant;
    if (lp == null) return;
    await lp.setCameraEnabled(enabled, cameraCaptureOptions: options);
  }
}
