import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trackmape_sup/app/conexion_backend/supabase/env_keys.dart';

class EnvLoader {
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');

    final supabaseUrl = dotenv.env[EnvKeys.supabaseUrl];
    final supabaseAnonKey = dotenv.env[EnvKeys.supabaseAnonKey];

    final faltaUrl = supabaseUrl == null || supabaseUrl.trim().isEmpty;
    final faltaAnonKey =
        supabaseAnonKey == null || supabaseAnonKey.trim().isEmpty;

    if (faltaUrl || faltaAnonKey) {
      throw Exception(
        'Faltan variables de entorno: ${EnvKeys.supabaseUrl} o ${EnvKeys.supabaseAnonKey}.',
      );
    }
  }
}
