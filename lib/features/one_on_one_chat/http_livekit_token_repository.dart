// // lib/features/one_on_one_chat/http_livekit_token_repository.dart
// import 'package:dio/dio.dart';

// /// 404 (방 없음) 전용 예외
// class JoinNotFoundException implements Exception {
//   final int roomId;
//   final Response? response;
//   JoinNotFoundException(this.roomId, [this.response]);

//   @override
//   String toString() =>
//       'JoinNotFoundException(roomId: $roomId, status: ${response?.statusCode})';
// }

// /// 방 생성 요청 모델
// class CreateRoomReq {
//   final String roomName;   // 예: "나비의 방"
//   final String duration;   // 예: "MIN15"
//   final int maxCapacity;   // 예: 2

//   const CreateRoomReq({
//     required this.roomName,
//     required this.duration,
//     required this.maxCapacity,
//   });

//   Map<String, dynamic> toJson() => {
//         'roomName': roomName,
//         'duration': duration,
//         'maxCapacity': maxCapacity,
//       };
// }

// /// 방 생성 응답 모델
// class CreateRoomRes {
//   final int roomId;

//   const CreateRoomRes(this.roomId);

//   factory CreateRoomRes.fromJson(Map<String, dynamic> json) {
//     // 서버 표준 응답: { status, code, message, data: { roomId: 123, ... } }
//     final data = (json['data'] ?? {}) as Map;
//     return CreateRoomRes(data['roomId'] as int);
//   }
// }

// /// LiveKit 접속에 필요한 자격증명
// class LiveKitCredentials {
//   final String wsUrl;
//   final String token;
//   LiveKitCredentials({required this.wsUrl, required this.token});
// }

// /// 토큰 레포지토리 인터페이스
// abstract class LiveKitTokenRepository {
//   Future<LiveKitCredentials> fetchCredentials({
//     required int roomId,
//     required String identity,
//   });

//   Future<CreateRoomRes> createRoom(CreateRoomReq req);
// }

// /// HTTP 구현체
// class HttpLiveKitTokenRepository implements LiveKitTokenRepository {
//   final String baseUrl;            // 예: https://blurr.world  또는 http://192.168.x.x:8081
//   final String clientId;           // 헤더로 전송: X-Client-Id
//   final String? replaceLocalhost;  // wsUrl이 ws://localhost:xxxx 로 오면 치환할 호스트 (실기기 대응)
//   final Dio _dio;

//   HttpLiveKitTokenRepository({
//     required this.baseUrl,
//     required this.clientId,
//     this.replaceLocalhost,
//     Dio? dio,
//   }) : _dio = dio ??
//             Dio(BaseOptions(
//               baseUrl: baseUrl,
//               connectTimeout: const Duration(seconds: 8),
//               receiveTimeout: const Duration(seconds: 8),
//               headers: {
//                 'X-Client-Id': clientId,
//                 'Content-Type': 'application/json',
//                 'Accept': 'application/json',
//               },
//               // 상태코드는 우리가 직접 판단
//               validateStatus: (_) => true,
//             )) {
//     _dio.interceptors.add(
//       LogInterceptor(
//         requestHeader: true,
//         requestBody: true,
//         responseBody: true,
//       ),
//     );
//   }

//   Map<String, String> get _headers => {
//         'X-Client-Id': clientId,
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       };

//   /// 방 입장(토큰+wsUrl 받기) – 404면 JoinNotFoundException 던짐
//   @override
//   Future<LiveKitCredentials> fetchCredentials({
//     required int roomId,
//     required String identity, // 서버가 랜덤 닉네임 처리 → body 비워도 OK
//   }) async {
//     final resp = await _dio.post('/rooms/$roomId/join', data: const {}, options: Options(headers: _headers));
//     final code = resp.statusCode ?? 0;

//     if (code == 404) {
//       throw JoinNotFoundException(roomId, resp);
//     }
//     if (code != 200 || resp.data is! Map) {
//       throw Exception('Join API $code: ${resp.data}');
//     }

//     final map = resp.data as Map;
//     final data = (map['data'] ?? {}) as Map;

