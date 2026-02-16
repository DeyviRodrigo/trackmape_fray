import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';
import 'package:trackmape_sup/core/utilidades/calculadora_geodesica.dart';

class PaginaHistorico extends StatefulWidget {
  const PaginaHistorico({super.key});

  @override
  State<PaginaHistorico> createState() => _PaginaHistoricoState();
}

class _PaginaHistoricoState extends State<PaginaHistorico> {
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

              // Cargar mapa de códigos (V01, J01, etc)
              final listaEquipos = snapshot.data![0] as List<Map<String, dynamic>>;
              for (var e in listaEquipos) {
                mapaCodigos[e['id_equipo_control'].toString()] = e['codigo_equipo_control'] ?? "S/N";
              }

              // Trayectoria cruda
              final trayectoriaRaw = snapshot.data![1] as List<Map<String, dynamic>>;

              // --- SOLUCIÓN AL DESORDEN DE COORDENADAS ---
              // 1. Clonamos la lista para no mutar el original
              List<Map<String, dynamic>> trayectoria = List.from(trayectoriaRaw);
              // 2. Ordenamos por tiempo de forma ascendente
              trayectoria.sort((a, b) => a['tiempo'].compareTo(b['tiempo']));

              return FlutterMap(
                options: MapOptions(
                  initialCenter: const ll.LatLng(-14.671137, -69.478404),
                  initialZoom: 15,
                  onTap: (_, __) => setState(() => puntoSeleccionado = null),
                ),
                children: [
                  TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}'),
                  // Dibujar las líneas de ruta ordenadas
                  PolylineLayer(polylines: _generarLineas(trayectoria)),
                  // Dibujar los iconos de los equipos
                  MarkerLayer(markers: _construirMarcadores(trayectoria)),
                ],
              );
            },
          ),

          // Etiqueta de Fecha Superior
          Positioned(
            top: 20, left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
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

  void _seleccionarPunto(Map<String, dynamic> actual, List<Map<String, dynamic>> historialCompleto) {
    setState(() {
      puntoSeleccionado = actual;
      DateTime hora = DateTime.parse(actual['tiempo']);
      Duration diff = DateTime.now().difference(hora);
      tiempoReporte = diff.inMinutes > 60 ? "${diff.inHours}h ${diff.inMinutes % 60}m" : "${diff.inMinutes} min";

      // Filtramos historial del equipo específico y aseguramos que esté ordenado para calcular velocidad
      final historialEmisor = historialCompleto.where((p) => p['fk_emisor'] == actual['fk_emisor']).toList();
      historialEmisor.sort((a, b) => a['tiempo'].compareTo(b['tiempo']));

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
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100), // Subido para no tapar el bottom nav
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
                Text("UNIDAD: ${mapaCodigos[puntoSeleccionado!['fk_emisor'].toString()] ?? 'S/N'}",
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
                _dato("Tiempo", tiempoReporte, color: Colors.blueAccent),
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
    Map<String, Marker> marcadoresUltimaPosicion = {};

    // Al estar 'datos' ordenado por tiempo, el último que procesemos de cada ID será el más reciente
    for (var pos in datos) {
      String id = pos['fk_emisor'].toString();

      marcadoresUltimaPosicion[id] = Marker(
        point: ll.LatLng((pos['lat_grados'] as num).toDouble(), (pos['lon_grados'] as num).toDouble()),
        width: 65, height: 65,
        child: GestureDetector(
          onTap: () => _seleccionarPunto(pos, datos),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange, width: 0.5)
                ),
                child: Text(mapaCodigos[id] ?? "...",
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.local_shipping, color: Colors.orange, size: 26),
            ],
          ),
        ),
      );
    }
    return marcadoresUltimaPosicion.values.toList();
  }

  List<Polyline> _generarLineas(List<Map<String, dynamic>> pos) {
    Map<String, List<ll.LatLng>> rutasPorEquipo = {};

    for (var p in pos) {
      String id = p['fk_emisor'].toString();
      rutasPorEquipo.putIfAbsent(id, () => []);
      rutasPorEquipo[id]!.add(ll.LatLng((p['lat_grados'] as num).toDouble(), (p['lon_grados'] as num).toDouble()));
    }

    return rutasPorEquipo.entries.map((e) => Polyline(
        points: e.value,
        color: Colors.orange.withOpacity(0.4),
        strokeWidth: 3
    )).toList();
  }
}