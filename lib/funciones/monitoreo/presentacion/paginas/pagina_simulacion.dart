import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/core/mapas/coordenadas_operacion.dart';
import 'package:trackmape_sup/core/ui/track_custom_icons.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';

class HojaSimulacion extends StatefulWidget {
  const HojaSimulacion({super.key});

  @override
  State<HojaSimulacion> createState() => _HojaSimulacionState();
}

class _HojaSimulacionState extends State<HojaSimulacion> {
  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();

  DateTime _fechaSimulacion = DateTime.now();
  List<Map<String, dynamic>> _datosHistoricos = [];
  int _puntero = 0;
  bool _reproduciendo = false;
  double _velocidad = 1.0;
  Timer? _timerSimulacion;
  bool _cargando = false;
  bool _estabaReproduciendoDuranteArrastre = false;
  ll.LatLng _centroInicial = puntoTrabajoLatLng;

  Map<String, Map<String, dynamic>> equiposInfo = {};
  Map<String, Marker> marcadoresActivos = {};
  Map<String, List<ll.LatLng>> rastrosCola = {};
  final Map<String, _EstadoSimulacionEquipo> _estadoActualEquipos = {};
  final Map<String, _ResumenSimulacionEquipo> _resumenesDiaPorEquipo = {};
  final Map<String, ll.LatLng> _ultimaPosicionEquipo = {};
  final Map<String, DateTime> _ultimoTiempoEquipo = {};
  String? _equipoSeleccionadoId;

  // Retorna milisegundos según velocidad
  int _obtenerIntervalo(double velocidad) {
    switch (velocidad) {
      case 1.0: return 800;
      case 2.0: return 400;
      case 4.0: return 200;
      case 10.0: return 80;
      default: return 800;
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos(_fechaSimulacion);
  }

  Future<void> _cargarDatos(DateTime fecha) async {
    _timerSimulacion?.cancel();
    setState(() {
      _fechaSimulacion = fecha;
      _cargando = true;
      _reproduciendo = false;
      _puntero = 0;
      _datosHistoricos = [];
      equiposInfo.clear();
      marcadoresActivos.clear();
      rastrosCola.clear();
      _estadoActualEquipos.clear();
      _resumenesDiaPorEquipo.clear();
      _ultimaPosicionEquipo.clear();
      _ultimoTiempoEquipo.clear();
      _equipoSeleccionadoId = null;
    });

    final resultados = await Future.wait([
      _repositorio.obtenerEquiposRaw(),
      _repositorio.obtenerTrayectoriaPorFecha(fecha),
      _repositorio.obtenerUltimasPosiciones(),
    ]);

    final equipos = resultados[0];
    final trayectoria = resultados[1];
    final ultimasPosiciones = resultados[2];

    setState(() {
      for (final equipo in equipos) {
        equiposInfo[equipo['id_equipo_control'].toString()] = equipo;
      }
      _datosHistoricos = trayectoria;
      _resumenesDiaPorEquipo.addAll(_calcularResumenesDia(trayectoria));
      _puntero = 0;
      _centroInicial = _resolverCentroInicial(trayectoria, ultimasPosiciones);
      _cargando = false;
    });

    if (_datosHistoricos.isNotEmpty) {
      _reanudar();
    }
  }

  void _arrancarMotores() {
    _timerSimulacion?.cancel();
    if (_datosHistoricos.isEmpty || !_reproduciendo) return;

    _timerSimulacion = Timer.periodic(
      Duration(milliseconds: _obtenerIntervalo(_velocidad)),
          (_) {
        if (_datosHistoricos.isEmpty || !_reproduciendo) return;

        if (_puntero >= _datosHistoricos.length) {
          _puntero = 0;
          rastrosCola.clear();
        }

    final punto = _datosHistoricos[_puntero];
    _procesarPunto(punto);

        setState(() {
          _puntero++;
          if (_puntero >= _datosHistoricos.length) {
            _puntero = 0;
            rastrosCola.clear();
          }
        });
      },
    );
  }

  void _procesarPunto(Map<String, dynamic> punto) {
    final id = punto['fk_emisor'].toString();
    if (equiposInfo[id]?['activo'] != true) return;

    final lat = (punto['lat_grados'] as num).toDouble();
    final lon = (punto['lon_grados'] as num).toDouble();
    final pos = ll.LatLng(
      lat,
      lon,
    );
    final tiempoActual = _parsearFechaHora(punto['tiempo']);
    final posicionAnterior = _ultimaPosicionEquipo[id];
    final tiempoAnterior = _ultimoTiempoEquipo[id];

    var velocidadKmh = 0.0;
    var distanciaMetros = 0.0;
    var deltaSegundos = 0;

    if (posicionAnterior != null && tiempoAnterior != null && tiempoActual != null) {
      distanciaMetros = _calcularDistanciaMetros(posicionAnterior, pos);
      deltaSegundos = tiempoActual.difference(tiempoAnterior).inSeconds;
      if (deltaSegundos > 0) {
        velocidadKmh = (distanciaMetros / deltaSegundos) * 3.6;
      }
    }

    setState(() {
      final resumenDia = _resumenesDiaPorEquipo[id] ?? const _ResumenSimulacionEquipo();
      marcadoresActivos[id] = Marker(
        key: ValueKey('sim_${id}_$_puntero'),
        point: pos,
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _equipoSeleccionadoId = id;
            });
          },
          child: _buildIcono(id),
        ),
      );

