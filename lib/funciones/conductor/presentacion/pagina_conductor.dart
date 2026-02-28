import 'package:flutter/material.dart';
import '../datos/repositorio_conductor.dart';
import '../servicios/gps_servicio.dart';
import '../servicios/identificador_dispositivo.dart';

class PaginaConductor extends StatefulWidget {
  const PaginaConductor({super.key});

  @override
  State<PaginaConductor> createState() => _PaginaConductorState();
}

class _PaginaConductorState extends State<PaginaConductor> {

  final RepositorioConductor _repo = RepositorioConductor();
  final GpsServicio _gps = GpsServicio();

  String? idDispositivo;

  bool cargando = true;
  bool registrado = false;
  bool gpsActivo = false;

  final TextEditingController codigoCtrl = TextEditingController();
  final TextEditingController nombreCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _verificarDispositivo();
  }

  Future<void> _verificarDispositivo() async {

    try {

      final id = await IdentificadorDispositivo.obtenerId();

      idDispositivo = id;

      final existe = await _repo.buscarDispositivo(id);

      if (existe != null) {
        registrado = true;
      }

    } catch (e) {

      debugPrint("ERROR verificando dispositivo: $e");

    }

    if (mounted) {
      setState(() {
        cargando = false;
      });
    }

  }

  Future<void> _registrar() async {

    if (codigoCtrl.text.isEmpty || nombreCtrl.text.isEmpty) {
      _mensaje("Completa todos los campos");
      return;
    }

    try {

      await _repo.registrarDispositivo(
        id: idDispositivo!,
        codigo: codigoCtrl.text,
        nombre: nombreCtrl.text,
      );

      if (mounted) {
        setState(() {
          registrado = true;
        });
      }

      _mensaje("Dispositivo registrado");

    } catch (e) {

      _mensaje("Error registrando dispositivo");

    }

  }

  void _activarGps() {

    _gps.iniciar(idDispositivo!);

    setState(() {
      gpsActivo = true;
    });

  }

  void _detenerGps() {

    _gps.detener();

    setState(() {
      gpsActivo = false;
    });

  }

  void _mensaje(String texto) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );

  }

  @override
  Widget build(BuildContext context) {

    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!registrado) {
      return _formRegistro();
    }

    return _panelGps();

  }

  Widget _formRegistro() {

    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Dispositivo")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "ID dispositivo:",
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 5),

            SelectableText(
              idDispositivo ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: codigoCtrl,
              decoration: const InputDecoration(
                labelText: "Código equipo",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                labelText: "Nombre conductor",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _registrar,
                child: const Text("Registrar dispositivo"),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _panelGps() {

    return Scaffold(
      appBar: AppBar(title: const Text("Modo Conductor")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.gps_fixed,
              size: 60,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            Text(
              "ID dispositivo",
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 5),

            Text(
              idDispositivo ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            gpsActivo
                ? ElevatedButton.icon(
              onPressed: _detenerGps,
              icon: const Icon(Icons.stop),
              label: const Text("Detener GPS"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            )
                : ElevatedButton.icon(
              onPressed: _activarGps,
              icon: const Icon(Icons.play_arrow),
              label: const Text("Activar GPS"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),

          ],
        ),
      ),
    );
  }

}