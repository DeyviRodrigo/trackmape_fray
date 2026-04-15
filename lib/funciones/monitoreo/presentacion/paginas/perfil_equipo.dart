import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/core/utilidades/limpiador_trayectoria.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/modelos/modelo_equipo.dart';
import 'package:trackmape_sup/funciones/monitoreo/dominio/servicios/servicio_metricas_operador.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_historico.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_stream.dart';

const Color _colorNeutral900 = Color(0xFF121212);
const Color _colorNeutral800 = Color(0xFF1A1A1A);
const Color _colorNeutral700 = Color(0xFF242424);
const Color _colorPrimary = Color(0xFFFF9800);
const Color _colorPrimarySoft = Color(0xFFFFB74D);
const Color _colorTertiary = Color(0xFFFFC107);
const Color _colorSecondary = Color(0xFF2E7D32);
const Color _colorSurfaceBlue = Color(0xFF1F4E68);
const Color _colorSurfaceBlueAlt = Color(0xFF225B79);
const Color _colorSurfaceGreen = Color(0xFF183B24);
const Color _colorSurfaceAmber = Color(0xFF4A3511);
const Color _colorSurfaceDark = Color(0xFF1E1E1E);
const Color _colorDivider = Color(0xFF2A7AA1);

class PaginaPerfilEquipo extends StatefulWidget {
  final ModeloEquipo equipo;
  const PaginaPerfilEquipo({super.key, required this.equipo});

  @override
  State<PaginaPerfilEquipo> createState() => _PaginaPerfilEquipoState();
}

class _PaginaPerfilEquipoState extends State<PaginaPerfilEquipo> {
  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();
  final LimpiadorTrayectoria _limpiador = const LimpiadorTrayectoria();
  final ServicioMetricasOperador _servicioMetricas =
      const ServicioMetricasOperador();
  late DateTime _fechaConsulta;

