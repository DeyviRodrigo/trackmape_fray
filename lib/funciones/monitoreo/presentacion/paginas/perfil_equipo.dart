import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/core/utilidades/limpiador_trayectoria.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/modelos/modelo_equipo.dart';
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

class PaginaPerfilEquipo extends StatefulWidget {
  final ModeloEquipo equipo;
  const PaginaPerfilEquipo({super.key, required this.equipo});

  @override
  State<PaginaPerfilEquipo> createState() => _PaginaPerfilEquipoState();
}

class _PaginaPerfilEquipoState extends State<PaginaPerfilEquipo> {
  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();
  final LimpiadorTrayectoria _limpiador = const LimpiadorTrayectoria();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorNeutral900,
      appBar: AppBar(
        title: const Text('Perfil de Operador'),
        backgroundColor: _colorNeutral900,
        foregroundColor: _colorPrimary,
      ),
      body: FutureBuilder<_ResumenPerfilEquipo>(
        future: _cargarResumenPerfil(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          final resumen = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth - 28;
              final panelWidth = availableWidth.clamp(300.0, 360.0);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: panelWidth),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _colorNeutral800,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 18,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStructuredDashboard(
                            resumen,
                            panelWidth: panelWidth - 28,
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
    final hoy = DateTime.now();
    final resultados = await Future.wait([
      _repositorio.obtenerTrayectoriaPorFecha(hoy),
      _repositorio.streamUltimasConexiones().first,
    ]);

    final trayectoriasDia = (resultados[0] as List<Map<String, dynamic>>)
        .where((punto) => punto['fk_emisor']?.toString() == widget.equipo.id)
        .toList()
      ..sort((a, b) => a['tiempo'].toString().compareTo(b['tiempo'].toString()));

    final conexiones = (resultados[1] as List<Map<String, dynamic>>)
        .where((punto) => punto['fk_emisor']?.toString() == widget.equipo.id)
        .toList()
      ..sort((a, b) => a['tiempo'].toString().compareTo(b['tiempo'].toString()));

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

    var velocidadActual = 0.0;
    var velocidadMaxima = 0.0;
    var distanciaTotalKm = 0.0;
    var sumaVelocidades = 0.0;
    var tramosValidos = 0;

    for (var i = 1; i < puntosValidos.length; i++) {
      final anterior = _mapToPunto(puntosValidos[i - 1]);
      final actual = _mapToPunto(puntosValidos[i]);
      final velocidad = _limpiador.velocidadKmh(anterior, actual);
      final distancia = _limpiador.distanciaMetros(
        anterior.latitud,
        anterior.longitud,
        actual.latitud,
        actual.longitud,
      );

      if (velocidad.isNaN || velocidad.isInfinite) continue;
      if (velocidad > 120) continue;
      if (distancia < 2) continue;

      velocidadActual = velocidad;
      if (velocidad > velocidadMaxima) {
        velocidadMaxima = velocidad;
      }
      distanciaTotalKm += distancia / 1000;
      sumaVelocidades += velocidad;
      tramosValidos++;
    }

    final conectadoDesde = activo && puntosValidos.isNotEmpty
        ? DateTime.tryParse(puntosValidos.first['tiempo']?.toString() ?? '')
        : ultimoTiempo;

    return _ResumenPerfilEquipo(
      nombreCorto: _abreviarNombre(widget.equipo.nombreMostrar),
      nombreCompleto: widget.equipo.nombreMostrar,
      estado: activo ? 'ACTIVO' : 'INACTIVO',
      conectadoDesdeTexto: conectadoDesde == null
          ? 'Sin datos'
          : DateFormat('hh:mm a').format(conectadoDesde),
      velocidadActualKmh: velocidadActual,
      velocidadMaximaKmh: velocidadMaxima,
      velocidadPromedioKmh:
          tramosValidos == 0 ? 0.0 : (sumaVelocidades / tramosValidos),
      recorridoKm: distanciaTotalKm,
      tramosValidos: tramosValidos,
      registrosHoy: puntosValidos.length,
      ultimoReporteTexto: ultimoTiempo == null
          ? 'Sin GPS'
          : DateFormat('HH:mm:ss').format(ultimoTiempo),
      latitud: (ultimo?['lat_grados'] as num?)?.toDouble(),
      longitud: (ultimo?['lon_grados'] as num?)?.toDouble(),
      altitud: ultimo?['alt_msnm']?.toString(),
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

  void _abrirHistorico() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaginaHistorico(
          equipoIdFiltro: widget.equipo.id,
          nombreEquipoFiltro: widget.equipo.nombreMostrar,
        ),
      ),
    );
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
        _abrirHistorico();
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
    const spacing = 10.0;
    final stackedSmallWidth = (panelWidth * 0.37).clamp(108.0, 132.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTopNameCard(resumen),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                title: 'Estado',
                value: resumen.estado,
                accent:
                    resumen.estado == 'ACTIVO'
                        ? const Color(0xFF9BE7A4)
                        : const Color(0xFFFF6B6B),
                background:
                    resumen.estado == 'ACTIVO'
                        ? _colorSurfaceGreen
                        : const Color(0xFF4A1F24),
                border:
                    resumen.estado == 'ACTIVO'
                        ? _colorSecondary
                        : const Color(0xFFB23A48),
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              flex: 2,
              child: _buildInfoTile(
                title: 'Conectado desde',
                value: resumen.conectadoDesdeTexto,
                accent: Colors.white,
                background: _colorSurfaceDark,
                border: _colorPrimary.withOpacity(0.35),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        SizedBox(
          height: 158,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: _buildBigValueTile(
                  title: 'Velocidad',
                  value: '${resumen.velocidadActualKmh.toStringAsFixed(1)} km/h',
                  accent: _colorPrimary,
                  background: _colorSurfaceAmber,
                  border: _colorTertiary.withOpacity(0.5),
                ),
              ),
              SizedBox(width: spacing),
              SizedBox(
                width: stackedSmallWidth,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildCompactInfoTile(
                        title: 'Vel Max',
                        value:
                            '${resumen.velocidadMaximaKmh.toStringAsFixed(1)} km/h',
                        accent: Colors.white,
                        background: _colorSurfaceBlueAlt,
                        border: _colorPrimary.withOpacity(0.3),
                      ),
                    ),
                    SizedBox(height: spacing),
                    Expanded(
                      child: _buildCompactInfoTile(
                        title: 'Vel Prom',
                        value:
                            '${resumen.velocidadPromedioKmh.toStringAsFixed(1)} km/h',
                        accent: Colors.white,
                        background: _colorSurfaceBlue,
                        border: _colorPrimary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing),
        _buildWideTile(
          title: 'Recorrido',
          value: '${resumen.recorridoKm.toStringAsFixed(2)} km',
          subtitle:
              '${resumen.tramosValidos} tramos validos | ${resumen.registrosHoy} registros hoy',
          background: _colorSurfaceDark,
          border: _colorSecondary.withOpacity(0.35),
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                title: 'Ciclos',
                value: 'Sin dato',
                accent: Colors.white70,
                background: _colorSurfaceBlue,
                border: Colors.white10,
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _buildInfoTile(
                title: 'Promedio ciclo tiempo',
                value: 'Sin dato',
                accent: Colors.white70,
                background: _colorSurfaceBlueAlt,
                border: Colors.white10,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                title: 'Max',
                value: 'Sin dato',
                accent: Colors.white70,
                background: _colorSurfaceAmber,
                border: _colorTertiary.withOpacity(0.35),
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _buildInfoTile(
                title: 'Min',
                value: 'Sin dato',
                accent: Colors.white70,
                background: _colorSurfaceBlue,
                border: Colors.white10,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        SizedBox(
          height: 158,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: _buildBigValueTile(
                  title: 'Sobretiempo',
                  value: 'Sin dato',
                  accent: Colors.white70,
                  background: _colorSurfaceDark,
                  border: _colorPrimary.withOpacity(0.28),
                ),
              ),
              SizedBox(width: spacing),
              SizedBox(
                width: stackedSmallWidth,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildCompactInfoTile(
                        title: 'Pago de ineficiencia',
                        value: 'Sin dato',
                        accent: Colors.white70,
                        background: _colorSurfaceAmber,
                        border: _colorPrimary.withOpacity(0.45),
                      ),
                    ),
                    SizedBox(height: spacing),
                    Expanded(
                      child: _buildCompactInfoTile(
                        title: 'Costo de ineficiencia',
                        value: 'Sin dato',
                        accent: Colors.white70,
                        background: _colorSurfaceAmber,
                        border: _colorPrimary.withOpacity(0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing),
        _buildWideTile(
          title: 'Resumen operativo',
          value: 'Almuerzo: Sin dato',
          subtitle:
              'Desayuno: Sin dato\nSobretiempos permitidos: Sin dato',
          background: _colorSurfaceBlueAlt,
          border: _colorPrimary.withOpacity(0.28),
        ),
      ],
    );
  }

  Widget _buildTopNameCard(_ResumenPerfilEquipo resumen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_colorSurfaceBlueAlt, _colorSurfaceBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _colorPrimary.withOpacity(0.35), width: 1.4),
      ),
      child: Text(
        resumen.nombreCorto,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required Color accent,
    Color background = _colorSurfaceBlue,
    Color border = _colorNeutral700,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      constraints: const BoxConstraints(minHeight: 96),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: accent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoTile({
    required String title,
    required String value,
    required Color accent,
    Color background = _colorSurfaceBlue,
    Color border = _colorNeutral700,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            background.withOpacity(0.92),
            background,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
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
                fontSize: 26,
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
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.4),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
          backgroundColor:
              filled ? _colorPrimary : _colorNeutral700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side:
              filled
                  ? const BorderSide(color: _colorPrimarySoft, width: 1.2)
                  : const BorderSide(color: Colors.white12, width: 1.2),
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
}
