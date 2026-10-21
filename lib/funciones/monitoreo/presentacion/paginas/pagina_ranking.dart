import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/modelos/modelo_equipo.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';
import 'package:trackmape_sup/funciones/monitoreo/dominio/servicios/servicio_metricas_operador.dart';

class PaginaRanking extends StatefulWidget {
  const PaginaRanking({super.key});

  @override
  State<PaginaRanking> createState() => _PaginaRankingState();
}

class _PaginaRankingState extends State<PaginaRanking> {
  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();
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
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'RANKING OPERATIVO',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _seleccionarFecha,
            icon: const Icon(Icons.calendar_month, color: Colors.orange),
            label: Text(
              DateFormat('dd/MM/yyyy').format(_fechaConsulta),
              style: const TextStyle(color: Colors.orange),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<_RankingVista>(
        future: _cargarRanking(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          if (snapshot.hasError) {
            return _buildEstado(
              'No se pudo cargar el ranking.\n${snapshot.error}',
            );
          }

          final vista = snapshot.data;
          if (vista == null) {
            return _buildEstado('No hay datos disponibles para esta fecha.');
          }

          if (vista.volquetes.isEmpty && vista.cargadores.isEmpty) {
            return _buildEstado('No encontramos operadores con datos ese día.');
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildResumenHeader(vista),
              const SizedBox(height: 16),
              if (vista.volquetes.isNotEmpty) ...[
                _buildSectionTitle(
                  'Volquetes',
                  'Más ciclos, menor tiempo de ciclo y menos sobretiempo',
                ),
                const SizedBox(height: 10),
                ...vista.volquetes.asMap().entries.map(
                      (entry) => _buildRankingCard(
                        item: entry.value,
                        posicion: entry.key + 1,
                        esVolquete: true,
                      ),
                    ),
                const SizedBox(height: 20),
              ],
              if (vista.cargadores.isNotEmpty) ...[
                _buildSectionTitle(
                  'Cargadores',
                  'Ordenados por recorrido, actividad y velocidad promedio',
                ),
                const SizedBox(height: 10),
                ...vista.cargadores.asMap().entries.map(
                      (entry) => _buildRankingCard(
                        item: entry.value,
                        posicion: entry.key + 1,
                        esVolquete: false,
                      ),
                    ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaConsulta,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Seleccionar fecha del ranking',
    );

    if (!mounted || seleccionada == null) return;

    setState(() {
      _fechaConsulta = DateTime(
        seleccionada.year,
        seleccionada.month,
        seleccionada.day,
      );
    });
  }

  Future<_RankingVista> _cargarRanking() async {
    final equiposRaw = await _repositorio.obtenerEquiposRaw(
      soloCodigosConPrefijoExclamacion: true,
    );
    final equipos = equiposRaw
        .map(ModeloEquipo.fromJson)
        .where(
          (equipo) =>
              (equipo.tipoEquipo?.trim() ?? '') ==
              RepositorioMonitoreo.tipoEquipoSeeedWioTrackerL1,
        )
        .toList();

    final trayectoria = await _repositorio.obtenerTrayectoriaPorFecha(
      _fechaConsulta,
    );
    final puntosDelDia = [...trayectoria];

    if (_esMismoDia(_fechaConsulta, DateTime.now())) {
      final conexiones = await _repositorio.obtenerUltimasPosiciones();
      for (final conexion in conexiones) {
        final id = conexion['fk_emisor']?.toString();
        final tiempo = conexion['tiempo']?.toString();
        final existe = puntosDelDia.any(
          (punto) =>
              punto['fk_emisor']?.toString() == id &&
              punto['tiempo']?.toString() == tiempo,
        );
        if (!existe) {
          puntosDelDia.add(conexion);
        }
      }
    }

    final puntosPorEquipo = <String, List<Map<String, dynamic>>>{};
    for (final punto in puntosDelDia) {
      final id = punto['fk_emisor']?.toString();
      if (id == null || id.isEmpty) continue;
      puntosPorEquipo.putIfAbsent(id, () => []);
      puntosPorEquipo[id]!.add(punto);
    }

    final items = <_RankingItem>[];
    for (final equipo in equipos) {
      final puntos = puntosPorEquipo[equipo.id] ?? const [];
      if (puntos.isEmpty) continue;

      puntos.sort(
        (a, b) => a['tiempo'].toString().compareTo(b['tiempo'].toString()),
      );

      final resultado = _servicioMetricas.procesarDatosUnidad(
        equipo: equipo,
        puntosCrudos: puntos,
      );

      final item = _RankingItem(
        equipo: equipo,
        metricas: resultado.metricas,
        resumen: resultado.resumenMovimiento,
        puntosProcesados: puntos.length,
      );

      items.add(item);
    }

    final volquetes = items.where((item) => item.esVolquete).toList()
      ..sort(_compararVolquetes);
    final cargadores = items.where((item) => item.esCargador).toList()
      ..sort(_compararCargadores);

    return _RankingVista(
      fecha: _fechaConsulta,
      volquetes: volquetes,
      cargadores: cargadores,
    );
  }

  int _compararVolquetes(_RankingItem a, _RankingItem b) {
    final porCiclos = b.metricas.ciclos.compareTo(a.metricas.ciclos);
    if (porCiclos != 0) return porCiclos;

    final aProm = a.metricas.promedioCicloMin ?? double.infinity;
    final bProm = b.metricas.promedioCicloMin ?? double.infinity;
    final porPromedio = aProm.compareTo(bProm);
    if (porPromedio != 0) return porPromedio;

    final aSobre = a.metricas.sobretiempoTotalMin ?? double.infinity;
    final bSobre = b.metricas.sobretiempoTotalMin ?? double.infinity;
    final porSobretiempo = aSobre.compareTo(bSobre);
    if (porSobretiempo != 0) return porSobretiempo;

    return b.resumen.recorridoKm.compareTo(a.resumen.recorridoKm);
  }

  int _compararCargadores(_RankingItem a, _RankingItem b) {
    final porRecorrido = b.resumen.recorridoKm.compareTo(a.resumen.recorridoKm);
    if (porRecorrido != 0) return porRecorrido;

    final porVelocidad =
        b.resumen.velocidadPromedioKmh.compareTo(a.resumen.velocidadPromedioKmh);
    if (porVelocidad != 0) return porVelocidad;

    return b.resumen.tramosValidos.compareTo(a.resumen.tramosValidos);
  }

  bool _esMismoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildEstado(String texto) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildResumenHeader(_RankingVista vista) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ranking del ${DateFormat('dd/MM/yyyy').format(vista.fecha)}',
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${vista.volquetes.length} volquetes | ${vista.cargadores.length} cargadores',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildRankingCard({
    required _RankingItem item,
    required int posicion,
    required bool esVolquete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: posicion == 1 ? Colors.orange : Colors.white12,
          width: posicion == 1 ? 1.6 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.orange.withOpacity(0.14),
                child: Text(
                  '$posicion',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.equipo.nombreMostrar,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      esVolquete ? 'Volquete' : 'Cargador',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (esVolquete)
                _buildBadge('${item.metricas.ciclos} ciclos')
              else
                _buildBadge('${item.resumen.recorridoKm.toStringAsFixed(1)} km'),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildMetricChip(
                'Recorrido',
                '${item.resumen.recorridoKm.toStringAsFixed(2)} km',
              ),
              _buildMetricChip(
                'Vel Prom',
                '${item.resumen.velocidadPromedioKmh.toStringAsFixed(1)} km/h',
              ),
              _buildMetricChip(
                'Vel Max',
                '${item.resumen.velocidadMaximaKmh.toStringAsFixed(1)} km/h',
              ),
              _buildMetricChip(
                'Tramos',
                '${item.resumen.tramosValidos}',
              ),
              if (esVolquete) ...[
                _buildMetricChip(
                  'Prom ciclo',
                  _formatearMin(item.metricas.promedioCicloMin),
                ),
                _buildMetricChip(
                  'Min',
                  _formatearMin(item.metricas.minCicloMin),
                ),
                _buildMetricChip(
                  'Max',
                  _formatearMin(item.metricas.maxCicloMin),
                ),
                _buildMetricChip(
                  'Sobretiempo',
                  _formatearMin(item.metricas.sobretiempoTotalMin),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.orange.withOpacity(0.45)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatearMin(double? valor) {
    if (valor == null) return 'Sin dato';
    return '${valor.toStringAsFixed(1)} min';
  }
}

class _RankingVista {
  const _RankingVista({
    required this.fecha,
    required this.volquetes,
    required this.cargadores,
  });

  final DateTime fecha;
  final List<_RankingItem> volquetes;
  final List<_RankingItem> cargadores;
}

class _RankingItem {
  const _RankingItem({
    required this.equipo,
    required this.metricas,
    required this.resumen,
    required this.puntosProcesados,
  });

  final ModeloEquipo equipo;
  final MetricasOperadorDiarias metricas;
  final ResumenMovimientoOperador resumen;
  final int puntosProcesados;

  bool get esVolquete => _descriptor.contains('VOLQUETE');
  bool get esCargador => _descriptor.contains('CARGADOR');

  String get _descriptor =>
      '${equipo.tipoEquipo ?? ''} ${equipo.nombre ?? ''} ${equipo.codigo ?? ''}'
          .toUpperCase();
}
