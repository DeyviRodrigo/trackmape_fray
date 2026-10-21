/// Responsabilidad: Inicializar el cliente Supabase con las variables de
/// entorno publicas ya cargadas por CargadorVariablesEntorno.
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trackmape_sup/app2/conexion_backend/supabase/arranque/claves_entorno.dart';

// INICIALIZACION SUPABASE - Arranca el cliente Supabase con las claves publicas
class InicializacionSupabase {
  // INIT - Inicializa Supabase con la URL y la clave publica del entorno
  static Future<void> init() async {
    final supabaseUrl = dotenv.env[ClavesEntorno.supabaseUrl];
    final supabaseAnonKey = dotenv.env[ClavesEntorno.supabaseAnonKey];

    await Supabase.initialize(
      url: supabaseUrl ?? '',
      publishableKey: supabaseAnonKey ?? '',
    );
  }
}
