import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'funciones/navegacion/presentacion/contenedor_principal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mwcbxpacxacpfanmgxiw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im13Y2J4cGFjeGFjcGZhbm1neGl3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1ODkwNTg1NSwiZXhwIjoyMDc0NDgxODU1fQ.BrJcx5d5mozvnRuioONqnStIkgTFGoMwSYnkKG6ESYo',
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