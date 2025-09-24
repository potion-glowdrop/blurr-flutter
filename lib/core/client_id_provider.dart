// lib/core/client_id_provider.dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ClientIdProvider {
  static const _kKey = 'x_client_id_cache';

  Future<String> getClientId() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_kKey);
    if (cached != null && cached.isNotEmpty) return cached;

    final deviceInfo = DeviceInfoPlugin();
    String? id;
    if (Platform.isAndroid) {
      final a = await deviceInfo.androidInfo;
      id = a.id; // Android 10+에서도 안정적으로 있음(고유성 OK)
    } else if (Platform.isIOS) {
      final i = await deviceInfo.iosInfo;
      id = i.identifierForVendor;
    }
    id ??= const Uuid().v4();
    await prefs.setString(_kKey, id);
    return id;
  }
}
