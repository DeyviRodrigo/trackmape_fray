/// Responsabilidad: Cargar el archivo .env en disco y validar que las
/// variables de entorno publicas requeridas por el backend esten presentes.
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trackmape_sup/app2/conexion_backend/supabase/arranque/claves_entorno.dart';

// CARGADOR VARIABLES ENTORNO - Lee .env y valida las claves publicas requeridas
class CargadorVariablesEntorno {
  // CARGAR - Lee el archivo .env y valida presencia de las claves publicas
  static Future<void> cargar() async {
    await dotenv.load(fileName: '.env');

    final supabaseUrl = dotenv.env[ClavesEntorno.supabaseUrl];
    final supabaseAnonKey = dotenv.env[ClavesEntorno.supabaseAnonKey];

    final faltaUrl = supabaseUrl == null || supabaseUrl.trim().isEmpty;
    final faltaAnonKey =
        supabaseAnonKey == null || supabaseAnonKey.trim().isEmpty;

    if (faltaUrl || faltaAnonKey) {
      throw Exception(
        'Faltan variables de entorno: ${ClavesEntorno.supabaseUrl} o '
        '${ClavesEntorno.supabaseAnonKey}.',
      );
    }
  }
}
