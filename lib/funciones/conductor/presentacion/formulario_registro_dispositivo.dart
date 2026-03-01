import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormularioRegistroDispositivo extends StatefulWidget {
  const FormularioRegistroDispositivo({super.key});

  @override
  State<FormularioRegistroDispositivo> createState() =>
      _FormularioRegistroDispositivoState();
}

class _FormularioRegistroDispositivoState
    extends State<FormularioRegistroDispositivo> {

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController placaController = TextEditingController();

  bool cargando = false;

  Future<void> registrar() async {
    final supabase = Supabase.instance.client;

    setState(() {
      cargando = true;
    });

    try {

      await supabase.from('equipos_control').insert({
        'nombre_conductor': nombreController.text,
        'placa': placaController.text,
        'activo': true
      });

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dispositivo registrado")),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );

    }

    setState(() {
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Dispositivo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: "Nombre conductor",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: placaController,
              decoration: const InputDecoration(
                labelText: "Placa del vehículo",
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: cargando ? null : registrar,
              child: cargando
                  ? const CircularProgressIndicator()
                  : const Text("Guardar"),
            )

          ],
        ),
      ),
    );
  }
}