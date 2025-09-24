// lib/net/group_api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:blurr/core/client_id_provider.dart';

class GroupApiClient {
  final Dio _dio;
  final ClientIdProvider _clientIdProvider;

  GroupApiClient(String baseUrl, {ClientIdProvider? clientIdProvider})
      : _clientIdProvider = clientIdProvider ?? ClientIdProvider(),
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 8),
        )) {
    // 1) X-Client-Id를 매 요청에 자동 주입 (비동기 OK)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final id = await _clientIdProvider.getClientId();
        options.headers['X-Client-Id'] = id;
        options.headers['Accept'] = 'application/json';
        options.headers['Content-Type'] = 'application/json';
        debugPrint('➡️ ${options.method} ${options.uri} X-Client-Id=$id');
        handler.next(options);
      },
      onResponse: (r, h) { debugPrint('✅ ${r.statusCode} ${r.requestOptions.uri}\n${r.data}'); h.next(r); },
      onError: (e, h) { debugPrint('❌ ${e.response?.statusCode} ${e.requestOptions.uri}\n${e.response?.data}'); h.next(e); },
    ));
  }

  Never _throw(Response r, String where) => throw '$where -> HTTP ${r.statusCode}: ${r.data}';

  Future<List<Map<String, dynamic>>> listRooms() async {
    final r = await _dio.get('/rooms/list', options: Options(validateStatus: (_) => true));
    if (r.statusCode != 200) _throw(r, 'GET /rooms/list');
    return (r.data['data'] as List).cast<Map<String, dynamic>>();
  }

  Future<int> addRoom({required String roomName, String duration = 'MIN15', int maxCap = 8}) async {
    final r = await _dio.post('/rooms/add',
      data: {'roomName': roomName, 'duration': duration, 'maxCapacity': maxCap},
      options: Options(validateStatus: (_) => true),
    );
    if (r.statusCode != 200) _throw(r, 'POST /rooms/add');
    return (r.data['data']['roomId'] as num).toInt();
  }

  Future<Map<String, String>> joinRoom(int roomId) async {
    final r = await _dio.post('/rooms/$roomId/join',
      options: Options(validateStatus: (_) => true),
    );
    if (r.statusCode != 200) _throw(r, 'POST /rooms/$roomId/join');
    final d = r.data['data'] as Map<String, dynamic>;
    return {
      'wsUrl': '${d['wsUrl']}',
      'token': '${d['token']}',
      // 필요하면 여기서 roomId, randomName도 함께 뽑아 넘길 수 있음
    };
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
}
