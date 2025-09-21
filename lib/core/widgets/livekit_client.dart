import 'package:livekit_client/livekit_client.dart';

late final Room _room;
EventsListener<RoomEvent>? _roomListener;

Future<void> connectLiveKit(String token, {required String url}) async {
  _room = Room();

  // 1) 이벤트 리스너 생성
  _roomListener = _room.createListener();

  // 2) 필요한 이벤트 구독
  _roomListener!
    // 방 끊김 등
    ..on<RoomDisconnectedEvent>((e) {
      // TODO: UI 정리
    })
    // 원격 참가자 입장
    ..on<ParticipantConnectedEvent>((e) {
      // e.participant => RemoteParticipant
      // setState(() {}); // 필요 시
    })
    // 트랙 구독(상대 비디오 올라옴)
    ..on<TrackSubscribedEvent>((e) {
      // e.participant, e.track (VideoTrack/AudioTrack)
      // setState(() {});
    })
    // 트랙 해제
    ..on<TrackUnsubscribedEvent>((e) {
      // setState(() {});
    });

  // (선택) 일반적인 상태변화 알림
  _room.addListener(() {
    // room.activeSpeakers / participants 등 변하면 옵니다
    // setState(() {});
  });

  // 3) 접속
  await _room.connect(url, token);

  // 4) 내 카메라/마이크 publish
  await _room.localParticipant?.setCameraEnabled(true);
  await _room.localParticipant?.setMicrophoneEnabled(true);

  await _room.localParticipant?.setCameraEnabled(
    true,
    cameraCaptureOptions: const CameraCaptureOptions(
      cameraPosition: CameraPosition.front,
    ),
  );
}

// ✅ 위젯 dispose에서 꼭 정리
Future<void> disposeLiveKit() async {
  await _roomListener?.dispose();
  await _room.dispose();
}
