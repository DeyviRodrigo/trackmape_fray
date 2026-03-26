import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/core/utilidades/calculadora_geodesica.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';

class PaginaHistorico extends StatefulWidget {
  const PaginaHistorico({super.key});

  @override
  State<PaginaHistorico> createState() => _PaginaHistoricoState();
}

class _PaginaHistoricoState extends State<PaginaHistorico> {
  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();

  final Map<String, String> mapaCodigos = {};

  DateTime fechaSeleccionada = DateTime.now();
  Map<String, dynamic>? puntoSeleccionado;
  double velocidadCalc = 0.0;
  String tiempoReporte = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'calendar',
        backgroundColor: Colors.orange,
        child: const Icon(Icons.calendar_month, color: Colors.black),
        onPressed: () async {
          final picker = await showDatePicker(
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
          FutureBuilder<List<dynamic>>(
            future: Future.wait([
              _repositorio.obtenerEquiposRaw(),
              _repositorio.obtenerTrayectoriaPorFecha(fechaSeleccionada),
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                );
              }

              final listaEquipos =
                  snapshot.data![0] as List<Map<String, dynamic>>;
              mapaCodigos.clear();
              for (final equipo in listaEquipos) {
                mapaCodigos[equipo['id_equipo_control'].toString()] =
                    equipo['codigo_equipo_control']?.toString() ?? 'S/N';
              }

              final trayectoriaRaw =
                  snapshot.data![1] as List<Map<String, dynamic>>;
              final trayectoria = _filtrarDatosValidos(trayectoriaRaw)
                ..sort((a, b) => a['tiempo'].compareTo(b['tiempo']));

              return FlutterMap(
                options: MapOptions(
                  initialCenter: const ll.LatLng(-15.488405, -70.150497),
                  initialZoom: 15,
                  onTap: (_, __) => setState(() => puntoSeleccionado = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                  ),
                  PolylineLayer(polylines: _generarLineas(trayectoria)),
                  MarkerLayer(markers: _construirMarcadores(trayectoria)),
                ],
              );
            },
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange),
              ),
              child: Text(
                'Fecha: ${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (puntoSeleccionado != null) _buildPanelInfo(),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filtrarDatosValidos(List<Map<String, dynamic>> datos) {
    final datosFiltrados = <Map<String, dynamic>>[];

    for (final punto in datos) {
      final lat = (punto['lat_grados'] as num?)?.toDouble() ?? 0.0;
      final lon = (punto['lon_grados'] as num?)?.toDouble() ?? 0.0;

      if (lat == 0.0 || lon == 0.0) continue;
      if (lat < -90 || lat > 90) continue;
      if (lon < -180 || lon > 180) continue;
      if (lat < -20 || lat > -10) continue;
      if (lon < -75 || lon > -65) continue;

      datosFiltrados.add(punto);
    }

    return datosFiltrados;
  }

  void _seleccionarPunto(
    Map<String, dynamic> actual,
    List<Map<String, dynamic>> historialCompleto,
  ) {
    setState(() {
      puntoSeleccionado = actual;

      final hora = DateTime.parse(actual['tiempo']);
      final diff = DateTime.now().difference(hora);
      tiempoReporte = diff.inMinutes > 60
          ? '${diff.inHours}h ${diff.inMinutes % 60}m'
          : '${diff.inMinutes} min';

      final historialEmisor = historialCompleto
          .where((p) => p['fk_emisor'] == actual['fk_emisor'])
          .toList()
        ..sort((a, b) => a['tiempo'].compareTo(b['tiempo']));

      final idx = historialEmisor.indexOf(actual);
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
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF06329C),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.orange, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'UNIDAD: ${mapaCodigos[puntoSeleccionado!['fk_emisor'].toString()] ?? 'S/N'}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => setState(() => puntoSeleccionado = null),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dato('Lat (X)', puntoSeleccionado!['lat_grados'].toString()),
                _dato('Lon (Y)', puntoSeleccionado!['lon_grados'].toString()),
                _dato('Alt (Z)', '${puntoSeleccionado!['alt_msnm'] ?? 'N/A'}m'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dato(
                  'Velocidad',
                  '${velocidadCalc.toStringAsFixed(1)} km/h',
                  color: Colors.greenAccent,
                ),
                _dato('Tiempo', tiempoReporte, color: Colors.blueAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dato(String t, String v, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(t, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        Text(
          v,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  List<Marker> _construirMarcadores(List<Map<String, dynamic>> datos) {
    final marcadoresUltimaPosicion = <String, Marker>{};

    for (final pos in datos) {
      final id = pos['fk_emisor'].toString();
      marcadoresUltimaPosicion[id] = Marker(
        point: ll.LatLng(
          (pos['lat_grados'] as num).toDouble(),
          (pos['lon_grados'] as num).toDouble(),
        ),
        width: 65,
        height: 65,
        child: GestureDetector(
          onTap: () => _seleccionarPunto(pos, datos),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange, width: 0.5),
                ),
                child: Text(
                  mapaCodigos[id] ?? '...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.local_shipping,
                color: Color(0xFF06329C),
                size: 26,
              ),
            ],
          ),
        ),
      );
    }

    return marcadoresUltimaPosicion.values.toList();
  }

  List<Polyline> _generarLineas(List<Map<String, dynamic>> pos) {
    final datosPorEquipo = <String, List<Map<String, dynamic>>>{};

    for (final punto in pos) {
      final id = punto['fk_emisor'].toString();
      datosPorEquipo.putIfAbsent(id, () => []);
      datosPorEquipo[id]!.add(punto);
    }

    final polilineas = <Polyline>[];

    for (final entry in datosPorEquipo.entries) {
      final puntosOrdenados = [...entry.value]
        ..sort((a, b) => a['tiempo'].compareTo(b['tiempo']));

      final ruta = <ll.LatLng>[];
      for (final punto in puntosOrdenados) {
        ruta.add(
          ll.LatLng(
            (punto['lat_grados'] as num).toDouble(),
            (punto['lon_grados'] as num).toDouble(),
          ),
        );
      }

      if (ruta.length >= 2) {
        polilineas.add(
          Polyline(
            points: ruta,
            color: Colors.orange.withOpacity(0.7),
            strokeWidth: 4,
          ),
        );
      }
    }

    return polilineas;
  }
}
