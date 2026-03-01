import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class IdentificadorDispositivo {

  static Future<String> obtenerId() async {

    final deviceInfo = DeviceInfoPlugin();

    try {
      // ========================================
      // CASO 1: WEB (Chrome, Edge, etc.)
      // ========================================
      if (kIsWeb) {
        final info = await deviceInfo.webBrowserInfo;
        // Combinamos varios datos para crear un ID único
        final navegador = info.browserName.name;
        final plataforma = info.platform ?? 'web';
        final userAgent = info.userAgent ?? '';

        // Generamos un hash simple del userAgent para diferenciarlo
        final hash = userAgent.hashCode.abs().toString();

        return 'WEB_${navegador}_${plataforma}_$hash';
      }

      // ========================================
      // CASO 2: ANDROID
      // ========================================
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return info.id;
      }

      // ========================================
      // CASO 3: iOS
      // ========================================
      if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        return info.identifierForVendor ?? 'ios_${DateTime.now().millisecondsSinceEpoch}';
      }

      // ========================================
      // CASO 4: WINDOWS / LINUX / MACOS
      // ========================================
      if (Platform.isWindows) {
        final info = await deviceInfo.windowsInfo;
        return 'WIN_${info.computerName}_${info.deviceId}';
      }

      if (Platform.isLinux) {
        final info = await deviceInfo.linuxInfo;
        return 'LINUX_${info.machineId ?? info.id}';
      }

      if (Platform.isMacOS) {
        final info = await deviceInfo.macOsInfo;
        return 'MAC_${info.systemGUID ?? info.computerName}';
      }

    } catch (e) {
      // Si falla, generamos un ID único basado en tiempo
      return 'FALLBACK_${DateTime.now().millisecondsSinceEpoch}';
    }

    return 'UNKNOWN_${DateTime.now().millisecondsSinceEpoch}';
  }
}