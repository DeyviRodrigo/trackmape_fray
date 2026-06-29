import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trackmape_sup/app/conexion_backend/supabase/env_keys.dart';

class SupabaseInit {
  static Future<void> init() async {
    final supabaseUrl = dotenv.env[EnvKeys.supabaseUrl];
    final supabaseAnonKey = dotenv.env[EnvKeys.supabaseAnonKey];

    await Supabase.initialize(
      url: supabaseUrl ?? '',
      publishableKey: supabaseAnonKey ?? '',
    );
  }
}
