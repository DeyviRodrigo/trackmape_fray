import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/core/mapas/coordenadas_operacion.dart';
import 'package:trackmape_sup/core/ui/track_custom_icons.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';
import 'package:trackmape_sup/funciones/monitoreo/dominio/servicios/servicio_metricas_operador.dart';

class PaginaStream extends StatefulWidget {
  const PaginaStream({
    super.key,
    this.equipoIdFiltro,
    this.nombreEquipoFiltro,
  });

  final String? equipoIdFiltro;
  final String? nombreEquipoFiltro;

  @override
  State<PaginaStream> createState() => _PaginaStreamState();
}

class _PaginaStreamState extends State<PaginaStream> {
  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();
  final MapController _mapController = MapController();
  static const _configMetricas = ConfiguracionMetricasOperador.porDefecto;

  static const double _zoomReferenciaMovil = 15.0;
  static const double _zoomReferenciaWeb = 15.0;
  static const double _tamanoBaseIconoMovil = 56.0;
  static const double _tamanoBaseIconoWeb = 60.0;
  static const double _tamanoBaseIconoDesktop = 58.0;
  static const double _tamanoMinimoIconoMovil = 42.0;
  static const double _tamanoMinimoIconoWeb = 46.0;
  static const double _tamanoMinimoIconoDesktop = 44.0;
  static const double _tamanoMaximoIconoMovil = 74.0;
  static const double _tamanoMaximoIconoWeb = 84.0;
  static const double _tamanoMaximoIconoDesktop = 80.0;
  static const double _tamanoBaseTextoMovil = 10.0;
  static const double _tamanoBaseTextoWeb = 10.5;
  static const double _tamanoBaseTextoDesktop = 10.5;
  static const double _tamanoMinimoTextoMovil = 8.5;
  static const double _tamanoMinimoTextoWeb = 9.0;
  static const double _tamanoMinimoTextoDesktop = 9.0;
  static const double _tamanoMaximoTextoMovil = 12.0;
  static const double _tamanoMaximoTextoWeb = 12.5;
  static const double _tamanoMaximoTextoDesktop = 12.0;

  late final Stream<List<Map<String, dynamic>>> _trayectoriaStream;
  Timer? _timerRefrescoUI;

  final Map<String, List<ll.LatLng>> _rastrosCrudos = {};
  final Map<String, Map<String, dynamic>> equiposInfo = {};
  final Map<String, ll.LatLng> _posicionAnterior = {};
  final Map<String, DateTime> _tiempoAnterior = {};
  final Map<String, double> _velocidades = {};
  final Map<String, double> _distanciasAcumuladas = {};
  final Map<String, ll.LatLng> _ultimaPosicion = {};
  final Map<String, DateTime> _ultimoTiempo = {};
  final Map<String, bool> _equipoActivo = {};

  bool _cargandoInicial = true;
  bool _mostrandoDiagnostico = false;
  double _zoomActual = 15.0;
  Future<List<Map<String, dynamic>>>? _diagnosticoFuture;

  @override
  void initState() {
    super.initState();
    _trayectoriaStream = _repositorio.obtenerTrayectoriaStream();
    _cargarDatosIniciales();
    _timerRefrescoUI = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timerRefrescoUI?.cancel();
    super.dispose();
  }

  void _abrirDiagnostico() {
    setState(() {
      _mostrandoDiagnostico = true;
      _diagnosticoFuture = _repositorio.obtenerDiagnosticoStream();
    });
  }

  void _cerrarDiagnostico() {
    setState(() {
      _mostrandoDiagnostico = false;
    });
  }

  Future<void> _cargarDatosIniciales() async {
    try {
      final equipos = await _repositorio.obtenerEquiposRaw(
        soloCodigosConPrefijoExclamacion: true,
      );
      final ultimasPosiciones = await _repositorio.obtenerUltimasPosiciones();

      if (!mounted) return;

      setState(() {
        for (final equipo in equipos) {
          final id = equipo['id_equipo_control'].toString();
          if (widget.equipoIdFiltro != null && widget.equipoIdFiltro != id) {
            continue;
          }
          equiposInfo[id] = equipo;
          _equipoActivo.putIfAbsent(id, () => false);
          _velocidades.putIfAbsent(id, () => 0.0);
          _distanciasAcumuladas.putIfAbsent(id, () => 0.0);
        }

        final ahora = DateTime.now();
        for (final pos in ultimasPosiciones) {
          _aplicarPosicion(pos, ahora, esInicial: true);
        }

        _cargandoInicial = false;
      });
    } catch (e) {
      debugPrint('Error cargando datos iniciales: $e');
      if (mounted) {
        setState(() {
          _cargandoInicial = false;
        });
      }
    }
  }

