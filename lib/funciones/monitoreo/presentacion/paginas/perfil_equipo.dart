import 'package:flutter/material.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/modelos/modelo_equipo.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';

class PaginaPerfilEquipo extends StatefulWidget {
  final ModeloEquipo equipo;
  const PaginaPerfilEquipo({super.key, required this.equipo});

  @override
  State<PaginaPerfilEquipo> createState() => _PaginaPerfilEquipoState();
}

class _PaginaPerfilEquipoState extends State<PaginaPerfilEquipo> {
  final _repositorio = RepositorioMonitoreo();
  late TextEditingController _nombreCtrl;
  late TextEditingController _codigoCtrl;
  late bool _habilitado;

  @override
  void initState() {
    super.initState();
    // Usamos los nombres exactos de tu modelo: nombre y codigo
    _nombreCtrl = TextEditingController(text: widget.equipo.nombre);
    _codigoCtrl = TextEditingController(text: widget.equipo.codigo);
    _habilitado = widget.equipo.habilitado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Editar Perfil"), backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const CircleAvatar(radius: 45, backgroundColor: Colors.orange, child: Icon(Icons.person, size: 50, color: Colors.black)),
            const SizedBox(height: 30),
            TextField(
              controller: _nombreCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Nombre", labelStyle: TextStyle(color: Colors.orange)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codigoCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Código (V01, etc)", labelStyle: TextStyle(color: Colors.orange)),
            ),
            const SizedBox(height: 30),
            SwitchListTile(
              title: const Text("Habilitar Operador", style: TextStyle(color: Colors.white)),
              value: _habilitado,
              activeColor: Colors.orange,
              onChanged: (val) => setState(() => _habilitado = val),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 50)),
              onPressed: () async {
                // Enviamos los cambios a Supabase usando el ID correcto
                final exito = await _repositorio.actualizarEquipo(widget.equipo.id, {
                  'nombre_equipo_control': _nombreCtrl.text,
                  'codigo_equipo_control': _codigoCtrl.text,
                  'habilitado': _habilitado,
                });
                if (exito && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil Actualizado")));
                }
              },
              child: const Text("GUARDAR CAMBIOS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}