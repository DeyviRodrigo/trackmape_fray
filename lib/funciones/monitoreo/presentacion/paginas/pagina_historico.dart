import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/core/mapas/coordenadas_operacion.dart';
import 'package:trackmape_sup/core/utilidades/limpiador_trayectoria.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';

class PaginaHistorico extends StatefulWidget {
  const PaginaHistorico({
    super.key,
    this.equipoIdFiltro,
    this.nombreEquipoFiltro,
  });

  final String? equipoIdFiltro;
  final String? nombreEquipoFiltro;

  @override
  State<PaginaHistorico> createState() => _PaginaHistoricoState();
}

class _PaginaHistoricoState extends State<PaginaHistorico> {
  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();
  final LimpiadorTrayectoria _limpiador = const LimpiadorTrayectoria();

  final Map<String, String> mapaEtiquetasEquipos = {};

  DateTime fechaSeleccionada = DateTime.now();
  Map<String, dynamic>? puntoSeleccionado;
  double velocidadCalc = 0.0;
  String tiempoReporte = '';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;

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
              mapaEtiquetasEquipos.clear();
              for (final equipo in listaEquipos) {
                final id = equipo['id_equipo_control'].toString();
                final nombre = equipo['nombre']?.toString().trim() ?? '';
                final codigo =
                    equipo['codigo_equipo_control']?.toString().trim() ?? '';
                mapaEtiquetasEquipos[id] = nombre.isNotEmpty
                    ? nombre
                    : (codigo.isNotEmpty ? codigo : 'S/N');
              }

              final trayectoriaRaw =
                  snapshot.data![1] as List<Map<String, dynamic>>;
              final trayectoria = _filtrarDatosValidos(
                widget.equipoIdFiltro == null
                    ? trayectoriaRaw
                    : trayectoriaRaw
                        .where(
                          (punto) =>
                              punto['fk_emisor']?.toString() ==
                              widget.equipoIdFiltro,
                        )
                        .toList(),
              )
                ..sort((a, b) => a['tiempo'].compareTo(b['tiempo']));

              return FlutterMap(
                options: MapOptions(
                  initialCenter: puntoTrabajoLatLng,
                  initialZoom: isMobile ? 14.5 : 15,
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
            right: isMobile ? 84 : null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.equipoIdFiltro != null) ...[
                  _buildFloatingBackButton(),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Text(
                      widget.equipoIdFiltro == null
                          ? 'Fecha: ${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}'
                          : 'Fecha: ${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year} | ${widget.nombreEquipoFiltro ?? 'Unidad'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (puntoSeleccionado != null) _buildPanelInfo(isMobile: isMobile),
        ],
      ),
        );
      },
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
        velocidadCalc = _limpiador.velocidadKmh(
          _mapToPunto(anterior),
          _mapToPunto(actual),
        );
      } else {
        velocidadCalc = 0.0;
      }
    });
  }

  Widget _buildPanelInfo({bool isMobile = false}) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'UNIDAD: ${mapaEtiquetasEquipos[puntoSeleccionado!['fk_emisor'].toString()] ?? 'S/N'}',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => setState(() => puntoSeleccionado = null),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 16,
              runSpacing: 10,
              children: [
                _dato('Lat (X)', puntoSeleccionado!['lat_grados'].toString()),
                _dato('Lon (Y)', puntoSeleccionado!['lon_grados'].toString()),
                _dato('Alt (Z)', '${puntoSeleccionado!['alt_msnm'] ?? 'N/A'}m'),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 16,
              runSpacing: 10,
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

  Widget _buildFloatingBackButton() {
    return Material(
      color: Colors.black.withOpacity(0.82),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.75)),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.orange),
        ),
      ),
    );
  }

  List<Marker> _construirMarcadores(List<Map<String, dynamic>> datos) {
    final marcadoresUltimaPosicion = <String, Marker>{};
    final datosPorEquipo = <String, List<Map<String, dynamic>>>{};

    for (final pos in datos) {
      final id = pos['fk_emisor'].toString();
      datosPorEquipo.putIfAbsent(id, () => []);
      datosPorEquipo[id]!.add(pos);
    }

    for (final entry in datosPorEquipo.entries) {
      final id = entry.key;
      final limpieza = _limpiarPuntos(entry.value);
      final limpios = limpieza.puntos.map((punto) => punto.payload).toList();
      final pos = limpios.isNotEmpty ? limpios.last : null;
      if (pos == null) {
        continue;
      }

      marcadoresUltimaPosicion[id] = Marker(
        point: ll.LatLng(
          (pos['lat_grados'] as num).toDouble(),
          (pos['lon_grados'] as num).toDouble(),
        ),
        width: 65,
        height: 65,
        child: GestureDetector(
          onTap: () => _seleccionarPunto(pos, limpios),
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
                  mapaEtiquetasEquipos[id] ?? '...',
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

      final limpieza = _limpiarPuntos(puntosOrdenados);
      final segmentos = _segmentarRutaValida(limpieza.segmentos);

      for (final segmento in segmentos) {
        if (segmento.length < 2) {
          continue;
        }

        polilineas.add(
          Polyline(
            points: segmento,
            color: Colors.orange.withOpacity(0.7),
            strokeWidth: 4,
          ),
        );
      }
    }

    return polilineas;
  }

  ResultadoLimpiezaTrayectoria<Map<String, dynamic>> _limpiarPuntos(
    List<Map<String, dynamic>> puntos,
  ) {
    final convertidos = puntos
        .where(_esPuntoUsable)
        .map(_mapToPunto)
        .toList();

    return _limpiador.limpiar(convertidos);
  }

  List<List<ll.LatLng>> _segmentarRutaValida(
    List<List<PuntoTrayectoria<Map<String, dynamic>>>> segmentos,
  ) {
    return segmentos
        .map(
          (segmento) => segmento
              .map((punto) => ll.LatLng(punto.latitud, punto.longitud))
              .toList(),
        )
        .toList();
  }

  bool _esPuntoUsable(Map<String, dynamic> punto) {
    final lat = (punto['lat_grados'] as num?)?.toDouble();
    final lon = (punto['lon_grados'] as num?)?.toDouble();
    final tiempo = DateTime.tryParse(punto['tiempo']?.toString() ?? '');

    return lat != null &&
        lon != null &&
        tiempo != null &&
        _limpiador.coordenadaEsValida(lat, lon);
  }

  PuntoTrayectoria<Map<String, dynamic>> _mapToPunto(Map<String, dynamic> punto) {
    return PuntoTrayectoria<Map<String, dynamic>>(
      latitud: (punto['lat_grados'] as num).toDouble(),
      longitud: (punto['lon_grados'] as num).toDouble(),
      tiempo: DateTime.parse(punto['tiempo']),
      payload: punto,
    );
  }
}
