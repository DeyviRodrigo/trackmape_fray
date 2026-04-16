import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/core/mapas/coordenadas_operacion.dart';
import 'package:trackmape_sup/core/ui/track_custom_icons.dart';
import 'package:trackmape_sup/core/utilidades/limpiador_trayectoria.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/modelos/modelo_equipo.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';
import 'package:trackmape_sup/funciones/monitoreo/dominio/servicios/servicio_metricas_operador.dart';

class PaginaHistorico extends StatefulWidget {
  const PaginaHistorico({
    super.key,
    this.equipoIdFiltro,
    this.nombreEquipoFiltro,
    this.fechaInicial,
  });

  final String? equipoIdFiltro;
  final String? nombreEquipoFiltro;
  final DateTime? fechaInicial;

  @override
  State<PaginaHistorico> createState() => _PaginaHistoricoState();
}

class _PaginaHistoricoState extends State<PaginaHistorico> {
  static const List<String> _mesesEspanol = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  static const List<String> _diasSemanaAbreviados = [
    'L',
    'M',
    'M',
    'J',
    'V',
    'S',
    'D',
  ];

  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();
  final LimpiadorTrayectoria _limpiador = const LimpiadorTrayectoria();
  final ServicioMetricasOperador _servicioMetricas =
      const ServicioMetricasOperador();
  final ConfiguracionMetricasOperador _configMetricas =
      ConfiguracionMetricasOperador.porDefecto;

  final Map<String, String> mapaEtiquetasEquipos = {};
  final Map<String, String> mapaNombresEquipos = {};
  final Map<String, String> mapaCodigosEquipos = {};

  late DateTime fechaSeleccionada;
  Map<String, dynamic>? puntoSeleccionado;
  double velocidadCalc = 0.0;
  String tiempoReporte = '';