      rastrosCola.putIfAbsent(id, () => []);
      rastrosCola[id]!.add(pos);
      if (rastrosCola[id]!.length > 15) {
        rastrosCola[id]!.removeAt(0);
      }

      _estadoActualEquipos[id] = _EstadoSimulacionEquipo(
        id: id,
        nombre: _obtenerEtiquetaEquipo(id),
        latitud: lat,
        longitud: lon,
        tiempo: tiempoActual,
        velocidadKmh: velocidadKmh,
        distanciaMetros: distanciaMetros,
        deltaSegundos: deltaSegundos,
        velocidadPromedioDiaKmh: resumenDia.velocidadPromedioKmh,
        kilometrosDia: resumenDia.kilometros,
        tramosValidosDia: resumenDia.tramosValidos,
        registro: Map<String, dynamic>.from(punto),
      );

      _ultimaPosicionEquipo[id] = pos;
      if (tiempoActual != null) {
        _ultimoTiempoEquipo[id] = tiempoActual;
      }
    });
  }

  Map<String, _ResumenSimulacionEquipo> _calcularResumenesDia(
    List<Map<String, dynamic>> trayectoria,
  ) {
    final porEquipo = <String, List<Map<String, dynamic>>>{};

    for (final punto in trayectoria) {
      final id = punto['fk_emisor']?.toString();
      if (id == null || id.isEmpty) continue;

      final lat = (punto['lat_grados'] as num?)?.toDouble();
      final lon = (punto['lon_grados'] as num?)?.toDouble();
      final tiempo = _parsearFechaHora(punto['tiempo']);

      if (lat == null || lon == null || tiempo == null) continue;
      if (lat == 0.0 || lon == 0.0) continue;
      if (lat < -20 || lat > -10 || lon < -75 || lon > -65) continue;

      porEquipo.putIfAbsent(id, () => []);
      porEquipo[id]!.add(punto);
    }

    final resumenes = <String, _ResumenSimulacionEquipo>{};

    for (final entry in porEquipo.entries) {
      final puntos = [...entry.value]
        ..sort((a, b) => a['tiempo'].toString().compareTo(b['tiempo'].toString()));

      double kilometros = 0.0;
      double sumaVelocidades = 0.0;
      int tramosValidos = 0;

      for (var i = 1; i < puntos.length; i++) {
        final anterior = puntos[i - 1];
        final actual = puntos[i];

        final tiempoAnterior = _parsearFechaHora(anterior['tiempo']);
        final tiempoActual = _parsearFechaHora(actual['tiempo']);
        if (tiempoAnterior == null || tiempoActual == null) continue;

        final deltaSegundos = tiempoActual.difference(tiempoAnterior).inSeconds;
        if (deltaSegundos <= 0) continue;

        final p1 = ll.LatLng(
          (anterior['lat_grados'] as num).toDouble(),
          (anterior['lon_grados'] as num).toDouble(),
        );
        final p2 = ll.LatLng(
          (actual['lat_grados'] as num).toDouble(),
          (actual['lon_grados'] as num).toDouble(),
        );

        final distanciaMetros = _calcularDistanciaMetros(p1, p2);
        final velocidadKmh = (distanciaMetros / deltaSegundos) * 3.6;

        if (velocidadKmh.isNaN || velocidadKmh.isInfinite) continue;
        if (velocidadKmh > 120) continue;

        kilometros += distanciaMetros / 1000;
        sumaVelocidades += velocidadKmh;
        tramosValidos++;
      }

      resumenes[entry.key] = _ResumenSimulacionEquipo(
        kilometros: kilometros,
        velocidadPromedioKmh:
            tramosValidos == 0 ? 0.0 : (sumaVelocidades / tramosValidos),
        tramosValidos: tramosValidos,
      );
    }

    return resumenes;
  }

  void _togglePlay() {
    if (_reproduciendo) {
      _pausar();
    } else {
      _reanudar();
    }
  }

  void _pausar() {
    _timerSimulacion?.cancel();
    setState(() {
      _reproduciendo = false;
    });
  }

  void _reanudar() {
    if (_datosHistoricos.isEmpty) return;
    setState(() {
      _reproduciendo = true;
    });
    _arrancarMotores();
  }

  void _retroceder() {
    if (_datosHistoricos.isEmpty) return;
    setState(() {
      _puntero = math.max(0, _puntero - 20);
      rastrosCola.clear();
    });
  }

  void _avanzar() {
    if (_datosHistoricos.isEmpty) return;
    setState(() {
      _puntero = math.min(_datosHistoricos.length - 1, _puntero + 20);
    });
  }

  void _cambiarVelocidad(double v) {
    if (_velocidad == v) return;
    setState(() {
      _velocidad = v;
    });
    if (_reproduciendo) {
      _arrancarMotores();
    }
  }

  Future<void> _seleccionarFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaSimulacion,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orange,
              onPrimary: Color(0xFF06329C),
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (seleccionada != null && !_esMismaFecha(seleccionada, _fechaSimulacion)) {
      await _cargarDatos(seleccionada);
    }
  }

  String _horaActual() {
    if (_datosHistoricos.isEmpty) return '00:00:00';
    final indice = _puntero.clamp(0, _datosHistoricos.length - 1);
    final crudo = _datosHistoricos[indice]['tiempo'];
    DateTime? fechaHora;

    if (crudo is DateTime) {
      fechaHora = crudo;
    } else if (crudo != null) {
      fechaHora = DateTime.tryParse(crudo.toString());
    }

    return fechaHora == null ? '00:00:00' : DateFormat('HH:mm:ss').format(fechaHora);
  }

  String _etiquetaVelocidad() {
    switch (_velocidad) {
      case 1.0:
        return '1x';
      case 2.0:
        return '2x';
      case 4.0:
        return '4x';
      case 10.0:
        return '10x';
      default:
        return '${_velocidad}x';
    }
  }

  bool _esMismaFecha(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    _timerSimulacion?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _datosHistoricos.length;
    final sliderMax = total > 1 ? (total - 1).toDouble() : 1.0;
    final sliderValue = total > 0
        ? _puntero.clamp(0, total - 1).toDouble()
        : 0.0;

    return Scaffold(
      backgroundColor: Color(0xFF06329C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Simulación en tiempo real'),
        actions: [
          InkWell(
            onTap: _seleccionarFecha,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Text(DateFormat('yyyy-MM-dd').format(_fechaSimulacion)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _centroInicial,
                    initialZoom: MediaQuery.of(context).size.width < 760 ? 14.5 : 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                    ),
                    PolylineLayer(
                      polylines: rastrosCola.entries
                          .map(
                            (e) => Polyline(
                          points: e.value,
                          color: Colors.greenAccent.withValues(alpha: 0.7),
                          strokeWidth: 4,
                        ),
                      )
                          .toList(),
                    ),
                    MarkerLayer(markers: marcadoresActivos.values.toList()),
                  ],
                ),
              ),
              _buildPanelInferior(total, sliderValue, sliderMax, MediaQuery.of(context).size.width < 760),
            ],
          ),
          if (_equipoSeleccionado != null)
            Positioned(
              top: 16,
              left: MediaQuery.of(context).size.width < 760 ? 12 : null,
              right: 16,
              child: _buildPanelEquipoSeleccionado(
                _equipoSeleccionado!,
                width: (MediaQuery.of(context).size.width - 28)
                    .clamp(260.0, 420.0)
                    .toDouble(),
              ),
            ),
          if (_cargando)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.55),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPanelInferior(
    int total,
    double sliderValue,
    double sliderMax,
    bool isMobile,
  ) {
    return Container(
      color: const Color(0xE61A1A1A),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 6,
            children: [
              IconButton(
                onPressed: _retroceder,
                icon: const Icon(Icons.fast_rewind),
              ),
              IconButton(
                onPressed: _togglePlay,
                icon: Icon(_reproduciendo ? Icons.pause : Icons.play_arrow),
                style: IconButton.styleFrom(
                  foregroundColor: Colors.orange,
                  iconSize: 30,
                ),
              ),
              IconButton(
                onPressed: _avanzar,
                icon: const Icon(Icons.fast_forward),
              ),
              const SizedBox(width: 8),
              const Text('Velocidad'),
              const SizedBox(width: 8),
              DropdownButton<double>(
                value: _velocidad,
                dropdownColor: const Color(0xFF06329C),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 1.0, child: Text('1x')),
                  DropdownMenuItem(value: 2.0, child: Text('2x')),
                  DropdownMenuItem(value: 4.0, child: Text('4x')),
                  DropdownMenuItem(value: 10.0, child: Text('10x')),
                ],
                onChanged: (v) {
                  if (v != null) _cambiarVelocidad(v);
                },
              ),
              if (!isMobile) const Spacer(),
              Padding(
                padding: EdgeInsets.only(left: isMobile ? 0 : 8),
                child: Text(
                  _horaActual(),
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text('00:00', style: TextStyle(fontSize: 12)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.orange,
                    inactiveTrackColor: Colors.orange.withValues(alpha: 0.25),
                    thumbColor: Colors.orange,
                    overlayColor: Colors.orange.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: sliderValue,
                    min: 0,
                    max: sliderMax,
                    onChangeStart: (_) {
                      _estabaReproduciendoDuranteArrastre = _reproduciendo;
                      _pausar();
                    },
                    onChanged: (value) {
                      if (_datosHistoricos.isEmpty) return;
                      setState(() {
                        _puntero = value.round().clamp(0, _datosHistoricos.length - 1);
                        rastrosCola.clear();
                      });
                      _procesarPunto(_datosHistoricos[_puntero]);
                    },
                    onChangeEnd: (_) {
                      if (_estabaReproduciendoDuranteArrastre) {
                        _reanudar();
                      }
                      _estabaReproduciendoDuranteArrastre = false;
                    },
                  ),
                ),
              ),
              const Text('23:59', style: TextStyle(fontSize: 12)),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${total == 0 ? 0 : (_puntero.clamp(0, total - 1) + 1)} / $total registros (${_etiquetaVelocidad()})',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcono(String id) {
    final nombre = _obtenerEtiquetaEquipo(id);
    final seleccionado = _equipoSeleccionadoId == id;
    final iconoEquipo = TrackCustomIcons.iconoPorEquipo(
      nombre: equiposInfo[id]?['nombre']?.toString(),
      codigo: equiposInfo[id]?['codigo_equipo_control']?.toString(),
    );
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF06329C),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: seleccionado ? Colors.orange : Colors.greenAccent,
              width: seleccionado ? 2 : 1,
            ),
          ),
          child: Text(
            nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Icon(iconoEquipo, color: Colors.greenAccent, size: 35),
      ],
    );
  }

  _EstadoSimulacionEquipo? get _equipoSeleccionado {
    final id = _equipoSeleccionadoId;
    if (id == null) return null;
    return _estadoActualEquipos[id];
  }

  Widget _buildPanelEquipoSeleccionado(
    _EstadoSimulacionEquipo estado, {
    double width = 320,
  }) {
    final tiempo = estado.tiempo == null
        ? '--:--:--'
        : DateFormat('HH:mm:ss').format(estado.tiempo!);
    final iconoEquipo = TrackCustomIcons.iconoPorEquipo(
      nombre: equiposInfo[estado.id]?['nombre']?.toString(),
      codigo: equiposInfo[estado.id]?['codigo_equipo_control']?.toString(),
    );

    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 6,
            children: [
              Icon(iconoEquipo, color: Colors.greenAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  estado.nombre,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _equipoSeleccionadoId = null;
                  });
                },
                icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _datoPanel('Hora actual', tiempo, Colors.orangeAccent),
                    _datoPanel(
                      'Velocidad',
                      '${estado.velocidadKmh.toStringAsFixed(1)} km/h',
                      Colors.greenAccent,
                    ),
                    _datoPanel(
                      'Tramo actual',
                      '${estado.distanciaMetros.toStringAsFixed(1)} m',
                      Colors.cyanAccent,
                    ),
                    _datoPanel(
                      'Delta tiempo',
                      '${estado.deltaSegundos}s',
                      Colors.white,
                    ),
                    _datoPanel(
                      'Lat / Lon',
                      '${estado.latitud.toStringAsFixed(6)}, ${estado.longitud.toStringAsFixed(6)}',
                      Colors.white70,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _datoPanel(
                      'Vel. promedio dia',
                      '${estado.velocidadPromedioDiaKmh.toStringAsFixed(1)} km/h',
                      Colors.amberAccent,
                    ),
                    _datoPanel(
                      'Km recorridos dia',
                      '${estado.kilometrosDia.toStringAsFixed(2)} km',
                      Colors.lightBlueAccent,
                    ),
                    _datoPanel(
                      'Tramos validos dia',
                      '${estado.tramosValidosDia}',
                      Colors.white70,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _datoPanel(String etiqueta, String valor, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _obtenerEtiquetaEquipo(String id) {
    final nombre = equiposInfo[id]?['nombre']?.toString().trim() ?? '';
    if (nombre.isNotEmpty) return nombre;

    final codigo = equiposInfo[id]?['codigo_equipo_control']?.toString().trim() ?? '';
    if (codigo.isNotEmpty) return codigo;

    return id;
  }

  ll.LatLng _resolverCentroInicial(
    List<Map<String, dynamic>> trayectoria,
    List<Map<String, dynamic>> ultimasPosiciones,
  ) {
    final puntoTrayectoria = _primerPuntoValido(trayectoria);
    if (puntoTrayectoria != null) return puntoTrayectoria;

    final puntoStream = _primerPuntoValido(ultimasPosiciones);
    if (puntoStream != null) return puntoStream;

    return puntoTrabajoLatLng;
  }

  ll.LatLng? _primerPuntoValido(List<Map<String, dynamic>> puntos) {
    for (final punto in puntos) {
      final lat = (punto['lat_grados'] as num?)?.toDouble() ?? 0.0;
      final lon = (punto['lon_grados'] as num?)?.toDouble() ?? 0.0;

      if (lat == 0.0 || lon == 0.0) continue;
      if (lat < -20 || lat > -10 || lon < -75 || lon > -65) continue;

      return ll.LatLng(lat, lon);
    }

    return null;
  }

  DateTime? _parsearFechaHora(dynamic valor) {
    if (valor is DateTime) return valor;
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString());
  }

  double _calcularDistanciaMetros(ll.LatLng p1, ll.LatLng p2) {
    const double p = 0.017453292519943295;
    final double a = 0.5 -
        math.cos((p2.latitude - p1.latitude) * p) / 2 +
        math.cos(p1.latitude * p) *
            math.cos(p2.latitude * p) *
            (1 - math.cos((p2.longitude - p1.longitude) * p)) / 2;

    return 12742 * math.asin(math.sqrt(a)) * 1000;
  }
}

class _EstadoSimulacionEquipo {
  const _EstadoSimulacionEquipo({
    required this.id,
    required this.nombre,
    required this.latitud,
    required this.longitud,
    required this.tiempo,
    required this.velocidadKmh,
    required this.distanciaMetros,
    required this.deltaSegundos,
    required this.velocidadPromedioDiaKmh,
    required this.kilometrosDia,
    required this.tramosValidosDia,
    required this.registro,
  });

  final String id;
  final String nombre;
  final double latitud;
  final double longitud;
  final DateTime? tiempo;
  final double velocidadKmh;
  final double distanciaMetros;
  final int deltaSegundos;
  final double velocidadPromedioDiaKmh;
  final double kilometrosDia;
  final int tramosValidosDia;
  final Map<String, dynamic> registro;
}

class _ResumenSimulacionEquipo {
  const _ResumenSimulacionEquipo({
    this.kilometros = 0.0,
    this.velocidadPromedioKmh = 0.0,
    this.tramosValidos = 0,
  });

  final double kilometros;
  final double velocidadPromedioKmh;
  final int tramosValidos;
}
