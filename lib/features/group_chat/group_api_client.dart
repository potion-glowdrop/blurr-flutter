// // lib/net/group_api_client.dart
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart'; // ← 추가: debugPrint용

// class GroupApiClient {
//   final Dio _dio;

//   // ↓↓↓ 여기만 교체: _makeDio(baseUrl) 사용
//   GroupApiClient(String baseUrl) : _dio = _makeDio(baseUrl);

//   Future<List<Map<String, dynamic>>> listRooms() async {
//     final r = await _dio.get('/rooms/list');
//     return (r.data['data'] as List).cast<Map<String, dynamic>>();
//   }

//   Future<int> addRoom({
//     required String roomName,
//     String duration = 'MIN15',
//     int maxCap = 8,
//   }) async {
//     final r = await _dio.post('/rooms/add', data: {
//       'roomName': roomName,
//       'duration': duration,
//       'maxCapacity': maxCap,
//     });
//     return r.data['data']['roomId'] as int;
//   }

//   Future<Map<String, String>> joinRoom(int roomId) async {
//     final r = await _dio.post('/rooms/$roomId/join');
//     final d = r.data['data'];
//     return {'wsUrl': d['wsUrl'], 'token': d['token']};
//   }

//   /// 이름으로 방 찾고 없으면 생성 → roomId 반환
//   Future<int> getOrCreateRoomId(String roomName) async {
//     final rooms = await listRooms();
//     final hit = rooms.firstWhere(
//       (e) => (e['roomName'] == roomName) && (e['active'] == true),
//       orElse: () => {},
//     );
//     if (hit.isNotEmpty) return hit['id'] as int;
//     return await addRoom(roomName: roomName);
//   }
// }

// /// -------- 여기부터 추가: 로깅/validateStatus 적용된 Dio 생성기 --------
// Dio _makeDio(String baseUrl) {
//   final dio = Dio(BaseOptions(
//     baseUrl: baseUrl,
//     connectTimeout: const Duration(seconds: 8),
//     // 4xx도 throw하지 않고 응답을 돌려줌(우리가 직접 확인)
//     validateStatus: (_) => true,
//     headers: {'Content-Type': 'application/json'},
//   ));

//   dio.interceptors.add(
//     InterceptorsWrapper(
//       onRequest: (o, h) {
//         debugPrint('➡️ ${o.method} ${o.uri}\n${o.data ?? ''}');
//         h.next(o);
//       },
//       onResponse: (r, h) {
//         debugPrint('✅ ${r.statusCode} ${r.requestOptions.uri}\n${r.data}');
//         h.next(r);
//       },
//       onError: (e, h) {
//         debugPrint('❌ ${e.response?.statusCode} ${e.requestOptions.uri}\n${e.response?.data}');
//         h.next(e);
//       },
//     ),
//   );
//   return dio;
// }
// lib/net/group_api_client.dart
// lib/net/group_api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class GroupApiClient {
  final Dio _dio;
  GroupApiClient(String baseUrl)
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 8),
        ));

  Never _throw(Response r, String where) {
    throw '$where -> HTTP ${r.statusCode}: ${r.data}';
  }

  Future<List<Map<String, dynamic>>> listRooms() async {
    final r = await _dio.get(
      '/rooms/list',
      options: Options(validateStatus: (code) => true), // ← 핵심
    );
    debugPrint('listRooms ${r.statusCode} ${r.data}');
    if (r.statusCode != 200) _throw(r, 'GET /rooms/list');
    final data = r.data['data'];
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<int> addRoom({
    required String roomName,
    String duration = 'MIN15',
    int maxCap = 8,
  }) async {
    final r = await _dio.post(
      '/rooms/add',
      data: {
        'roomName': roomName,
        'duration': duration,
        'maxCapacity': maxCap,
      },
      options: Options(validateStatus: (code) => true), // ← 핵심
    );
    debugPrint('addRoom ${r.statusCode} ${r.data}');
    if (r.statusCode != 200) _throw(r, 'POST /rooms/add');
    return (r.data['data']['roomId'] as num).toInt();
  }

  // Future<Map<String, String>> joinRoom(int roomId) async {
  //   final r = await _dio.post(
  //     '/rooms/$roomId/join',
  //     options: Options(validateStatus: (code) => true), // ← 핵심
  //   );
  //   debugPrint('joinRoom($roomId) ${r.statusCode} ${r.data}');
  //   if (r.statusCode != 200) _throw(r, 'POST /rooms/$roomId/join');
  //   final d = r.data['data'] as Map<String, dynamic>;
  //   return {'wsUrl': '${d['wsUrl']}', 'token': '${d['token']}'};
  // }
// Future<Map<String, String>> joinRoom(int roomId) async {
//   final r = await _dio.post(
//     '/rooms/$roomId/join',
//     options: Options(validateStatus: (code) => true), // 404여도 바디 받기
//   );
//   debugPrint('[API] joinRoom($roomId) status=${r.statusCode} body=${r.data}');
//   if (r.statusCode != 200) {
//     throw 'POST /rooms/$roomId/join -> ${r.statusCode}: ${r.data}';
//   }
//   final d = r.data['data'] as Map<String, dynamic>;
//   return {'wsUrl': '${d['wsUrl']}', 'token': '${d['token']}'};
// }
// lib/net/group_api_client.dart

Future<Map<String, String>> joinRoom(int roomId) async {
  final r = await _dio.post(
    '/rooms/$roomId/join',
    // ★ 404/4xx여도 throw하지 않고 r.statusCode / r.data를 받기
    options: Options(validateStatus: (code) => true),
  );
  debugPrint('[API] joinRoom($roomId) status=${r.statusCode} body=${r.data}');
  if (r.statusCode != 200) {
    throw 'POST /rooms/$roomId/join -> ${r.statusCode}: ${r.data}';
  }
  final d = r.data['data'] as Map<String, dynamic>;
  return {'wsUrl': '${d['wsUrl']}', 'token': '${d['token']}'};
}

  Future<int> getOrCreateRoomId(String roomName) async {
    final rooms = await listRooms();
    final hit = rooms.firstWhere(
      (e) => (e['roomName'] == roomName) && (e['active'] == true),
      orElse: () => const {},
    );
    if (hit.isNotEmpty) return (hit['id'] as num).toInt();
    return await addRoom(roomName: roomName);
  }


Dio _makeDio(String baseUrl) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 8),
    validateStatus: (_) => true,           // ← 4xx도 던지지 않고 응답 반환
    headers: {'Content-Type': 'application/json'},
  ));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (o, h) { debugPrint('➡️ ${o.method} ${o.uri}\n${o.data ?? ''}'); h.next(o); },
    onResponse: (r, h) { debugPrint('✅ ${r.statusCode} ${r.requestOptions.uri}\n${r.data}'); h.next(r); },
    onError: (e, h) { debugPrint('❌ ${e.response?.statusCode} ${e.requestOptions.uri}\n${e.response?.data}'); h.next(e); },
  ));
  return dio;
}
}