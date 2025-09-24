import 'package:dio/dio.dart';
import 'package:blurr/core/client_id_provider.dart'; // ✅ 추가

class MemberApi {
  MemberApi._();
  static final MemberApi I = MemberApi._();

  static const _apiPrefix = ''; // 필요 시 '/api' 등으로 교체
  String? _clientId;            // 캐시

  final _dio = Dio(BaseOptions(
    baseUrl: 'https://blurr.world', // 예: https://api.blurr.world
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // X-Client-Id는 인터셉터에서 주입
    },
    validateStatus: (s) => s != null && s < 500,
  ))
    ..interceptors.add(
      // ✅ 모든 요청에 X-Client-Id 자동 주입
      InterceptorsWrapper(onRequest: (options, handler) async {
        // 캐시된 값이 없으면 한 번만 생성/로딩
        I._clientId ??= await ClientIdProvider().getClientId();
        options.headers['X-Client-Id'] = I._clientId!;
        handler.next(options);
      }),
    );

  // (선택) 앱 시작 시 미리 준비하고 싶으면 호출
  Future<void> prepare() async {
    _clientId ??= await ClientIdProvider().getClientId();
  }

  void setAuthToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<bool> isRegistered() async {
    final res = await _dio.get('$_apiPrefix/members/info');
    return res.statusCode == 200;
  }

  Future<void> register({
    required String genderKo,
    required String ageKo,
    required String nickname,
    String role = 'CLIENT',
  }) async {
    final body = {
      'gender': _mapGender(genderKo),
      'age': _mapAge(ageKo),
      'role': role,
      'nickName': nickname,
    };

    final res = await _dio.post('$_apiPrefix/members', data: body);
    if (res.statusCode == 409) return; // 이미 가입
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('회원가입 실패 (${res.statusCode}) ${res.data}');
    }
  }

  String _mapGender(String g) {
    switch (g) {
      case '여성': return 'FEMALE';
      case '남성': return 'MALE';
      default: return 'UNKNOWN';
    }
  }

  String _mapAge(String a) {
    switch (a) {
      case '10대': return 'Teens';
      case '20대': return 'Twenties';
      case '30대': return 'Thirties';
      case '40대': return 'Forties';
      default: return 'FiftiesPlus';
    }
  }
}
