import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'dart:async';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';

class HojaSimulacion extends StatefulWidget {
  const HojaSimulacion({super.key});

  @override
  State<HojaSimulacion> createState() => _HojaSimulacionState();
}

class _HojaSimulacionState extends State<HojaSimulacion> {
  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();

  // --- Control de reproducción ---
  DateTime _fechaSimulacion = DateTime(2026, 1, 15);
  List<Map<String, dynamic>> _datosHistoricos = [];
  int _puntero = 0;
  bool _reproduciendo = false;
  double _velocidad = 1.0;
  Timer? _timerSimulacion;
  bool _cargando = false;

  // --- Mapa ---
  Map<String, Map<String, dynamic>> equiposInfo = {};
  Map<String, Marker> marcadoresActivos = {};
  Map<String, List<ll.LatLng>> rastrosCola = {};

  // Velocidades disponibles con sus intervalos en ms
  static const Map<double, int> _velocidades = {
    1.0: 800,
    2.0: 400,
    4.0: 200,
    10.0: 80,
  };

  @override
  void initState() {
    super.initState();
    _cargarDatos(_fechaSimulacion);
  }

  Future<void> _cargarDatos(DateTime fecha) async {
    _timerSimulacion?.cancel();
    setState(() {
      _cargando = true;
      _reproduciendo = false;
      _puntero = 0;
      marcadoresActivos.clear();
      rastrosCola.clear();
      _datosHistoricos = [];
    });

    final resultados = await Future.wait([
      _repositorio.obtenerEquiposRaw(),
      _repositorio.obtenerTrayectoriaPorFecha(fecha),
    ]);

    if (!mounted) return;

    setState(() {
      equiposInfo.clear();
      for (var e in resultados[0]) {
        equiposInfo[e['id_equipo_control'].toString()] = e;
      }
      _datosHistoricos = resultados[1] as List<Map<String, dynamic>>;
      _cargando = false;
    });

    if (_datosHistoricos.isNotEmpty) {
      _iniciarReproduccion();
    }
  }

  void _iniciarReproduccion() {
    setState(() => _reproduciendo = true);
    _arrancarMotores();
  }

  void _arrancarMotores() {
    _timerSimulacion?.cancel();
    if (!_reproduciendo || _datosHistoricos.isEmpty) return;

    final ms = _velocidades[_velocidad] ?? 800;
    _timerSimulacion = Timer.periodic(Duration(milliseconds: ms), (_) {
      if (!mounted) return;
      if (_puntero >= _datosHistoricos.length) {
        setState(() {
          _puntero = 0;
          rastrosCola.clear();
        });
        return;
      }
      _procesarPunto(_datosHistoricos[_puntero]);
      setState(() => _puntero++);
    });
  }

  void _procesarPunto(Map<String, dynamic> punto) {
    final id = punto['fk_emisor'].toString();
    if (equiposInfo[id]?['habilitado'] != true) return;

    final pos = ll.LatLng(
      (punto['lat_grados'] as num).toDouble(),
      (punto['lon_grados'] as num).toDouble(),
    );

    setState(() {
      marcadoresActivos[id] = Marker(
        key: ValueKey('sim_${id}_$_puntero'),
        point: pos,
        width: 80,
        height: 80,
        child: _buildIcono(id),
      );

      rastrosCola.putIfAbsent(id, () => []);
      rastrosCola[id]!.add(pos);
      if (rastrosCola[id]!.length > 15) rastrosCola[id]!.removeAt(0);
    });
  }

  void _togglePlay() {
    if (_datosHistoricos.isEmpty) return;
    setState(() => _reproduciendo = !_reproduciendo);
    if (_reproduciendo) {
      _arrancarMotores();
    } else {
      _timerSimulacion?.cancel();
    }
  }

  void _pausar() {
    _timerSimulacion?.cancel();
    setState(() => _reproduciendo = false);
  }

  void _reanudar() {
    if (_datosHistoricos.isEmpty) return;
    setState(() => _reproduciendo = true);
    _arrancarMotores();
  }

  void _retroceder() {
    _timerSimulacion?.cancel();
    setState(() {
      _puntero = math.max(0, _puntero - 20);
      rastrosCola.clear();
      marcadoresActivos.clear();
    });
    if (_reproduciendo) _arrancarMotores();
  }

  void _avanzar() {
    _timerSimulacion?.cancel();
    setState(() {
      _puntero = math.min(
        _datosHistoricos.isEmpty ? 0 : _datosHistoricos.length - 1,
        _puntero + 20,
      );
    });
    if (_reproduciendo) _arrancarMotores();
  }

  void _cambiarVelocidad(double nuevaVelocidad) {
    setState(() => _velocidad = nuevaVelocidad);
    if (_reproduciendo) _arrancarMotores();
  }