  bool _aplicarPosicion(
    Map<String, dynamic> punto,
    DateTime ahora, {
    bool esInicial = false,
  }) {
    final id = punto['fk_emisor'].toString();
    if (equiposInfo[id]?['activo'] != true) return false;

    final lat = (punto['lat_grados'] as num?)?.toDouble() ?? 0.0;
    final lon = (punto['lon_grados'] as num?)?.toDouble() ?? 0.0;

    if (lat == 0.0 || lon == 0.0) return false;
    if (lat < -20 || lat > -10 || lon < -75 || lon > -65) return false;

    final tiempoActual = DateTime.parse(punto['tiempo']);
    final posActual = ll.LatLng(lat, lon);

    final ultimoRegistrado = _ultimoTiempo[id];
    if (ultimoRegistrado != null && !tiempoActual.isAfter(ultimoRegistrado)) {
      final segundos = ahora.difference(ultimoRegistrado).inSeconds.abs();
      _equipoActivo[id] = segundos <= 60;
      return false;
    }

    _ultimaPosicion[id] = posActual;
    _ultimoTiempo[id] = tiempoActual;
    _equipoActivo[id] = ahora.difference(tiempoActual).inSeconds.abs() <= 60;

    if (!esInicial && _posicionAnterior.containsKey(id) && _tiempoAnterior.containsKey(id)) {
      final metrosTramo = _calcularDistanciaMetros(_posicionAnterior[id]!, posActual);
      final segundos = tiempoActual.difference(_tiempoAnterior[id]!).inSeconds.toDouble();

      if (metrosTramo > 2) {
        _distanciasAcumuladas[id] = (_distanciasAcumuladas[id] ?? 0) + (metrosTramo / 1000);

        if (segundos > 0) {
          _velocidades[id] = (metrosTramo / segundos) * 3.6;
        }

        _rastrosCrudos.putIfAbsent(id, () => []);
        _rastrosCrudos[id]!.add(posActual);

        if (_rastrosCrudos[id]!.length > 40) {
          _rastrosCrudos[id] = _rastrosCrudos[id]!.sublist(_rastrosCrudos[id]!.length - 40);
        }
      }
    } else {
      _rastrosCrudos.putIfAbsent(id, () => []);
      if (_rastrosCrudos[id]!.isEmpty) {
        _rastrosCrudos[id]!.add(posActual);
      }
    }

    _posicionAnterior[id] = posActual;
    _tiempoAnterior[id] = tiempoActual;
    return true;
  }

