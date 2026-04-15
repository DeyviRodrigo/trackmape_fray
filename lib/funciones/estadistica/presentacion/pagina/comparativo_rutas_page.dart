import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/core/utilidades/limpiador_trayectoria.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/modelos/equipo_rendimiento.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/modelos/punto_rendimiento.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/repositorios/repositorio_rendimiento_operacional.dart';

class ComparativoRutasPage extends StatefulWidget {
  const ComparativoRutasPage({super.key});

  @override
  State<ComparativoRutasPage> createState() => _ComparativoRutasPageState();
}

class _ComparativoRutasPageState extends State<ComparativoRutasPage> {
  final RepositorioRendimientoOperacional _repo =
      RepositorioRendimientoOperacional();

  DateTime _fechaSeleccionada = DateTime.now();
  List<EquipoRendimiento> _equipos = const [];
  EquipoRendimiento? _equipoSeleccionado;
  bool _cargandoEquipos = true;
  bool _cargando = false;
  String? _error;

  List<PuntoRendimiento> _puntosCrudos = const [];
  ResultadoLimpiezaTrayectoria<PuntoRendimiento> _resultado =
      const ResultadoLimpiezaTrayectoria(
        puntos: [],
        segmentos: [],
        estadisticas: EstadisticasTrayectoria.vacia,
      );
  _ModoFiltro _modoFiltro = _ModoFiltro.normal;
  double _velocidadManualKmh = 35.0;

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
  }

  Future<void> _cargarEquipos() async {
    try {
      final equipos = await _repo.obtenerEquiposDisponibles();
      final filtrados = equipos
          .where((equipo) => equipo.codigoEquipoControl.trim().startsWith('!'))
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _equipos = filtrados;
        _equipoSeleccionado = filtrados.isNotEmpty ? filtrados.first : null;
        _cargandoEquipos = false;
      });

      if (filtrados.isNotEmpty) {
        await _cargarDatos();
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargandoEquipos = false;
        _error = 'No se pudieron cargar los equipos: $e';
      });
    }
  }

  Future<void> _cargarDatos() async {
    final equipo = _equipoSeleccionado;
    if (equipo == null) {
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final puntos = await _repo.obtenerPuntosPorEquipoYFecha(
        equipo: equipo,
        fecha: _fechaSeleccionada,
      );
      final crudosValidos = puntos.where(_coordenadaEsValida).toList();
      final convertidos = crudosValidos
          .map(
            (punto) => PuntoTrayectoria<PuntoRendimiento>(
              latitud: punto.latitud,
              longitud: punto.longitud,
            tiempo: punto.tiempo,
            payload: punto,
          ),
        )
        .toList();
      final resultado = _crearLimpiador().limpiar(convertidos);

      if (!mounted) {
        return;
      }

      setState(() {
        _puntosCrudos = crudosValidos;
        _resultado = resultado;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargando = false;
        _error = 'No se pudieron cargar los recorridos: $e';
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Seleccionar fecha',
    );

    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
      await _cargarDatos();
    }
  }

  bool _coordenadaEsValida(PuntoRendimiento punto) {
    return _crearLimpiador().coordenadaEsValida(punto.latitud, punto.longitud);
  }

  LimpiadorTrayectoria _crearLimpiador() {
    return LimpiadorTrayectoria(
      velocidadOperativaMaximaKmh: _velocidadAplicadaKmh,
    );
  }

  double get _velocidadAplicadaKmh {
    switch (_modoFiltro) {
      case _ModoFiltro.nevada:
        return 15.0;
      case _ModoFiltro.normal:
        return 25.0;
      case _ModoFiltro.caminoLibre:
        return 35.0;
      case _ModoFiltro.personalizado:
        return _velocidadManualKmh;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoEquipos) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    final puntosFiltrados = _resultado.puntos.map((punto) => punto.payload).toList();
    final perdidos = _puntosCrudos.length - puntosFiltrados.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1100;
        final isMobile = constraints.maxWidth < 760;
        final mapHeight = isMobile ? 320.0 : 360.0;
        final selectorWidth = isMobile ? constraints.maxWidth - 32 : 420.0;

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Comparativo de Rutas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Container(
                  constraints: BoxConstraints(
                    minWidth: selectorWidth,
                    maxWidth: selectorWidth,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _equipoSeleccionado?.idEquipoControl,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E1E1E),
                      hint: const Text('Seleccionar unidad'),
                      items: _equipos
                          .map(
                            (equipo) => DropdownMenuItem<String>(
                              value: equipo.idEquipoControl,
                              child: Text(
                                '${equipo.etiquetaVisible} (${equipo.codigoEquipoControl})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _equipoSeleccionado = _equipos.firstWhere(
                            (equipo) => equipo.idEquipoControl == value,
                          );
                        });
                        _cargarDatos();
                      },
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _seleccionarFecha,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                  ),
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    '${_fechaSeleccionada.year.toString().padLeft(4, '0')}-${_fechaSeleccionada.month.toString().padLeft(2, '0')}-${_fechaSeleccionada.day.toString().padLeft(2, '0')}',
                  ),
                ),
                IconButton(
                  onPressed: _cargando ? null : _cargarDatos,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Recargar comparativo',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtro manual de la ruta filtrada',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: _ModoFiltro.values
                          .map(
                            (modo) => ChoiceChip(
                              label: Text(modo.etiqueta),
                              selected: _modoFiltro == modo,
                              selectedColor: Colors.orange,
                              backgroundColor: Colors.white10,
                              labelStyle: TextStyle(
                                color: _modoFiltro == modo
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (selected) {
                                if (!selected) {
                                  return;
                                }
                                setState(() {
                                  _modoFiltro = modo;
                                });
                                _cargarDatos();
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    if (isMobile)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _modoFiltro == _ModoFiltro.personalizado
                                ? 'Km/h maximo manual: ${_velocidadManualKmh.toStringAsFixed(0)}'
                                : 'Km/h maximo aplicado por modo: ${_velocidadAplicadaKmh.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Slider(
                            value: _velocidadManualKmh,
                            min: 10,
                            max: 60,
                            divisions: 10,
                            activeColor: Colors.orange,
                            inactiveColor: Colors.white24,
                            label: '${_velocidadManualKmh.toStringAsFixed(0)} km/h',
                            onChanged: _modoFiltro == _ModoFiltro.personalizado
                                ? (value) {
                                    setState(() {
                                      _velocidadManualKmh = value;
                                    });
                                  }
                                : null,
                            onChangeEnd: _modoFiltro == _ModoFiltro.personalizado
                                ? (_) => _cargarDatos()
                                : null,
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _modoFiltro == _ModoFiltro.personalizado
                                  ? 'Km/h maximo manual: ${_velocidadManualKmh.toStringAsFixed(0)}'
                                  : 'Km/h maximo aplicado por modo: ${_velocidadAplicadaKmh.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 260,
                            child: Slider(
                              value: _velocidadManualKmh,
                              min: 10,
                              max: 60,
                              divisions: 10,
                              activeColor: Colors.orange,
                              inactiveColor: Colors.white24,
                              label: '${_velocidadManualKmh.toStringAsFixed(0)} km/h',
                              onChanged: _modoFiltro == _ModoFiltro.personalizado
                                  ? (value) {
                                      setState(() {
                                        _velocidadManualKmh = value;
                                      });
                                    }
                                  : null,
                              onChangeEnd: _modoFiltro == _ModoFiltro.personalizado
                                  ? (_) => _cargarDatos()
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 6),
                    Text(
                      'La ruta cruda no cambia. La ruta filtrada usa la estadistica de tus datos y este limite manual para mostrarle al cliente un escenario mas lento o mas rapido sin tocar codigo.',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _chip('Crudos validos: ${_puntosCrudos.length}'),
                  _chip('Filtrados: ${puntosFiltrados.length}'),
                  _chip('Perdidos: $perdidos'),
                  _chip(
                    'Media: ${_resultado.estadisticas.mediaDistanciaMetros.toStringAsFixed(1)} m',
                  ),
                  _chip(
                    'Mediana: ${_resultado.estadisticas.medianaDistanciaMetros.toStringAsFixed(1)} m',
                  ),
                  _chip(
                    'P90: ${_resultado.estadisticas.percentil90DistanciaMetros.toStringAsFixed(1)} m',
                  ),
                  _chip(
                    'Umbral: ${_resultado.estadisticas.umbralDistanciaMetros.toStringAsFixed(1)} m / ${_resultado.estadisticas.umbralVelocidadKmh.toStringAsFixed(1)} km/h',
                    color: Colors.orangeAccent.withOpacity(0.12),
                    borderColor: Colors.orangeAccent,
                  ),
                  _chip(
                    'Modo: ${_modoFiltro.etiqueta}',
                    color: Colors.lightBlueAccent.withOpacity(0.12),
                    borderColor: Colors.lightBlueAccent,
                  ),
                  _chip(
                    'Km/h aplicado: ${_velocidadAplicadaKmh.toStringAsFixed(0)}',
                    color: Colors.lightBlueAccent.withOpacity(0.12),
                    borderColor: Colors.lightBlueAccent,
                  ),
                ],
              ),
              if (_cargando)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(color: Colors.orange),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
            const SizedBox(height: 12),
            if (isWide)
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _MapaComparativo(
                        titulo: 'Ruta Cruda',
                        puntos: _puntosCrudos,
                        segmentosFiltrados: const [],
                        colorRutaCruda: Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MapaComparativo(
                        titulo: 'Ruta Filtrada',
                        puntos: puntosFiltrados,
                        segmentosFiltrados: _resultado.segmentos
                            .map(
                              (segmento) =>
                                  segmento.map((punto) => punto.payload).toList(),
                            )
                            .toList(),
                        colorRutaCruda: Colors.lightGreenAccent,
                        subtitulo:
                            'Modo ${_modoFiltro.etiqueta} | ${_velocidadAplicadaKmh.toStringAsFixed(0)} km/h',
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              SizedBox(
                height: mapHeight,
                child: _MapaComparativo(
                  titulo: 'Ruta Cruda',
                  puntos: _puntosCrudos,
                  segmentosFiltrados: const [],
                  colorRutaCruda: Colors.orangeAccent,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: mapHeight,
                child: _MapaComparativo(
                  titulo: 'Ruta Filtrada',
                  puntos: puntosFiltrados,
                  segmentosFiltrados: _resultado.segmentos
                      .map(
                        (segmento) =>
                            segmento.map((punto) => punto.payload).toList(),
                      )
                      .toList(),
                  colorRutaCruda: Colors.lightGreenAccent,
                  subtitulo:
                      'Modo ${_modoFiltro.etiqueta} | ${_velocidadAplicadaKmh.toStringAsFixed(0)} km/h',
                ),
              ),
            ],
          ],
        );

        if (isWide) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: content,
        );
      },
    );
  }

  Widget _chip(
    String texto, {
    Color color = Colors.white24,
    Color borderColor = Colors.white24,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        texto,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}

class _MapaComparativo extends StatelessWidget {
  const _MapaComparativo({
    required this.titulo,
    required this.puntos,
    required this.segmentosFiltrados,
    required this.colorRutaCruda,
    this.subtitulo,
  });

  final String titulo;
  final List<PuntoRendimiento> puntos;
  final List<List<PuntoRendimiento>> segmentosFiltrados;
  final Color colorRutaCruda;
  final String? subtitulo;

  @override
  Widget build(BuildContext context) {
    final centro = _calcularCentro() ?? const ll.LatLng(-15.488405, -70.150497);
    final usaSegmentos = segmentosFiltrados.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              options: MapOptions(initialCenter: centro, initialZoom: 15),
              children: [
                TileLayer(
                  urlTemplate: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                ),
                if (!usaSegmentos && puntos.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: puntos
                            .map((p) => ll.LatLng(p.latitud, p.longitud))
                            .toList(),
                        color: colorRutaCruda,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                if (usaSegmentos)
                  PolylineLayer(
                    polylines: segmentosFiltrados
                        .where((segmento) => segmento.length >= 2)
                        .map(
                          (segmento) => Polyline(
                            points: segmento
                                .map((p) => ll.LatLng(p.latitud, p.longitud))
                                .toList(),
                            color: colorRutaCruda,
                            strokeWidth: 4,
                          ),
                        )
                        .toList(),
                  ),
                if (puntos.isNotEmpty)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: ll.LatLng(puntos.first.latitud, puntos.first.longitud),
                        width: 24,
                        height: 24,
                        child: const Icon(
                          Icons.play_circle_fill,
                          color: Colors.lightGreenAccent,
                          size: 22,
                        ),
                      ),
                      Marker(
                        point: ll.LatLng(puntos.last.latitud, puntos.last.longitud),
                        width: 20,
                        height: 20,
                        child: const Icon(
                          Icons.radio_button_checked,
                          color: Colors.lightBlueAccent,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitulo != null)
                    Text(
                      subtitulo!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
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

  ll.LatLng? _calcularCentro() {
    if (puntos.isEmpty) {
      return null;
    }

    var lat = 0.0;
    var lon = 0.0;
    for (final punto in puntos) {
      lat += punto.latitud;
      lon += punto.longitud;
    }
    return ll.LatLng(lat / puntos.length, lon / puntos.length);
  }
}

enum _ModoFiltro {
  nevada('Nevada'),
  normal('Normal'),
  caminoLibre('Camino libre'),
  personalizado('Personalizado');

  const _ModoFiltro(this.etiqueta);

  final String etiqueta;
}
