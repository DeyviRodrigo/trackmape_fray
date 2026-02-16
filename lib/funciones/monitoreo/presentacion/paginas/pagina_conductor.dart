import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaginaConductor extends StatefulWidget {
  const PaginaConductor({super.key});

  @override
  State<PaginaConductor> createState() => _PaginaConductorState();
}

class _PaginaConductorState extends State<PaginaConductor> {
  final supabase = Supabase.instance.client;

  bool cargando = true;
  bool equipoRegistrado = false;
  bool gpsActivo = false;

  String? deviceId;

  final codigoController = TextEditingController();
  final nombreController = TextEditingController();

  Timer? _timerEnvio;

  // =====================
  // INIT
  // =====================
  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    try {
      deviceId = await _obtenerIdDispositivo();
      await _verificarEquipo();
    } catch (e) {
      print("ERROR inicializar: $e");
      setState(() => cargando = false);
    }
  }

  // =====================
  // ID DISPOSITIVO
  // =====================
  Future<String> _obtenerIdDispositivo() async {
    final info = DeviceInfoPlugin();
    final androidInfo = await info.androidInfo;

    return androidInfo.id;
  }

  // =====================
  // VERIFICAR EQUIPO
  // =====================
  Future<void> _verificarEquipo() async {
    final response = await supabase
        .from('equipos_control')
        .select()
        .eq('id_equipo_control', deviceId!)
        .maybeSingle();

    setState(() {
      equipoRegistrado = response != null;
      cargando = false;
    });
  }

  // =====================
  // REGISTRAR EQUIPO
  // =====================
  Future<void> _registrarEquipo() async {
    setState(() => cargando = true);

    await supabase.from('equipos_control').insert({
      'id_equipo_control': deviceId,
      'fk_sede': 'MINA', // valor temporal
      'codigo_equipo_control': codigoController.text,
      'nombre_equipo_control': nombreController.text,
      'habilitado': true,
    });

    setState(() {
      equipoRegistrado = true;
      cargando = false;
    });
  }

  // =====================
  // ACTIVAR GPS
  // =====================
  Future<void> _activarGPS() async {
    bool permiso = await _solicitarPermisos();
    if (!permiso) return;

    setState(() => gpsActivo = true);

    _timerEnvio =
        Timer.periodic(const Duration(seconds: 5), (_) => _enviarPosicion());
  }

  void _desactivarGPS() {
    _timerEnvio?.cancel();
    setState(() => gpsActivo = false);
  }

  // =====================
  // PERMISOS
  // =====================
  Future<bool> _solicitarPermisos() async {
    LocationPermission permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    return permiso == LocationPermission.always ||
        permiso == LocationPermission.whileInUse;
  }

  // =====================
  // ENVIAR POSICIÓN
  // =====================
  Future<void> _enviarPosicion() async {
    final posicion = await Geolocator.getCurrentPosition();

    await supabase.from('posiciones').insert({
      'id_equipo_control': deviceId,
      'latitud': posicion.latitude,
      'longitud': posicion.longitude,
      'velocidad': posicion.speed,
      'fecha': DateTime.now().toIso8601String(),
    });
  }

  // =====================
  // UI
  // =====================
  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!equipoRegistrado) {
      return _formularioRegistro();
    }

    return _panelConductor();
  }

  // =====================
  // FORMULARIO
  // =====================
  Widget _formularioRegistro() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("Registrar equipo",
              style: TextStyle(fontSize: 20)),

          TextField(
            controller: codigoController,
            decoration:
            const InputDecoration(labelText: "Código equipo"),
          ),

          TextField(
            controller: nombreController,
            decoration:
            const InputDecoration(labelText: "Nombre equipo"),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _registrarEquipo,
            child: const Text("Registrar"),
          )
        ],
      ),
    );
  }

  // =====================
  // PANEL CONDUCTOR
  // =====================
  Widget _panelConductor() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            gpsActivo ? "GPS ACTIVO" : "GPS DETENIDO",
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: gpsActivo ? _desactivarGPS : _activarGPS,
            child: Text(gpsActivo ? "Detener" : "Activar GPS"),
          ),
        ],
      ),
    );
  }
}
