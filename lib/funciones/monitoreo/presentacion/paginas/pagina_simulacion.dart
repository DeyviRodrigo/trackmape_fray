import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';

class HojaSimulacion extends StatefulWidget {
  const HojaSimulacion({super.key});

  @override
  State<HojaSimulacion> createState() => _HojaSimulacionState();
}

class _HojaSimulacionState extends State<HojaSimulacion> {
  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();

  DateTime _fechaSimulacion = DateTime(2026, 1, 15);
  List<Map<String, dynamic>> _datosHistoricos = [];
  int _puntero = 0;
  bool _reproduciendo = false;
  double _velocidad = 1.0;
  Timer? _timerSimulacion;
  bool _cargando = false;
  bool _estabaReproduciendoDuranteArrastre = false;

  Map<String, Map<String, dynamic>> equiposInfo = {};
  Map<String, Marker> marcadoresActivos = {};
  Map<String, List<ll.LatLng>> rastrosCola = {};

  static final Map<double, int> _velocidades = {
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
      _fechaSimulacion = fecha;
      _cargando = true;
      _reproduciendo = false;
      _puntero = 0;
      _datosHistoricos = [];
      equiposInfo.clear();
      marcadoresActivos.clear();
      rastrosCola.clear();
    });

    final resultados = await Future.wait([
      _repositorio.obtenerEquiposRaw(),
      _repositorio.obtenerTrayectoriaPorFecha(fecha),
    ]);

    final equipos = resultados[0] as List<Map<String, dynamic>>;
    final trayectoria = resultados[1] as List<Map<String, dynamic>>;

    setState(() {
      for (final equipo in equipos) {
        equiposInfo[equipo['id_equipo_control'].toString()] = equipo;
      }
      _datosHistoricos = trayectoria;
      _puntero = 0;
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
      Duration(milliseconds: _velocidades[_velocidad] ?? 800),
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
      if (rastrosCola[id]!.length > 15) {
        rastrosCola[id]!.removeAt(0);
      }
    });
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
              onPrimary: Colors.black,
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
      backgroundColor: Colors.black,
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
                  options: const MapOptions(
                    initialCenter: ll.LatLng(-15.488405, -70.150497),
                    initialZoom: 15,
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
              _buildPanelInferior(total, sliderValue, sliderMax),
            ],
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

  Widget _buildPanelInferior(int total, double sliderValue, double sliderMax) {
    return Container(
      color: const Color(0xE61A1A1A),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
                dropdownColor: const Color(0xFF1A1A1A),
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
              const Spacer(),
              Text(
                _horaActual(),
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
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
    final nombre = equiposInfo[id]?['codigo_equipo_control']?.toString() ?? id;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Icon(Icons.local_shipping, color: Colors.greenAccent, size: 35),
      ],
    );
  }
}
