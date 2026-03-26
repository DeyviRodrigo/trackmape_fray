import 'package:flutter/material.dart';

class PaginaInforme extends StatefulWidget {
  const PaginaInforme({super.key});

  @override
  State<PaginaInforme> createState() => _PaginaInformeState();
}

class _PaginaInformeState extends State<PaginaInforme> {
  final _textoControlador = TextEditingController();
  String _tipoIncidencia = 'Mantenimiento';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Registrar Reporte de Turno",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Selector de tipo de incidencia
            DropdownButtonFormField<String>(
              value: _tipoIncidencia,
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle("Tipo de Reporte"),
              items: ['Mantenimiento', 'Producción', 'Incidente', 'Clima']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _tipoIncidencia = val!),
            ),

            const SizedBox(height: 15),

            // Campo de descripción
            TextField(
              controller: _textoControlador,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle("Descripción del suceso"),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Aquí conectaremos con Supabase más adelante
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Reporte guardado localmente"))
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("ENVIAR REPORTE",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.orange),
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
    );
  }
}