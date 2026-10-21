/// Responsabilidad: Capturar y gestionar errores no controlados en hilos de
/// interfaz de usuario y tareas asincronas para registrar logs y evitar
/// cierres inesperados.
library;

import 'package:flutter/foundation.dart';

// GESTION ERRORES APP - Captura centralizada y gestion de excepciones globales
class GestionErroresApp {
  GestionErroresApp._();

  // INICIALIZAR - Configura los callbacks globales de Flutter y PlatformDispatcher
  static void inicializar() {
    FlutterError.onError = (detalles) {
      FlutterError.presentError(detalles);
      debugPrint('ERROR GLOBAL UI: ${detalles.exceptionAsString()}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('ERROR GLOBAL ASINCRONO: $error\n$stack');
      return true;
    };
  }
}