  @override
  void initState() {
    super.initState();
    _fechaConsulta = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorNeutral900,
      appBar: AppBar(
        title: Text(
          'Perfil de Operador · ${DateFormat('dd/MM/yyyy').format(_fechaConsulta)}',
        ),
        backgroundColor: _colorNeutral900,
        foregroundColor: _colorPrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarControlesFecha,
        backgroundColor: _colorPrimary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.calendar_month),
        label: const Text(
          'Fecha',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<_ResumenPerfilEquipo>(
        future: _cargarResumenPerfil(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return _buildErrorState('No se pudieron cargar los datos del operador.');
          }

          final resumen = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = (constraints.maxWidth - 32).clamp(320.0, 420.0);
              final panelWidth = availableWidth.toDouble();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: panelWidth),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF1C1C1E),
                            Color(0xFF121212),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: _colorPrimary, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 24,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStructuredDashboard(
                            resumen,
                            panelWidth: panelWidth - 32,
                          ),
                          const SizedBox(height: 18),
                          _buildActionButton(
                            label: 'Ver tracking de unidad',
                            icon: Icons.alt_route,
                            filled: true,
                            onPressed: _mostrarOpcionesTracking,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<_ResumenPerfilEquipo> _cargarResumenPerfil() async {
    final trayectoriasDia = (await _repositorio.obtenerTrayectoriaPorFecha(_fechaConsulta))
        .where((punto) => punto['fk_emisor']?.toString() == widget.equipo.id)
        .toList()
      ..sort((a, b) => a['tiempo'].toString().compareTo(b['tiempo'].toString()));

    final conexiones = <Map<String, dynamic>>[];
    if (_esMismoDia(_fechaConsulta, DateTime.now())) {
      conexiones.addAll(
        (await _repositorio.obtenerUltimasPosiciones()).where(
          (punto) => punto['fk_emisor']?.toString() == widget.equipo.id,
        ),
      );
      conexiones.sort(
        (a, b) => a['tiempo'].toString().compareTo(b['tiempo'].toString()),
      );
    }

    final puntos = [...trayectoriasDia];
    for (final conexion in conexiones) {
      final tiempoConexion = conexion['tiempo']?.toString();
      final existe = puntos.any(
        (punto) => punto['tiempo']?.toString() == tiempoConexion,
      );
      if (!existe) {
        puntos.add(conexion);
      }
    }
    puntos.sort((a, b) => a['tiempo'].toString().compareTo(b['tiempo'].toString()));

    final puntosValidos = puntos.where(_esPuntoUsable).toList();
    final ultimo = puntosValidos.isNotEmpty ? puntosValidos.last : null;
    final ultimoTiempo = ultimo == null
        ? null
        : DateTime.tryParse(ultimo['tiempo']?.toString() ?? '');

    final ahora = DateTime.now();
    final activo = ultimoTiempo != null &&
        ahora.difference(ultimoTiempo).inSeconds.abs() <= 60;

    final conectadoDesde = activo && puntosValidos.isNotEmpty
        ? DateTime.tryParse(puntosValidos.first['tiempo']?.toString() ?? '')
        : ultimoTiempo;
    final resumenMovimiento = _servicioMetricas.calcularResumenMovimiento(
      equipo: widget.equipo,
      puntosCrudos: puntos,
    );
    final metricas = _servicioMetricas.calcularMetricasDiarias(
      equipo: widget.equipo,
      puntosCrudos: puntos,
    );

    return _ResumenPerfilEquipo(
      nombreCorto: _abreviarNombre(widget.equipo.nombreMostrar),
      nombreCompleto: widget.equipo.nombreMostrar,
      estado: activo ? 'ACTIVO' : 'INACTIVO',
      conectadoDesdeTexto: conectadoDesde == null
          ? 'Sin datos'
          : DateFormat('dd/MM/yyyy\nhh:mm a').format(conectadoDesde),
      velocidadActualKmh: resumenMovimiento.velocidadActualKmh,
      velocidadMaximaKmh: resumenMovimiento.velocidadMaximaKmh,
      velocidadPromedioKmh: resumenMovimiento.velocidadPromedioKmh,
      recorridoKm: resumenMovimiento.recorridoKm,
      tramosValidos: resumenMovimiento.tramosValidos,
      registrosHoy: resumenMovimiento.registrosValidos,
      ultimoReporteTexto: ultimoTiempo == null
          ? 'Sin GPS'
          : DateFormat('HH:mm:ss').format(ultimoTiempo),
      latitud: (ultimo?['lat_grados'] as num?)?.toDouble(),
      longitud: (ultimo?['lon_grados'] as num?)?.toDouble(),
      altitud: ultimo?['alt_msnm']?.toString(),
      ciclos: metricas.ciclos,
      promedioCicloMin: metricas.promedioCicloMin,
      modaCicloMin: metricas.modaCicloMin,
      mediaCicloMin: metricas.mediaCicloMin,
      maxCicloMin: metricas.maxCicloMin,
      minCicloMin: metricas.minCicloMin,
      sobretiempoTotalMin: metricas.sobretiempoTotalMin,
      sobretiempoPermitidoMin: metricas.sobretiempoPermitidoMin,
      pagoIneficiencia: metricas.pagoIneficiencia,
      costoIneficiencia: metricas.costoIneficiencia,
      almuerzoDesayunoInfo: metricas.almuerzoDesayunoInfo,
      tieneMuestraSuficiente: metricas.tieneMuestraSuficiente,
    );
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

  String _abreviarNombre(String valor) {
    final limpio = valor.trim();
    if (limpio.length <= 14) return limpio.toUpperCase();
    return '${limpio.substring(0, 14).toUpperCase()}...';
  }

  bool _esMismoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _cambiarFechaConsulta(int diasDelta) {
    final ahora = DateTime.now();
    final nuevaFecha = DateTime(
      _fechaConsulta.year,
      _fechaConsulta.month,
      _fechaConsulta.day + diasDelta,
    );

    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final minima = DateTime(2024, 1, 1);
    if (nuevaFecha.isAfter(hoy) || nuevaFecha.isBefore(minima)) {
      return;
    }

    setState(() {
      _fechaConsulta = nuevaFecha;
    });
  }

  Future<void> _mostrarControlesFecha() async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF171717),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void actualizar(int delta) {
              _cambiarFechaConsulta(delta);
              setModalState(() {});
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Cambiar fecha de prueba',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_fechaConsulta),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBottomSheetAction(
                            label: '-1 dia',
                            icon: Icons.chevron_left,
                            onTap: () => actualizar(-1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBottomSheetAction(
                            label: '+1 dia',
                            icon: Icons.chevron_right,
                            onTap: () => actualizar(1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBottomSheetAction(
                            label: '-7 dias',
                            icon: Icons.keyboard_double_arrow_left,
                            onTap: () => actualizar(-7),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBottomSheetAction(
                            label: 'Hoy',
                            icon: Icons.today,
                            onTap: () {
                              setState(() {
                                _fechaConsulta = DateTime.now();
                              });
                              setModalState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatearMinutosDashboard(double? valor, {String sufijo = 'min'}) {
    if (valor == null) return 'Sin dato';
    return '${valor.toStringAsFixed(1)} $sufijo';
  }

  String _formatearMontoDashboard(double? valor) {
    if (valor == null) return 'Sin dato';
    return 'S/ ${valor.toStringAsFixed(2)}';
  }

  void _abrirTrackingEnVivo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaginaStream(
          equipoIdFiltro: widget.equipo.id,
          nombreEquipoFiltro: widget.equipo.nombreMostrar,
        ),
      ),
    );
  }

  Future<void> _abrirHistorico() async {
    final fechaRetornada = await Navigator.push<DateTime>(
      context,
      MaterialPageRoute(
        builder: (_) => PaginaHistorico(
          equipoIdFiltro: widget.equipo.id,
          nombreEquipoFiltro: widget.equipo.nombreMostrar,
          fechaInicial: _fechaConsulta,
        ),
      ),
    );

    if (!mounted || fechaRetornada == null) return;

    setState(() {
      _fechaConsulta = DateTime(
        fechaRetornada.year,
        fechaRetornada.month,
        fechaRetornada.day,
      );
    });
  }

  Future<void> _mostrarOpcionesTracking() async {
    final accion = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF171717),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.equipo.nombreMostrar,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selecciona que deseas consultar para esta unidad',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                _buildBottomSheetAction(
                  label: 'Ver tracking en vivo',
                  icon: Icons.sensors,
                  onTap: () {
                    Navigator.pop(context, 'en_vivo');
                  },
                ),
                const SizedBox(height: 12),
                _buildBottomSheetAction(
                  label: 'Ver datos anteriores',
                  icon: Icons.history,
                  onTap: () {
                    Navigator.pop(context, 'historico');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    switch (accion) {
      case 'en_vivo':
        _abrirTrackingEnVivo();
        break;
      case 'historico':
        await _abrirHistorico();
        break;
      default:
        break;
    }
  }

  Widget _buildHero(_ResumenPerfilEquipo resumen, {bool isMobile = false}) {
    final colorEstado =
        resumen.estado == 'ACTIVO' ? Colors.greenAccent : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 12,
            spacing: 12,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resumen.nombreCorto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      resumen.nombreCompleto,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colorEstado.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorEstado.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado',
                      style: TextStyle(
                        color: colorEstado,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resumen.estado,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHeroInfo(
                  'Conectado desde',
                  resumen.conectadoDesdeTexto,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeroInfo(
                  'Codigo unidad',
                  widget.equipo.codigo ?? 'Sin codigo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStructuredDashboard(
    _ResumenPerfilEquipo resumen, {
    required double panelWidth,
  }) {
    const spacing = 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTopNameCard(resumen),
        SizedBox(height: spacing),
        _buildStatusHeader(
          estado: resumen.estado,
          conectadoDesdeTexto: resumen.conectadoDesdeTexto,
        ),
        SizedBox(height: spacing),
        SizedBox(
          height: 176,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildHighlightedMetric(
                  title: 'Velocidad',
                  value: '${resumen.velocidadActualKmh.toStringAsFixed(1)} km/h',
                  accent: _colorPrimarySoft,
                  height: 176,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _buildMetricLineBlock(
                        title: 'Vel Max',
                        value:
                            '${resumen.velocidadMaximaKmh.toStringAsFixed(1)} km/h',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _buildMetricLineBlock(
                        title: 'Vel Prom',
                        value:
                            '${resumen.velocidadPromedioKmh.toStringAsFixed(1)} km/h',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290),
            child: _buildRecorridoBlock(
              recorrido: '${resumen.recorridoKm.toStringAsFixed(2)} km',
              detalle:
                  '${resumen.tramosValidos} tramos validos | ${resumen.registrosHoy} registros hoy',
            ),
          ),
        ),
        SizedBox(height: spacing + 2),
        _buildStatsRow(
          leftTitle: 'Ciclos',
          leftValue: resumen.ciclos.toString(),
          rightTitle: 'Promedio ciclo tiempo',
          rightValue: _formatearMinutosDashboard(resumen.promedioCicloMin),
        ),
        const SizedBox(height: 12),
        _buildStatsRow(
          leftTitle: 'Max',
          leftValue: _formatearMinutosDashboard(resumen.maxCicloMin),
          rightTitle: 'Min',
          rightValue: _formatearMinutosDashboard(resumen.minCicloMin),
        ),
        const SizedBox(height: 12),
        _buildHorizontalDivider(),
        SizedBox(height: spacing),
        SizedBox(
          height: 176,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildHighlightedMetric(
                  title: 'Sobretiempo',
                  value: _formatearMinutosDashboard(
                    resumen.sobretiempoTotalMin,
                    sufijo: 'min',
                  ),
                  accent: Colors.white,
                  height: 176,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _buildStackLineBlock(
                        title: 'Pago de ineficiencia',
                        value: _formatearMontoDashboard(resumen.pagoIneficiencia),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _buildStackLineBlock(
                        title: 'Costo de ineficiencia',
                        value: _formatearMontoDashboard(
                          resumen.costoIneficiencia,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing),
        _buildMealTitle('Sobretiempos permitidos.'),
        const SizedBox(height: 8),
        _buildMealPair(
          almuerzo:
              'Total: ${resumen.sobretiempoPermitidoMin.toStringAsFixed(1)} min',
          desayuno: 'No separado',
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _colorNeutral800,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.orange, size: 42),
                const SizedBox(height: 12),
                const Text(
                  'No pudimos cargar este perfil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() {}),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorPrimary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopNameCard(_ResumenPerfilEquipo resumen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(
            resumen.nombreCorto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigValueTile({
    required String title,
    required String value,
    required Color accent,
    Color background = _colorSurfaceBlue,
    Color border = _colorNeutral700,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            background.withOpacity(0.38),
            background.withOpacity(0.24),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border.withOpacity(0.55), width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: accent,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideTile({
    required String title,
    required String value,
    String? subtitle,
    Color background = _colorSurfaceBlue,
    Color border = _colorNeutral700,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border.withOpacity(0.18), width: 1),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinePair({
    required String leftTitle,
    required String leftValue,
    required String rightTitle,
    required String rightValue,
    Color leftAccent = Colors.white,
    Color rightAccent = Colors.white,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildLineValue(
            title: leftTitle,
            value: leftValue,
            accent: leftAccent,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 1.2,
          height: 62,
          color: _colorDivider.withOpacity(0.9),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildLineValue(
            title: rightTitle,
            value: rightValue,
            accent: rightAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildLineValue({
    required String title,
    required String value,
    Color accent = Colors.white,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFD5C2A4),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: accent,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 0.95,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalDivider() {
    return Container(
      height: 2,
      color: _colorPrimary.withOpacity(0.92),
    );
  }

  Widget _buildHighlightedMetric({
    required String title,
    required String value,
    required Color accent,
    required double height,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF221E18),
            Color(0xFF141414),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _colorPrimarySoft.withOpacity(0.9), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD5C2A4),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: accent,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 0.95,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow({
    required String leftTitle,
    required String leftValue,
    required String rightTitle,
    required String rightValue,
  }) {
    return Column(
      children: [
        _buildHorizontalDivider(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLineValue(title: leftTitle, value: leftValue),
            ),
            Container(
              width: 1.5,
              height: 58,
              color: _colorPrimary.withOpacity(0.92),
            ),
            Expanded(
              child: _buildLineValue(title: rightTitle, value: rightValue),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleLineItem(String title, String value) {
    return Column(
      children: [
        Text(
          '$title: $value',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildHorizontalDivider(),
      ],
    );
  }

  Widget _buildStatusHeader({
    required String estado,
    required String conectadoDesdeTexto,
  }) {
    final accent = estado == 'ACTIVO'
        ? const Color(0xFF9BE7A4)
        : const Color(0xFFFF6B6B);

    return SizedBox(
      height: 70,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  estado,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: accent,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 0.95,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1.5,
            height: 64,
            color: _colorPrimary.withOpacity(0.92),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Desde',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD5C2A4),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  conectadoDesdeTexto,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricLineBlock({
    required String title,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD5C2A4),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFB648),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _buildHorizontalDivider(),
        ],
      ),
    );
  }

  Widget _buildRecorridoBlock({
    required String recorrido,
    required String detalle,
  }) {
    return Column(
      children: [
        const Text(
          'Recorrido',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _buildHorizontalDivider(),
        const SizedBox(height: 12),
        Text(
          recorrido,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          detalle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFD5C2A4),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildStackLineBlock({
    required String title,
    required String value,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        _buildHorizontalDivider(),
      ],
    );
  }

  Widget _buildMealTitle(String title) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFD5C2A4),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildHorizontalDivider(),
        ),
      ],
    );
  }

  Widget _buildMealPair({
    required String almuerzo,
    required String desayuno,
  }) {
    return Column(
      children: [
        Text(
          'Almuerzo: $almuerzo',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Desayuno: $desayuno',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroInfo(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        const Icon(Icons.analytics_outlined, color: Colors.orange),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required Color accent,
    Widget? footer,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 10,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: accent,
                  fontSize: 58,
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
          if (footer != null) ...[
            const SizedBox(height: 14),
            footer,
          ],
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(_ResumenPerfilEquipo resumen) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1F6788),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0A2230), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF174B64),
              borderRadius: BorderRadius.circular(18),
            ),
            child: resumen.latitud == null || resumen.longitud == null
                ? const Center(
                    child: Text(
                      'Sin coordenadas disponibles',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter:
                            ll.LatLng(resumen.latitud!, resumen.longitud!),
                        initialZoom: 16,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: ll.LatLng(
                                resumen.latitud!,
                                resumen.longitud!,
                              ),
                              width: 50,
                              height: 50,
                              child: const Icon(
                                Icons.local_shipping,
                                color: Colors.orange,
                                size: 34,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Ubicacion actual',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _buildCoordinateRow(
            'LAT',
            resumen.latitud == null
                ? '--'
                : resumen.latitud!.toStringAsFixed(6),
          ),
          _buildCoordinateRow(
            'LNG',
            resumen.longitud == null
                ? '--'
                : resumen.longitud!.toStringAsFixed(6),
          ),
          _buildCoordinateRow(
            'ALT',
            resumen.altitud == null || resumen.altitud!.isEmpty
                ? 'Sin dato'
                : '${resumen.altitud} msnm',
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool filled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 56,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: _colorPrimary,
          foregroundColor: const Color(0xFF121212),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: Color(0xFFFFD089), width: 3),
          elevation: 8,
          shadowColor: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildBottomSheetAction({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: _colorPrimary,
          foregroundColor: Colors.white,
          side: const BorderSide(color: _colorPrimarySoft, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _ResumenPerfilEquipo {
  const _ResumenPerfilEquipo({
    required this.nombreCorto,
    required this.nombreCompleto,
    required this.estado,
    required this.conectadoDesdeTexto,
    required this.velocidadActualKmh,
    required this.velocidadMaximaKmh,
    required this.velocidadPromedioKmh,
    required this.recorridoKm,
    required this.tramosValidos,
    required this.registrosHoy,
    required this.ultimoReporteTexto,
    required this.latitud,
    required this.longitud,
    required this.altitud,
    required this.ciclos,
    required this.promedioCicloMin,
    required this.modaCicloMin,
    required this.mediaCicloMin,
    required this.maxCicloMin,
    required this.minCicloMin,
    required this.sobretiempoTotalMin,
    required this.sobretiempoPermitidoMin,
    required this.pagoIneficiencia,
    required this.costoIneficiencia,
    required this.almuerzoDesayunoInfo,
    required this.tieneMuestraSuficiente,
  });

  final String nombreCorto;
  final String nombreCompleto;
  final String estado;
  final String conectadoDesdeTexto;
  final double velocidadActualKmh;
  final double velocidadMaximaKmh;
  final double velocidadPromedioKmh;
  final double recorridoKm;
  final int tramosValidos;
  final int registrosHoy;
  final String ultimoReporteTexto;
  final double? latitud;
  final double? longitud;
  final String? altitud;
  final int ciclos;
  final double? promedioCicloMin;
  final double? modaCicloMin;
  final double? mediaCicloMin;
  final double? maxCicloMin;
  final double? minCicloMin;
  final double? sobretiempoTotalMin;
  final double sobretiempoPermitidoMin;
  final double? pagoIneficiencia;
  final double? costoIneficiencia;
  final String almuerzoDesayunoInfo;
  final bool tieneMuestraSuficiente;
}