  double _calcularDistanciaMetros(ll.LatLng p1, ll.LatLng p2) {
    const double p = 0.017453292519943295;
    final double a = 0.5 -
        math.cos((p2.latitude - p1.latitude) * p) / 2 +
        math.cos(p1.latitude * p) * math.cos(p2.latitude * p) *
            (1 - math.cos((p2.longitude - p1.longitude) * p)) / 2;

    return 12742 * math.asin(math.sqrt(a)) * 1000;
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoInicial) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.orange),
              const SizedBox(height: 20),
              Text(
                'Cargando posiciones...',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;
        final cardHeight = isMobile ? 120.0 : 100.0;
        final alturaMinimaMapa = isMobile ? 320.0 : 420.0;

        return Scaffold(
          backgroundColor: Colors.black,
          body: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _trayectoriaStream,
            builder: (context, snapshot) {
          final ahora = DateTime.now();

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            for (final punto in snapshot.data!) {
              _aplicarPosicion(punto, ahora);
            }
          }

          for (final id in equiposInfo.keys) {
            final tiempo = _ultimoTiempo[id];
            if (tiempo == null) {
              _equipoActivo[id] = false;
            } else {
              _equipoActivo[id] = ahora.difference(tiempo).inSeconds.abs() <= 60;
            }
          }

          final marcadoresVisibles = <String, Marker>{};
          for (final entry in _ultimaPosicion.entries) {
            final id = entry.key;
            final posicion = entry.value;
            final estaActivo = _equipoActivo[id] ?? false;
            final color = estaActivo ? Colors.greenAccent : Colors.grey;

            marcadoresVisibles[id] = Marker(
              key: ValueKey('live_$id'),
              point: posicion,
              width: _anchoMarcador(isMobile),
              height: _altoMarcador(isMobile),
              child: _buildIconoOperador(
                id,
                color,
                isMobile: isMobile,
                zoom: _zoomActual,
              ),
            );
          }

          final polylines = <Polyline>[];
          for (final id in _rastrosCrudos.keys) {
            if ((_equipoActivo[id] ?? false) != true) continue;
            final rastro = _rastrosCrudos[id]!;
            if (rastro.length < 2) continue;

            polylines.add(
              Polyline(
                points: rastro,
                color: Colors.orange.withOpacity(0.75),
                strokeWidth: 4,
              ),
            );
          }

          final idsTarjetas = equiposInfo.keys.toList()
            ..sort((a, b) => _obtenerEtiquetaEquipo(a).compareTo(_obtenerEtiquetaEquipo(b)));
          final circulosChute = _configMetricas.puntosDescarga
              .map(
                (punto) => CircleMarker(
                  point: ll.LatLng(punto.latitud, punto.longitud),
                  radius: _configMetricas.radioChuteMetros,
                  useRadiusInMeter: true,
                  color: Colors.orange.withOpacity(0.18),
                  borderColor: Colors.orangeAccent,
                  borderStrokeWidth: 2,
                ),
              )
              .toList();
          final marcadoresChute = _configMetricas.puntosDescarga
              .asMap()
              .entries
              .map(
                (entry) => Marker(
                  point: ll.LatLng(entry.value.latitud, entry.value.longitud),
                  width: 70,
                  height: 28,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.78),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orangeAccent.withOpacity(0.9)),
                    ),
                    child: Text(
                      'Chute ${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
              .toList();

          final mapa = Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _ultimaPosicion.isNotEmpty
                      ? _ultimaPosicion.values.first
                      : puntoTrabajoLatLng,
                  initialZoom: isMobile ? 14.5 : 15,
                  onPositionChanged: (position, hasGesture) {
                    final nuevoZoom = position.zoom;
                    if (nuevoZoom == null) return;
                    if ((nuevoZoom - _zoomActual).abs() < 0.01) return;
                    setState(() {
                      _zoomActual = nuevoZoom;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                  ),
                  CircleLayer(circles: circulosChute),
                  PolylineLayer(polylines: polylines),
                  MarkerLayer(
                    markers: [
                      ...marcadoresChute,
                      ...marcadoresVisibles.values,
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.equipoIdFiltro != null) ...[
                      _buildFloatingBackButton(),
                      const SizedBox(width: 10),
                    ],
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.equipoIdFiltro != null)
                            Text(
                              widget.nombreEquipoFiltro?.trim().isNotEmpty == true
                                  ? 'Unidad: ${widget.nombreEquipoFiltro}'
                                  : 'Unidad filtrada',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          if (widget.equipoIdFiltro != null)
                            const SizedBox(height: 6),
                          _leyendaItem(
                            Colors.orange.withOpacity(0.75),
                            'GPS en vivo',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: ElevatedButton.icon(
                  onPressed: _abrirDiagnostico,
                  icon: const Icon(Icons.analytics, size: 18),
                  label: Text(isMobile ? 'Diag.' : 'Diagnostico'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.8),
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 10 : 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              if (_mostrandoDiagnostico)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.65),
                    alignment: Alignment.center,
                    child: _buildPanelDiagnostico(isMobile: isMobile),
                  ),
                ),
            ],
          );

          return Column(
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: alturaMinimaMapa),
                  child: mapa,
                ),
              ),
              SizedBox(
                height: cardHeight + (isMobile ? 12 : 20),
                child: idsTarjetas.isEmpty
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'No hay equipos disponibles',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.fromLTRB(
                          isMobile ? 10 : 15,
                          isMobile ? 4 : 8,
                          isMobile ? 10 : 15,
                          isMobile ? 8 : 12,
                        ),
                        children: idsTarjetas
                            .map((id) => _buildCardKPI(id, isMobile: isMobile))
                            .toList(),
                      ),
              ),
            ],
          );
            },
          ),
        );
      },
    );
  }

  Widget _leyendaItem(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 20, height: 3, color: color),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(color: Colors.white, fontSize: 10),
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

  Widget _buildCardKPI(String id, {bool isMobile = false}) {
    final nombre = _obtenerEtiquetaEquipo(id);
    final vel = _velocidades[id] ?? 0.0;
    final dist = _distanciasAcumuladas[id] ?? 0.0;
    final activo = _equipoActivo[id] ?? false;

    return Container(
      width: isMobile ? 180 : 170,
      margin: const EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activo ? (vel > 40 ? Colors.redAccent : Colors.green) : Colors.grey,
          width: 2,
        ),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nombre,
                  style: TextStyle(
                    color: activo ? Colors.orange : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 13 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                activo ? Icons.circle : Icons.circle_outlined,
                color: activo ? Colors.green : Colors.grey,
                size: 10,
              ),
            ],
          ),
          const SizedBox(height: 6),
          _datoFila(
            Icons.speed,
            '${vel.toStringAsFixed(1)} km/h',
            activo ? Colors.greenAccent : Colors.grey,
          ),
          _datoFila(
            Icons.route,
            '${dist.toStringAsFixed(2)} km rec.',
            activo ? Colors.cyanAccent : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _datoFila(IconData icono, String texto, Color color) {
    return Row(
      children: [
        Icon(icono, size: 14, color: color),
        const SizedBox(width: 6),
        Text(texto, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _buildIconoOperador(
    String id,
    Color color, {
    bool isMobile = false,
    required double zoom,
  }) {
    final tamanoIcono = _tamanoIconoMarcador(isMobile: isMobile, zoom: zoom);
    final tamanoTexto = _tamanoTextoMarcador(isMobile: isMobile, zoom: zoom);
    final iconoEquipo = TrackCustomIcons.iconoPorEquipo(
      nombre: equiposInfo[id]?['nombre']?.toString(),
      codigo: equiposInfo[id]?['codigo_equipo_control']?.toString(),
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 1),
          ),
          child: Text(
            _obtenerEtiquetaEquipo(id),
            style: TextStyle(
              color: Colors.white,
              fontSize: tamanoTexto,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Icon(iconoEquipo, color: color, size: tamanoIcono),
      ],
    );
  }

  double _tamanoIconoMarcador({required bool isMobile, required double zoom}) {
    if (isMobile) {
      return _tamanoProporcional(
        zoom: zoom,
        zoomReferencia: _zoomReferenciaMovil,
        base: _tamanoBaseIconoMovil,
        minimo: _tamanoMinimoIconoMovil,
        maximo: _tamanoMaximoIconoMovil,
        factorEscala: 4.0,
      );
    }

    if (kIsWeb) {
      return _tamanoProporcional(
        zoom: zoom,
        zoomReferencia: _zoomReferenciaWeb,
        base: _tamanoBaseIconoWeb,
        minimo: _tamanoMinimoIconoWeb,
        maximo: _tamanoMaximoIconoWeb,
        factorEscala: 4.5,
      );
    }

    return _tamanoProporcional(
      zoom: zoom,
      zoomReferencia: _zoomReferenciaWeb,
      base: _tamanoBaseIconoDesktop,
      minimo: _tamanoMinimoIconoDesktop,
      maximo: _tamanoMaximoIconoDesktop,
      factorEscala: 4.2,
    );
  }

  double _tamanoTextoMarcador({required bool isMobile, required double zoom}) {
    if (isMobile) {
      return _tamanoProporcional(
        zoom: zoom,
        zoomReferencia: _zoomReferenciaMovil,
        base: _tamanoBaseTextoMovil,
        minimo: _tamanoMinimoTextoMovil,
        maximo: _tamanoMaximoTextoMovil,
        factorEscala: 0.45,
      );
    }

    if (kIsWeb) {
      return _tamanoProporcional(
        zoom: zoom,
        zoomReferencia: _zoomReferenciaWeb,
        base: _tamanoBaseTextoWeb,
        minimo: _tamanoMinimoTextoWeb,
        maximo: _tamanoMaximoTextoWeb,
        factorEscala: 0.5,
      );
    }

    return _tamanoProporcional(
      zoom: zoom,
      zoomReferencia: _zoomReferenciaWeb,
      base: _tamanoBaseTextoDesktop,
      minimo: _tamanoMinimoTextoDesktop,
      maximo: _tamanoMaximoTextoDesktop,
      factorEscala: 0.48,
    );
  }

  double _tamanoProporcional({
    required double zoom,
    required double zoomReferencia,
    required double base,
    required double minimo,
    required double maximo,
    required double factorEscala,
  }) {
    final tamano = base + ((zoom - zoomReferencia) * factorEscala);
    return tamano.clamp(minimo, maximo);
  }

  double _anchoMarcador(bool isMobile) {
    final icono = _tamanoIconoMarcador(isMobile: isMobile, zoom: _zoomActual);
    return isMobile ? icono * 1.9 : icono * 2.0;
  }

  double _altoMarcador(bool isMobile) {
    final icono = _tamanoIconoMarcador(isMobile: isMobile, zoom: _zoomActual);
    return isMobile ? icono * 1.75 : icono * 1.8;
  }

  String _obtenerEtiquetaEquipo(String id) {
    final nombre = equiposInfo[id]?['nombre']?.toString().trim() ?? '';
    if (nombre.isNotEmpty) return nombre;

    final codigo = equiposInfo[id]?['codigo_equipo_control']?.toString().trim() ?? '';
    if (codigo.isNotEmpty) return codigo;

    return 'Unidad';
  }

  Widget _buildPanelDiagnostico({bool isMobile = false}) {
    return Container(
      width: isMobile ? double.infinity : 820,
      constraints: BoxConstraints(
        maxWidth: isMobile ? 520 : 820,
        maxHeight: isMobile ? 560 : 620,
      ),
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Diagnostico de Unidades',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _diagnosticoFuture = _repositorio.obtenerDiagnosticoStream();
                  });
                },
                icon: const Icon(Icons.refresh, color: Colors.orange),
              ),
              IconButton(
                onPressed: _cerrarDiagnostico,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Estado por unidad: ok, sin dato, sin match, coordenada invalida o sin codigo.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _diagnosticoFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  );
                }

                final items = snapshot.data!;
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final nombre = (item['nombre']?.toString().trim().isNotEmpty ?? false)
                        ? item['nombre'].toString()
                        : item['codigo_equipo_control']?.toString() ?? 'Unidad';
                    final estado = item['estado']?.toString() ?? 'desconocido';
                    final detalle = item['detalle']?.toString() ?? '';
                    final color = _colorEstadoDiagnostico(estado);
                    final iconoEquipo = TrackCustomIcons.iconoPorEquipo(
                      nombre: item['nombre']?.toString(),
                      codigo: item['codigo_equipo_control']?.toString(),
                    );

                    return ListTile(
                      leading: Icon(iconoEquipo, color: color),
                      title: Text(
                        nombre,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${item['codigo_equipo_control'] ?? 'Sin codigo'}\n$detalle',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color),
                        ),
                        child: Text(
                          estado,
                          style: TextStyle(color: color, fontWeight: FontWeight.bold),
                        ),
                      ),
                      isThreeLine: true,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _colorEstadoDiagnostico(String estado) {
    switch (estado) {
      case 'ok':
        return Colors.greenAccent;
      case 'sin_dato_reciente':
        return Colors.grey;
      case 'sin_dato':
        return Colors.orangeAccent;
      case 'sin_match':
        return Colors.redAccent;
      case 'coordenada_invalida':
        return Colors.deepOrangeAccent;
      case 'sin_codigo':
        return Colors.amber;
      default:
        return Colors.white70;
    }
  }
}