//     String? wsUrl = data['wsUrl']?.toString();
//     final token = data['token']?.toString();

//     if (wsUrl == null || token == null) {
//       throw Exception('Missing wsUrl/token in response: ${resp.data}');
//     }

//     // 실기기 테스트 시 ws://localhost → ws://<맥IP> 로 치환
//     if (replaceLocalhost != null) {
//       final uri = Uri.parse(wsUrl);
//       if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
//         wsUrl = uri.replace(host: replaceLocalhost!).toString();
//       }
//     }

//     return LiveKitCredentials(wsUrl: wsUrl, token: token);
//   }

//   /// 방 생성
//   @override
//   Future<CreateRoomRes> createRoom(CreateRoomReq req) async {
//     final res = await _dio.post(
//       '/rooms/add',
//       data: req.toJson(),
//       options: Options(headers: _headers),
//     );

//     if (res.statusCode == 200) {
//       return CreateRoomRes.fromJson(res.data as Map<String, dynamic>);
//     }
//     throw Exception('Create room failed: ${res.statusCode} ${res.data}');
//   }
// }

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
  /// 여기서 roomName을 "입장 코드"로 사용한다.
  final String roomName;   // 예: "888"
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

/// /rooms/list 항목 최소 모델
class RoomSummary {
  final int id;
  final String roomName;
  final bool active;

  RoomSummary({
    required this.id,
    required this.roomName,
    required this.active,
  });

  factory RoomSummary.fromJson(Map<String, dynamic> m) => RoomSummary(
        id: m['id'] as int,
        roomName: (m['roomName'] ?? '').toString(),
        active: (m['active'] as bool?) ?? true,
      );
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

  /// 추가: 코드(=roomName) 기반으로 동일 방에 조인 or 생성
  Future<LiveKitCredentials> joinOrCreateByCode({
    required String code,
    required String identity,
  });
}

/// 문자열 정규화(코드 비교 규칙 통일: 필요시 강화)
extension _Normalize on String {
  String normCode() => trim().toLowerCase();
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
    final resp = await _dio.post(
      '/rooms/$roomId/join',
      data: const {},
      options: Options(headers: _headers),
    );
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

  /// ===== 여기부터: "같은 코드면 같은 방" 조인-또는-생성 =====

  /// 활성 방 목록 조회
  Future<List<RoomSummary>> _fetchActiveRooms() async {
    final resp = await _dio.get(
      '/rooms/list',
      options: Options(headers: _headers),
    );
    if ((resp.statusCode ?? 0) != 200 || resp.data is! Map) {
      throw Exception('rooms/list failed: ${resp.statusCode} ${resp.data}');
    }
    final map = resp.data as Map;
    final list = (map['data'] as List?) ?? const [];
    return list
        .map((e) => RoomSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// code(=roomName)와 같은 활성 방 id 찾기(없으면 null)
  Future<int?> _findActiveRoomIdByCode(String code) async {
    final target = code.normCode();
    final rooms = await _fetchActiveRooms(); // 스웨거: 최신 생성 순으로 반환
    final hit = rooms.firstWhere(
      (r) => r.active && r.roomName.normCode() == target,
      orElse: () => RoomSummary(id: -1, roomName: '', active: false),
    );
    return hit.id > 0 ? hit.id : null;
  }

  /// 코드 기반: 같은 코드면 같은 방으로 조인 또는 생성
  @override
  Future<LiveKitCredentials> joinOrCreateByCode({
    required String code,
    required String identity,
  }) async {
    // 1) 같은 이름의 활성 방이 이미 있나?
    int? roomId = await _findActiveRoomIdByCode(code);

    // 2) 없으면 생성(방 이름에 code 사용)
    if (roomId == null) {
      final created = await createRoom(CreateRoomReq(
        roomName: code,     // 핵심
        duration: 'MIN15',
        maxCapacity: 2,
      ));
      roomId = created.roomId;

      // (선택) 극단적 레이스 안전을 원하면 재확인
      // final again = await _findActiveRoomIdByCode(code);
      // roomId = again ?? roomId;
    }

    // 3) 토큰/WS
    return fetchCredentials(roomId: roomId, identity: identity);
  }
}