  @override
  void initState() {
    super.initState();
    fechaSeleccionada = widget.fechaInicial ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _cerrarHistorico();
          },
          child: Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  FutureBuilder<_DatosHistoricoVista>(
                    future: _cargarDatosHistoricos(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.orange),
                        );
                      }

                      final datosVista = snapshot.data!;
                      mapaEtiquetasEquipos.clear();
                      mapaNombresEquipos.clear();
                      mapaCodigosEquipos.clear();
                      for (final equipo in datosVista.equiposPorId.values) {
                        final id = equipo.id;
                        final nombre = equipo.nombre?.trim() ?? '';
                        final codigo = equipo.codigo?.trim() ?? '';
                        mapaNombresEquipos[id] = nombre;
                        mapaCodigosEquipos[id] = codigo;
                        mapaEtiquetasEquipos[id] = nombre.isNotEmpty
                            ? nombre
                            : (codigo.isNotEmpty ? codigo : 'S/N');
                      }

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
                          CircleLayer(circles: _construirCirculosOperativos()),
                          PolylineLayer(
                            polylines: _generarLineas(
                              datosVista.resultadosPorEquipo,
                            ),
                          ),
                          MarkerLayer(
                            markers: [
                              ..._construirMarcadoresOperativos(),
                              ..._construirMarcadores(
                                datosVista.resultadosPorEquipo,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.equipoIdFiltro != null) ...[
                          _buildFloatingBackButton(),
                          const SizedBox(width: 10),
                        ],
                        _buildMiniCalendarCard(isMobile: isMobile),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildHistoricoInfoCard(isMobile: isMobile),
                        ),
                      ],
                    ),
                  ),
                  if (puntoSeleccionado != null)
                    _buildPanelInfo(isMobile: isMobile),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<_DatosHistoricoVista> _cargarDatosHistoricos() async {
    final equiposRaw = await _repositorio.obtenerEquiposRaw();
    final equiposPorId = <String, ModeloEquipo>{};
    for (final equipo in equiposRaw) {
      final modelo = ModeloEquipo.fromJson(equipo);
      equiposPorId[modelo.id] = modelo;
    }

    final trayectoriaRaw = await _repositorio.obtenerTrayectoriaPorFecha(
      fechaSeleccionada,
    );
    final trayectoriaFiltrada = widget.equipoIdFiltro == null
        ? trayectoriaRaw
        : trayectoriaRaw
            .where((punto) => punto['fk_emisor']?.toString() == widget.equipoIdFiltro)
            .toList();

    final trayectoria = await _mezclarConexionesSiHoy(trayectoriaFiltrada);
    final datosPorEquipo = <String, List<Map<String, dynamic>>>{};
    for (final punto in trayectoria) {
      final id = punto['fk_emisor']?.toString();
      if (id == null || id.isEmpty) continue;
      datosPorEquipo.putIfAbsent(id, () => []);
      datosPorEquipo[id]!.add(punto);
    }

    final resultadosPorEquipo = <String, ResultadoProcesadoOperador>{};
    for (final entry in datosPorEquipo.entries) {
      final equipo = equiposPorId[entry.key] ??
          ModeloEquipo(
            id: entry.key,
            nombre: mapaNombresEquipos[entry.key],
            codigo: mapaCodigosEquipos[entry.key],
          );
      resultadosPorEquipo[entry.key] = _servicioMetricas.procesarDatosUnidad(
        equipo: equipo,
        puntosCrudos: entry.value,
      );
    }

    return _DatosHistoricoVista(
      equiposPorId: equiposPorId,
      resultadosPorEquipo: resultadosPorEquipo,
    );
  }

  List<CircleMarker> _construirCirculosOperativos() {
    final circulos = <CircleMarker>[];

    for (final punto in _configMetricas.puntosDescarga) {
      circulos.add(
        CircleMarker(
          point: ll.LatLng(punto.latitud, punto.longitud),
          radius: _configMetricas.radioSalidaChuteMetros,
          useRadiusInMeter: true,
          color: Colors.orange.withOpacity(0.05),
          borderColor: Colors.orange.withOpacity(0.35),
          borderStrokeWidth: 1.2,
        ),
      );
      circulos.add(
        CircleMarker(
          point: ll.LatLng(punto.latitud, punto.longitud),
          radius: _configMetricas.radioEntradaChuteMetros,
          useRadiusInMeter: true,
          color: Colors.orange.withOpacity(0.16),
          borderColor: Colors.orangeAccent,
          borderStrokeWidth: 2,
        ),
      );
    }

    for (final punto in _configMetricas.puntosCarga) {
      circulos.add(
        CircleMarker(
          point: ll.LatLng(punto.latitud, punto.longitud),
          radius: _configMetricas.radioSalidaCargaMetros,
          useRadiusInMeter: true,
          color: Colors.cyanAccent.withOpacity(0.04),
          borderColor: Colors.cyanAccent.withOpacity(0.32),
          borderStrokeWidth: 1.2,
        ),
      );
      circulos.add(
        CircleMarker(
          point: ll.LatLng(punto.latitud, punto.longitud),
          radius: _configMetricas.radioEntradaCargaMetros,
          useRadiusInMeter: true,
          color: Colors.cyanAccent.withOpacity(0.14),
          borderColor: Colors.cyanAccent,
          borderStrokeWidth: 2,
        ),
      );
    }

    return circulos;
  }

  List<Marker> _construirMarcadoresOperativos() {
    final marcadores = <Marker>[];

    for (final entry in _configMetricas.puntosDescarga.asMap().entries) {
      marcadores.add(
        Marker(
          point: ll.LatLng(entry.value.latitud, entry.value.longitud),
          width: 76,
          height: 30,
          child: _buildGeocercaLabel(
            texto: 'Chute ${entry.key + 1}',
            borde: Colors.orangeAccent,
            textoColor: Colors.orangeAccent,
          ),
        ),
      );
    }

    for (final punto in _configMetricas.puntosCarga) {
      marcadores.add(
        Marker(
          point: ll.LatLng(punto.latitud, punto.longitud),
          width: 76,
          height: 30,
          child: _buildGeocercaLabel(
            texto: 'Carga',
            borde: Colors.cyanAccent,
            textoColor: Colors.cyanAccent,
          ),
        ),
      );
    }

    return marcadores;
  }

  Widget _buildGeocercaLabel({
    required String texto,
    required Color borde,
    required Color textoColor,
  }) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borde),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: textoColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _mezclarConexionesSiHoy(
    List<Map<String, dynamic>> trayectoria,
  ) async {
    if (!_esMismoDia(fechaSeleccionada, DateTime.now())) {
      final ordenados = [...trayectoria]
        ..sort((a, b) => a['tiempo'].toString().compareTo(b['tiempo'].toString()));
      return ordenados;
    }

    final conexiones = (await _repositorio.obtenerUltimasPosiciones()).where((punto) {
      if (widget.equipoIdFiltro == null) return true;
      return punto['fk_emisor']?.toString() == widget.equipoIdFiltro;
    });

    final resultado = [...trayectoria];
    for (final conexion in conexiones) {
      final id = conexion['fk_emisor']?.toString();
      final tiempo = conexion['tiempo']?.toString();
      final existe = resultado.any(
        (punto) =>
            punto['fk_emisor']?.toString() == id &&
            punto['tiempo']?.toString() == tiempo,
      );
      if (!existe) {
        resultado.add(Map<String, dynamic>.from(conexion));
      }
    }

    resultado.sort((a, b) => a['tiempo'].toString().compareTo(b['tiempo'].toString()));
    return resultado;
  }

  void _cerrarHistorico() {
    Navigator.of(context).pop<DateTime>(fechaSeleccionada);
  }

  bool _esMismoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _seleccionarFechaHistorica(DateTime nuevaFecha) {
    final fechaNormalizada = DateTime(
      nuevaFecha.year,
      nuevaFecha.month,
      nuevaFecha.day,
    );
    final hoy = DateTime.now();
    final limiteSuperior = DateTime(hoy.year, hoy.month, hoy.day);
    final limiteInferior = DateTime(2024, 1, 1);

    if (fechaNormalizada.isAfter(limiteSuperior) ||
        fechaNormalizada.isBefore(limiteInferior)) {
      return;
    }

    setState(() {
      fechaSeleccionada = fechaNormalizada;
      puntoSeleccionado = null;
    });
  }

  void _cambiarMesVisible(int deltaMeses) {
    final mesActual = DateTime(fechaSeleccionada.year, fechaSeleccionada.month);
    final nuevoMes = DateTime(mesActual.year, mesActual.month + deltaMeses, 1);
    final ultimoDiaMes = _diasEnMes(nuevoMes.year, nuevoMes.month);
    final nuevoDia = fechaSeleccionada.day.clamp(1, ultimoDiaMes);

    _seleccionarFechaHistorica(
      DateTime(nuevoMes.year, nuevoMes.month, nuevoDia),
    );
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
        onTap: _cerrarHistorico,
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

  Widget _buildMiniCalendarCard({required bool isMobile}) {
    final ancho = isMobile ? 142.0 : 168.0;
    final mesVisible = DateTime(fechaSeleccionada.year, fechaSeleccionada.month, 1);
    final offsetInicio = _indiceInicioMes(mesVisible);
    final totalDias = _diasEnMes(mesVisible.year, mesVisible.month);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: ancho,
          padding: EdgeInsets.fromLTRB(12, isMobile ? 10 : 12, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.94),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.indigo.shade200, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => _cambiarMesVisible(-1),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.chevron_left,
                        color: Color(0xFF3F51B5),
                        size: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _mesesEspanol[mesVisible.month - 1],
                          style: TextStyle(
                            color: Colors.indigo.shade700,
                            fontSize: isMobile ? 14 : 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${mesVisible.year}',
                          style: TextStyle(
                            color: Colors.indigo.shade700,
                            fontSize: isMobile ? 10 : 11,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _cambiarMesVisible(1),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.chevron_right,
                        color: Color(0xFF3F51B5),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: _diasSemanaAbreviados
                    .map(
                      (dia) => Expanded(
                        child: Text(
                          dia,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: isMobile ? 10 : 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 4),
              GridView.builder(
                itemCount: offsetInicio + totalDias,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  if (index < offsetInicio) {
                    return const SizedBox.shrink();
                  }

                  final dia = index - offsetInicio + 1;
                  final fechaDia = DateTime(mesVisible.year, mesVisible.month, dia);
                  final seleccionado = _esMismoDia(fechaDia, fechaSeleccionada);
                  final hoy = _esMismoDia(fechaDia, DateTime.now());
                  final habilitado = !_fechaFueraDeRango(fechaDia);

                  return InkWell(
                    onTap: habilitado ? () => _seleccionarFechaHistorica(fechaDia) : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: seleccionado
                            ? const Color(0xFF3F51B5)
                            : (hoy ? const Color(0xFFE8EAF6) : Colors.transparent),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$dia',
                        style: TextStyle(
                          color: !habilitado
                              ? Colors.black26
                              : (seleccionado ? Colors.white : Colors.black87),
                          fontSize: isMobile ? 10.5 : 11.5,
                          fontWeight: seleccionado ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoricoInfoCard({required bool isMobile}) {
    final fechaTexto =
        '${fechaSeleccionada.day.toString().padLeft(2, '0')}/${fechaSeleccionada.month.toString().padLeft(2, '0')}/${fechaSeleccionada.year}';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 14,
        vertical: isMobile ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.nombreEquipoFiltro?.isNotEmpty == true
                ? widget.nombreEquipoFiltro!
                : 'Consulta historica',
            style: TextStyle(
              color: Colors.orange,
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Fecha seleccionada: $fechaTexto',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 12 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Toca un dia del calendario para recargar el mapa.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _construirMarcadores(
    Map<String, ResultadoProcesadoOperador> resultadosPorEquipo,
  ) {
    final marcadoresUltimaPosicion = <String, Marker>{};

    for (final entry in resultadosPorEquipo.entries) {
      final id = entry.key;
      final limpios = entry.value.puntosLimpios.map((punto) => punto.payload).toList();
      final pos = limpios.isNotEmpty ? limpios.last : null;
      if (pos == null) {
        continue;
      }
      final iconoEquipo = TrackCustomIcons.iconoPorEquipo(
        nombre: mapaNombresEquipos[id],
        codigo: mapaCodigosEquipos[id],
      );

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
              Icon(
                iconoEquipo,
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

  List<Polyline> _generarLineas(
    Map<String, ResultadoProcesadoOperador> resultadosPorEquipo,
  ) {
    final polilineas = <Polyline>[];

    for (final entry in resultadosPorEquipo.entries) {
      final segmentos = _segmentarRutaValida(entry.value.segmentosReconstruidos);

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

  PuntoTrayectoria<Map<String, dynamic>> _mapToPunto(Map<String, dynamic> punto) {
    return PuntoTrayectoria<Map<String, dynamic>>(
      latitud: (punto['lat_grados'] as num).toDouble(),
      longitud: (punto['lon_grados'] as num).toDouble(),
      tiempo: DateTime.parse(punto['tiempo']),
      payload: punto,
    );
  }

  bool _fechaFueraDeRango(DateTime fecha) {
    final hoy = DateTime.now();
    final limiteSuperior = DateTime(hoy.year, hoy.month, hoy.day);
    final limiteInferior = DateTime(2024, 1, 1);
    return fecha.isAfter(limiteSuperior) || fecha.isBefore(limiteInferior);
  }

  int _diasEnMes(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _indiceInicioMes(DateTime fechaMes) {
    final weekday = fechaMes.weekday;
    return weekday - 1;
  }
}

class _DatosHistoricoVista {
  final Map<String, ModeloEquipo> equiposPorId;
  final Map<String, ResultadoProcesadoOperador> resultadosPorEquipo;

  const _DatosHistoricoVista({
    required this.equiposPorId,
    required this.resultadosPorEquipo,
  });
}
