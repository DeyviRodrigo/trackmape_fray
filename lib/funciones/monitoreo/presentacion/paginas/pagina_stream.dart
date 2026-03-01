import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/core/mapas/graphhopper/graphhopper_map_matching.dart';
import 'dart:math' as math;
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';

class PaginaStream extends StatefulWidget {
  const PaginaStream({super.key});

  @override
  State<PaginaStream> createState() => _PaginaStreamState();
}

class _PaginaStreamState extends State<PaginaStream> {
  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();

  // ============================================
  // 🗺️ GRAPHHOPPER MAP MATCHING
  // ============================================
  final GraphhopperMapMatching _mapMatching = GraphhopperMapMatching();

  // Información de equipos y estados de telemetría
  Map<String, Map<String, dynamic>> equiposInfo = {};
  Map<String, ll.LatLng> _posicionAnterior = {};
  Map<String, DateTime> _tiempoAnterior = {};
  Map<String, double> _velocidades = {};
  Map<String, double> _distanciasAcumuladas = {};

  // Rastros sin corregir (para mostrar mientras se procesa)
  Map<String, List<ll.LatLng>> _rastrosOriginales = {};

  @override
  void initState() {
    super.initState();
    _preCargarDatos();
  }

  @override
  void dispose() {
    _mapMatching.limpiarTodo();
    super.dispose();
  }

  // Carga inicial de nombres de equipos y estados de habilitación
  Future<void> _preCargarDatos() async {
    final resultados = await _repositorio.obtenerEquiposRaw();
    if (mounted) {
      setState(() {
        for (var e in resultados) {
          equiposInfo[e['id_equipo_control'].toString()] = e;
        }
      });
    }
  }

