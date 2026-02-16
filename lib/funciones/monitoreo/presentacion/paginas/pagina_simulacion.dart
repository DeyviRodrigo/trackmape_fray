import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'dart:async';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';

class HojaSimulacion extends StatefulWidget {
  const HojaSimulacion({super.key});

  @override
  State<HojaSimulacion> createState() => _HojaSimulacionState();
}

class _HojaSimulacionState extends State<HojaSimulacion> {
  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();

  List<Map<String, dynamic>> _datosHistoricos = [];
  int _puntero = 0;
  Timer? _timerSimulacion;

  Map<String, Map<String, dynamic>> equiposInfo = {};
  Map<String, Marker> marcadoresActivos = {};
  Map<String, List<ll.LatLng>> rastrosCola = {};

  @override
  void initState() {
    super.initState();
    _iniciarTodo();
  }

  Future<void> _iniciarTodo() async {
    // FECHA DE SIMULACIÓN: Cambia esta fecha por el día que quieres mostrar
    final DateTime fechaSimulacion = DateTime(2026, 1, 15);

    final resultados = await Future.wait([
      _repositorio.obtenerEquiposRaw(),
      _repositorio.obtenerTrayectoriaPorFecha(fechaSimulacion),
    ]);

    setState(() {
      for (var e in resultados[0]) {
        equiposInfo[e['id_equipo_control'].toString()] = e;
      }
      _datosHistoricos = resultados[1] as List<Map<String, dynamic>>;
    });

    if (_datosHistoricos.isNotEmpty) {
      _arrancarMotores();
    }
  }

  void _arrancarMotores() {
    _timerSimulacion?.cancel();
    // Velocidad de simulación: 1 punto cada 800ms
    _timerSimulacion = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_puntero >= _datosHistoricos.length) {
        _puntero = 0; // LOOP INFINITO: Vuelve a empezar si se acaba el día
        rastrosCola.clear(); // Limpiamos rastros para el reinicio
      }

      final punto = _datosHistoricos[_puntero];
      final id = punto['fk_emisor'].toString();

      // FILTRO: Solo si está habilitado en la hoja de Operadores
      if (equiposInfo[id]?['habilitado'] == true) {
        final pos = ll.LatLng(
            (punto['lat_grados'] as num).toDouble(),
            (punto['lon_grados'] as num).toDouble()
        );

        setState(() {
          // Marcador Verde con Key única para forzar el movimiento
          marcadoresActivos[id] = Marker(
            key: ValueKey("sim_${id}_$_puntero"),
            point: pos,
            width: 80, height: 80,
            child: _buildIcono(id),
          );

          // Rastro de 15 puntos (colita)
          rastrosCola.putIfAbsent(id, () => []);
          rastrosCola[id]!.add(pos);
          if (rastrosCola[id]!.length > 15) rastrosCola[id]!.removeAt(0);
        });
      }
      _puntero++;
    });
  }

  @override
  void dispose() {
    _timerSimulacion?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: ll.LatLng(-14.6792, -69.4866),
        initialZoom: 15,
      ),
      children: [
        TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}'),
        PolylineLayer(
          polylines: rastrosCola.entries.map((e) => Polyline(
            points: e.value,
            color: Colors.greenAccent.withValues(alpha: 0.7),
            strokeWidth: 4,
          )).toList(),
        ),
        MarkerLayer(markers: marcadoresActivos.values.toList()),
      ],
    );
  }

  Widget _buildIcono(String id) {
    String nombre = equiposInfo[id]?['codigo_equipo_control'] ?? "V-09";
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.greenAccent),
          ),
          child: Text(nombre, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const Icon(Icons.local_shipping, color: Colors.greenAccent, size: 35),
      ],
    );
  }
}