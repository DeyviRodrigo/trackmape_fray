import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'funciones/navegacion/presentacion/contenedor_principal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yrovlzezlxalcidoiakf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlyb3ZsemV6bHhhbGNpZG9pYWtmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2MTEyNTUsImV4cCI6MjA4NTE4NzI1NX0.hpQYhuqhVxYiWxlJFXPS5SZYENS3Uo7CUMRLjtb9x28',
  );

  runApp(const AplicacionTrackMAPE());
}

class AplicacionTrackMAPE extends StatelessWidget {
  const AplicacionTrackMAPE({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackMAPE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const ContenedorPrincipal(),
    );
  }
}