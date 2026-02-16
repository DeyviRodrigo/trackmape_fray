import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';
import 'package:trackmape_sup/core/utilidades/calculadora_geodesica.dart';

class PaginaMapa extends StatefulWidget {
  const PaginaMapa({super.key});

  @override
  State<PaginaMapa> createState() => _PaginaMapaState();
}

class _PaginaMapaState extends State<PaginaMapa> {
  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();
  Map<String, String> mapaCodigos = {};

  DateTime fechaSeleccionada = DateTime.now();
  Map<String, dynamic>? puntoSeleccionado;
  double velocidadCalc = 0.0;
  String tiempoReporte = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.calendar_month, color: Colors.black),
        onPressed: () async {
          DateTime? picker = await showDatePicker(
            context: context,
            initialDate: fechaSeleccionada,
            firstDate: DateTime(2025),
            lastDate: DateTime.now(),
          );
          if (picker != null) {
            setState(() {
              fechaSeleccionada = picker;
              puntoSeleccionado = null;
            });
          }
        },
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: Future.wait([
              _repositorio.obtenerEquiposRaw(),
              _repositorio.obtenerTrayectoriaPorFecha(fechaSeleccionada),
            ]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.orange));

              final listaEquipos = snapshot.data![0] as List<Map<String, dynamic>>;
              for (var e in listaEquipos) {
                mapaCodigos[e['id_equipo_control'].toString()] = e['codigo_equipo_control'] ?? "S/N";
              }

              final trayectoria = snapshot.data![1] as List<Map<String, dynamic>>;

              return FlutterMap(
                options: MapOptions(
                  initialCenter: const ll.LatLng(-15.488288, -70.149287),
                  initialZoom: 15,
                  onTap: (_, __) => setState(() => puntoSeleccionado = null),
                ),
                children: [
                  TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}'),
                  PolylineLayer(polylines: _generarLineas(trayectoria)),
                  MarkerLayer(markers: _construirMarcadores(trayectoria)),
                ],
              );
            },
          ),

          // Indicador de fecha
          Positioned(
            top: 50, left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange),
              ),
              child: Text(
                "Fecha: ${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          if (puntoSeleccionado != null) _buildPanelInfo(),
        ],
      ),
    );
  }

  void _seleccionarPunto(Map<String, dynamic> actual, List<Map<String, dynamic>> historial) {
    setState(() {
      puntoSeleccionado = actual;
      DateTime hora = DateTime.parse(actual['tiempo']);
      Duration diff = DateTime.now().difference(hora);
      tiempoReporte = diff.inMinutes > 60 ? "${diff.inHours}h ${diff.inMinutes % 60}m" : "${diff.inMinutes} min";

      final historialEmisor = historial.where((p) => p['fk_emisor'] == actual['fk_emisor']).toList();
      int idx = historialEmisor.indexOf(actual);

      if (idx > 0) {
        final anterior = historialEmisor[idx - 1];
        velocidadCalc = CalculadoraGeodesica.calcularVelocidad(
          (anterior['lat_grados'] as num).toDouble(),
          (anterior['lon_grados'] as num).toDouble(),
          DateTime.parse(anterior['tiempo']),
          (actual['lat_grados'] as num).toDouble(),
          (actual['lon_grados'] as num).toDouble(),
          DateTime.parse(actual['tiempo']),
        );
      } else {
        velocidadCalc = 0.0;
      }
    });
  }

  Widget _buildPanelInfo() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.orange, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("UNIDAD: ${mapaCodigos[puntoSeleccionado!['fk_emisor']] ?? 'S/N'}",
                    style: const TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => setState(() => puntoSeleccionado = null),
                )
              ],
            ),
            const Divider(color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dato("Lat (X)", puntoSeleccionado!['lat_grados'].toString()),
                _dato("Lon (Y)", puntoSeleccionado!['lon_grados'].toString()),
                _dato("Alt (Z)", "${puntoSeleccionado!['alt_msnm']}m"),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dato("Velocidad", "${velocidadCalc.toStringAsFixed(1)} km/h", color: Colors.greenAccent),
                _dato("Reportado hace", tiempoReporte, color: Colors.blueAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dato(String t, String v, {Color color = Colors.white}) => Column(
    children: [
      Text(t, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      Text(v, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    ],
  );

  List<Marker> _construirMarcadores(List<Map<String, dynamic>> datos) {
    Map<String, Marker> marcadores = {};
    for (var pos in datos.reversed) {
      String id = pos['fk_emisor'].toString();
      if (marcadores.containsKey(id)) continue;

      marcadores[id] = Marker(
        point: ll.LatLng((pos['lat_grados'] as num).toDouble(), (pos['lon_grados'] as num).toDouble()),
        width: 65, height: 65,
        child: GestureDetector(
          onTap: () => _seleccionarPunto(pos, datos),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange, width: 0.5)
                ),
                child: Text(mapaCodigos[id] ?? "...", style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.local_shipping, color: Colors.orange, size: 26),
            ],
          ),
        ),
      );
    }
    return marcadores.values.toList();
  }

  List<Polyline> _generarLineas(List<Map<String, dynamic>> pos) {
    Map<String, List<ll.LatLng>> rutas = {};
    for (var p in pos) {
      String id = p['fk_emisor'].toString();
      rutas.putIfAbsent(id, () => []);
      rutas[id]!.add(ll.LatLng((p['lat_grados'] as num).toDouble(), (p['lon_grados'] as num).toDouble()));
    }
    return rutas.entries.map((e) => Polyline(
        points: e.value,
        color: Colors.orange.withValues(alpha: 0.4),
        strokeWidth: 3
    )).toList();
  }
}