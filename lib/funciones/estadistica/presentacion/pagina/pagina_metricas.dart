import 'package:flutter/material.dart';

class PaginaMetricas extends StatelessWidget {
  const PaginaMetricas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: const Center(
        child: Text("Hoja de Estadísticas y Velocidad",
            style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}