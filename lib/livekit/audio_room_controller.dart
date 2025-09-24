// lib/livekit/audio_room_controller.dart
import 'package:livekit_client/livekit_client.dart' as lk;

class AudioRoomController {
  lk.Room? _room;

  Future<void> connect({required String wsUrl, required String token}) async {
    await disconnect();
    final room = lk.Room();
    await room.connect(wsUrl, token);
    // 내 마이크 on (상대에게 내 음성 전달)
    await room.localParticipant?.setMicrophoneEnabled(true);
    _room = room;
  }

  Future<void> disconnect() async {
    await _room?.disconnect();
    await _room?.dispose();
    _room = null;
  }
}
