import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class IdentificadorDispositivo {

  static Future<String> obtenerId() async {

    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.id;
    }

    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return info.identifierForVendor ?? "ios_unknown";
    }

    return "dispositivo_desconocido";
  }
}