  // --- FUNCIÓN PARA CALCULAR DISTANCIA (Fórmula Haversine corregida) ---
  double _calcularDistanciaMetros(ll.LatLng p1, ll.LatLng p2) {
    const double p = 0.017453292519943295; // math.pi / 180
    final double a = 0.5 -
        math.cos((p2.latitude - p1.latitude) * p) / 2 +
        math.cos(p1.latitude * p) * math.cos(p2.latitude * p) *
            (1 - math.cos((p2.longitude - p1.longitude) * p)) / 2;

    return 12742 * math.asin(math.sqrt(a)) * 1000; // Resultado en metros
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _repositorio.obtenerTrayectoriaStream(),
        builder: (context, snapshot) {
          Map<String, Marker> marcadoresVisibles = {};
          final ahora = DateTime.now();

          if (snapshot.hasData) {
            for (var punto in snapshot.data!) {
              final id = punto['fk_emisor'].toString();

              // Filtro: Solo mostrar si el operador está habilitado en la base de datos
              if (equiposInfo[id]?['habilitado'] != true) continue;

              final posActual = ll.LatLng(
                (punto['lat_grados'] as num).toDouble(),
                (punto['lon_grados'] as num).toDouble(),
              );
              final tiempoActual = DateTime.parse(punto['tiempo']);

              // --- CÁLCULO DE TELEMETRÍA (Velocidad y Distancia) ---
              if (_posicionAnterior.containsKey(id)) {
                double metrosTramo = _calcularDistanciaMetros(_posicionAnterior[id]!, posActual);

                // Evitamos ruido del GPS (solo contamos movimientos > 2 metros)
                if (metrosTramo > 2) {
                  _distanciasAcumuladas[id] = (_distanciasAcumuladas[id] ?? 0) + (metrosTramo / 1000);

                  double segundos = tiempoActual.difference(_tiempoAnterior[id]!).inSeconds.toDouble();
                  if (segundos > 0) {
                    _velocidades[id] = (metrosTramo / segundos) * 3.6; // Convertir m/s a km/h
                  }
                }
              }

              // Guardar estado para el siguiente cálculo
              _posicionAnterior[id] = posActual;
              _tiempoAnterior[id] = tiempoActual;

              // ============================================
              // 📍 AGREGAR PUNTO AL MAP MATCHING
              // ============================================
              _mapMatching.agregarPunto(id, posActual);

              // También mantener rastro original para visualización inmediata
              _rastrosOriginales.putIfAbsent(id, () => []);
              _rastrosOriginales[id]!.add(posActual);
              if (_rastrosOriginales[id]!.length > 50) {
                _rastrosOriginales[id]!.removeAt(0);
              }

              // --- CREACIÓN DE MARCADORES ---
              bool esPuntoActivo = ahora.difference(tiempoActual).inSeconds.abs() <= 60;

              marcadoresVisibles[id] = Marker(
                key: ValueKey("live_${id}_${punto['tiempo']}"),
                point: posActual,
                width: 80, height: 80,
                child: _buildIconoOperador(id, esPuntoActivo ? Colors.greenAccent : Colors.grey),
              );
            }
          }

          // ============================================
          // 🗺️ CONSTRUIR POLILÍNEAS
          // ============================================
          List<Polyline> polylines = [];

          for (final entry in _rastrosOriginales.entries) {
            final id = entry.key;

            // Obtener ruta corregida si existe, sino usar original
            List<ll.LatLng> puntosParaMostrar = _mapMatching.obtenerRutaCorregida(id);

            if (puntosParaMostrar.isEmpty) {
              puntosParaMostrar = entry.value;
            }

            if (puntosParaMostrar.length >= 2) {
              polylines.add(
                Polyline(
                  points: puntosParaMostrar,
                  color: Colors.greenAccent.withOpacity(0.8),
                  strokeWidth: 5,
                ),
              );
            }
          }

          return Stack(
            children: [
              FlutterMap(
                options: const MapOptions(
                  initialCenter: ll.LatLng(-14.6792, -69.4866),
                  initialZoom: 16,
                ),
                children: [
                  // ============================================
                  // 🗺️ CAPA 1: MAPA SATELITAL (FONDO)
                  // ============================================
                  TileLayer(
                    urlTemplate: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                  ),

                  // ============================================
                  // 📍 CAPA 2: POLILÍNEAS (RUTAS)
                  // ============================================
                  PolylineLayer(
                    polylines: polylines,
                  ),

                  // ============================================
                  // 🚗 CAPA 3: MARCADORES (VEHÍCULOS)
                  // ============================================
                  MarkerLayer(markers: marcadoresVisibles.values.toList()),
                ],
              ),

              // --- PANEL INFERIOR DE DATOS EN TIEMPO REAL ---
              Positioned(
                bottom: 20, left: 0, right: 0,
                child: SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    children: marcadoresVisibles.keys.map((id) => _buildCardKPI(id)).toList(),
                  ),
                ),
              ),

              // ============================================
              // 📊 INDICADOR DE GRAPHHOPPER (opcional)
              // ============================================
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.route, color: Colors.greenAccent, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'GraphHopper',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Tarjeta de datos por cada operador
  Widget _buildCardKPI(String id) {
    final nombre = equiposInfo[id]?['codigo_equipo_control'] ?? "Unidad";
    final vel = _velocidades[id] ?? 0.0;
    final dist = _distanciasAcumuladas[id] ?? 0.0;

    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: vel > 40 ? Colors.redAccent : Colors.orange, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(nombre, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          _datoFila(Icons.speed, "${vel.toStringAsFixed(1)} km/h", Colors.greenAccent),
          _datoFila(Icons.route, "${dist.toStringAsFixed(2)} km rec.", Colors.cyanAccent),
        ],
      ),
    );
  }

  Widget _datoFila(IconData icono, String texto, Color color) {
    return Row(
      children: [
        Icon(icono, size: 14, color: color),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildIconoOperador(String id, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color, width: 1)
          ),
          child: Text(
            equiposInfo[id]?['codigo_equipo_control'] ?? "",
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        Icon(Icons.local_shipping, color: color, size: 38),
      ],
    );
  }
}