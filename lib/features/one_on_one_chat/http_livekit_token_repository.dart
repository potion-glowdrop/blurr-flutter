// lib/features/one_on_one_chat/http_livekit_token_repository.dart
import 'package:dio/dio.dart';

/// 404 (방 없음) 전용 예외
class JoinNotFoundException implements Exception {
  final int roomId;
  final Response? response;
  JoinNotFoundException(this.roomId, [this.response]);

  @override
  String toString() =>
      'JoinNotFoundException(roomId: $roomId, status: ${response?.statusCode})';
}

/// 방 생성 요청 모델
class CreateRoomReq {
  final String roomName;   // 예: "나비의 방"
  final String duration;   // 예: "MIN15"
  final int maxCapacity;   // 예: 2

  const CreateRoomReq({
    required this.roomName,
    required this.duration,
    required this.maxCapacity,
  });

  Map<String, dynamic> toJson() => {
        'roomName': roomName,
        'duration': duration,
        'maxCapacity': maxCapacity,
      };
}

/// 방 생성 응답 모델
class CreateRoomRes {
  final int roomId;

  const CreateRoomRes(this.roomId);

  factory CreateRoomRes.fromJson(Map<String, dynamic> json) {
    // 서버 표준 응답: { status, code, message, data: { roomId: 123, ... } }
    final data = (json['data'] ?? {}) as Map;
    return CreateRoomRes(data['roomId'] as int);
  }
}

/// LiveKit 접속에 필요한 자격증명
class LiveKitCredentials {
  final String wsUrl;
  final String token;
  LiveKitCredentials({required this.wsUrl, required this.token});
}

/// 토큰 레포지토리 인터페이스
abstract class LiveKitTokenRepository {
  Future<LiveKitCredentials> fetchCredentials({
    required int roomId,
    required String identity,
  });

  Future<CreateRoomRes> createRoom(CreateRoomReq req);
}

/// HTTP 구현체
class HttpLiveKitTokenRepository implements LiveKitTokenRepository {
  final String baseUrl;            // 예: https://blurr.world  또는 http://192.168.x.x:8081
  final String clientId;           // 헤더로 전송: X-Client-Id
  final String? replaceLocalhost;  // wsUrl이 ws://localhost:xxxx 로 오면 치환할 호스트 (실기기 대응)
  final Dio _dio;

  HttpLiveKitTokenRepository({
    required this.baseUrl,
    required this.clientId,
    this.replaceLocalhost,
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              headers: {
                'X-Client-Id': clientId,
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              // 상태코드는 우리가 직접 판단
              validateStatus: (_) => true,
            )) {
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  Map<String, String> get _headers => {
        'X-Client-Id': clientId,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// 방 입장(토큰+wsUrl 받기) – 404면 JoinNotFoundException 던짐
  @override
  Future<LiveKitCredentials> fetchCredentials({
    required int roomId,
    required String identity, // 서버가 랜덤 닉네임 처리 → body 비워도 OK
  }) async {
    final resp = await _dio.post('/rooms/$roomId/join', data: const {}, options: Options(headers: _headers));
    final code = resp.statusCode ?? 0;

    if (code == 404) {
      throw JoinNotFoundException(roomId, resp);
    }
    if (code != 200 || resp.data is! Map) {
      throw Exception('Join API $code: ${resp.data}');
    }

    final map = resp.data as Map;
    final data = (map['data'] ?? {}) as Map;

    String? wsUrl = data['wsUrl']?.toString();
    final token = data['token']?.toString();

    if (wsUrl == null || token == null) {
      throw Exception('Missing wsUrl/token in response: ${resp.data}');
    }

    // 실기기 테스트 시 ws://localhost → ws://<맥IP> 로 치환
    if (replaceLocalhost != null) {
      final uri = Uri.parse(wsUrl);
      if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
        wsUrl = uri.replace(host: replaceLocalhost!).toString();
      }
    }

    return LiveKitCredentials(wsUrl: wsUrl, token: token);
  }

  /// 방 생성
  @override
  Future<CreateRoomRes> createRoom(CreateRoomReq req) async {
    final res = await _dio.post(
      '/rooms/add',
      data: req.toJson(),
      options: Options(headers: _headers),
    );

    if (res.statusCode == 200) {
      return CreateRoomRes.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Create room failed: ${res.statusCode} ${res.data}');
  }
}
