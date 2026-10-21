import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app2/aplicacion/aplicacion_trackmape.dart';
import 'app2/conexion_backend/supabase/arranque/cargador_variables_entorno.dart';
import 'app2/conexion_backend/supabase/arranque/inicializacion_supabase.dart';
import 'app2/errores/gestion_errores_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GestionErroresApp.inicializar();
  await CargadorVariablesEntorno.cargar();
  await InicializacionSupabase.init();

  runApp(const ProviderScope(child: AplicacionTrackMAPE()));
}
