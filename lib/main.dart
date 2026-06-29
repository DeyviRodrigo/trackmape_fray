import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/tokens/tokens_sistema.dart';
import 'funciones/navegacion/presentacion/contenedor_principal.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env');
  }

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);

  runApp(const AplicacionTrackMAPE());
}

class AplicacionTrackMAPE extends StatelessWidget {
  const AplicacionTrackMAPE({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackMAPE',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _TrackScrollBehavior(),
      theme: TemaBase.oscuro(),
      home: const ContenedorPrincipal(),
    );
  }
}

class _TrackScrollBehavior extends MaterialScrollBehavior {
  const _TrackScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}