  Future<void> _seleccionarFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaSimulacion,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.orange,
            onPrimary: Colors.black,
            surface: Color(0xFF1E1E1E),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (seleccionada != null && seleccionada != _fechaSimulacion) {
      setState(() => _fechaSimulacion = seleccionada);
      await _cargarDatos(seleccionada);
    }
  }

  String _horaActual() {
    if (_datosHistoricos.isEmpty || _puntero >= _datosHistoricos.length) {
      return '--:--:--';
    }
    final t = DateTime.parse(_datosHistoricos[_puntero]['tiempo']);
    return DateFormat('HH:mm:ss').format(t);
  }

  String _etiquetaVelocidad() {
    final v = _velocidad.truncateToDouble() == _velocidad
        ? _velocidad.toInt().toString()
        : _velocidad.toString();
    return '${v}x';
  }

  @override
  void dispose() {
    _timerSimulacion?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: _seleccionarFecha,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('EEE, d MMM yyyy', 'es').format(_fechaSimulacion),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.calendar_today_outlined,
                  color: Colors.orange, size: 18),
            ],
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // --- MAPA ---
          FlutterMap(
            options: const MapOptions(
              initialCenter: ll.LatLng(-14.6792, -69.4866),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
              ),
              PolylineLayer(
                polylines: rastrosCola.entries
                    .map((e) => Polyline(
                          points: e.value,
                          color: Colors.greenAccent.withValues(alpha: 0.7),
                          strokeWidth: 4,
                        ))
                    .toList(),
              ),
              MarkerLayer(markers: marcadoresActivos.values.toList()),
            ],
          ),

          // --- LOADING OVERLAY ---
          if (_cargando)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando datos de\n${DateFormat('d MMM yyyy', 'es').format(_fechaSimulacion)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          // --- PANEL INFERIOR DE CONTROL ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xE61A1A1A),
                border: Border(
                  top: BorderSide(color: Colors.orange, width: 1),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Fila 1: Controles de reproducción
                  Row(
                    children: [
                      // Retroceder 20 puntos
                      IconButton(
                        icon: const Icon(Icons.fast_rewind,
                            color: Colors.white70, size: 22),
                        onPressed:
                            _datosHistoricos.isEmpty ? null : _retroceder,
                        tooltip: 'Retroceder',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 36, minHeight: 36),
                      ),
                      // Play / Pausa
                      IconButton(
                        icon: Icon(
                          _reproduciendo
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: Colors.orange,
                          size: 32,
                        ),
                        onPressed:
                            _datosHistoricos.isEmpty ? null : _togglePlay,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 40, minHeight: 40),
                      ),
                      // Avanzar 20 puntos
                      IconButton(
                        icon: const Icon(Icons.fast_forward,
                            color: Colors.white70, size: 22),
                        onPressed:
                            _datosHistoricos.isEmpty ? null : _avanzar,
                        tooltip: 'Avanzar',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 36, minHeight: 36),
                      ),
                      const SizedBox(width: 4),
                      // Menú de velocidades
                      PopupMenuButton<double>(
                        onSelected: _cambiarVelocidad,
                        color: const Color(0xFF2A2A2A),
                        tooltip: 'Velocidad',
                        itemBuilder: (_) => _velocidades.keys
                            .map((v) => PopupMenuItem<double>(
                                  value: v,
                                  child: Row(
                                    children: [
                                      if (v == _velocidad)
                                        const Icon(Icons.check,
                                            color: Colors.orange, size: 16)
                                      else
                                        const SizedBox(width: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${v == v.truncateToDouble() ? v.toInt() : v}x',
                                        style: TextStyle(
                                          color: v == _velocidad
                                              ? Colors.orange
                                              : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: Colors.orange, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _etiquetaVelocidad(),
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(Icons.speed,
                                  color: Colors.orange, size: 14),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Hora actual de simulación
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.orange, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              _horaActual(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Fila 2: Slider de línea de tiempo
                  Row(
                    children: [
                      // Hora inicio del día
                      const Text(
                        '00:00',
                        style:
                            TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: Colors.orange,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.orange,
                            overlayColor: Colors.orange.withValues(alpha: 0.2),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7),
                            trackHeight: 3,
                          ),
                          child: Slider(
                            value: _datosHistoricos.isEmpty
                                ? 0
                                : _puntero
                                    .clamp(
                                        0, _datosHistoricos.length - 1)
                                    .toDouble(),
                            min: 0,
                            max: _datosHistoricos.isEmpty
                                ? 1
                                : (_datosHistoricos.length - 1).toDouble(),
                            onChangeStart: (_) => _pausar(),
                            onChanged: _datosHistoricos.isEmpty
                                ? null
                                : (val) {
                                    setState(() {
                                      _puntero = val.toInt();
                                      rastrosCola.clear();
                                      marcadoresActivos.clear();
                                    });
                                  },
                            onChangeEnd: (_) => _reanudar(),
                          ),
                        ),
                      ),
                      // Hora fin del día
                      const Text(
                        '23:59',
                        style:
                            TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),

                  // Indicador de puntos cargados
                  if (_datosHistoricos.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '${_puntero} / ${_datosHistoricos.length} registros',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcono(String id) {
    final nombre =
        equiposInfo[id]?['codigo_equipo_control'] ?? 'V-??';
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.greenAccent),
          ),
          child: Text(
            nombre,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold),
          ),
        ),
        const Icon(Icons.local_shipping,
            color: Colors.greenAccent, size: 35),
      ],
    );
  }
}
