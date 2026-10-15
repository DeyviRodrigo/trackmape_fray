import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const _background = Color(0xFF07111B);
  static const _panel = Color(0xFF0D1A27);
  static const _panelSoft = Color(0xFF101F2E);
  static const _border = Color(0x1AFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 980;
          final padding = isWide ? 24.0 : 14.0;
          final contentWidth = constraints.maxWidth - padding * 2;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(padding, 18, padding, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 16),
                _topCards(contentWidth),
                const SizedBox(height: 16),
                _responsiveSplit(
                  isWide: isWide,
                  leftFlex: 6,
                  rightFlex: 4,
                  left: _routePanel(),
                  right: _stopsPanel(),
                ),
                const SizedBox(height: 16),
                _categoryCards(contentWidth),
                const SizedBox(height: 16),
                _responsiveSplit(
                  isWide: isWide,
                  leftFlex: 7,
                  rightFlex: 5,
                  left: _indicatorsPanel(contentWidth),
                  right: _sigPanel(),
                ),
                const SizedBox(height: 16),
                _responsiveSplit(
                  isWide: isWide,
                  leftFlex: 7,
                  rightFlex: 5,
                  left: _alertsPanel(),
                  right: _fleetPanel(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header() {
    return _panelBox(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.blueAccent.withValues(alpha: 0.5),
              ),
            ),
            child: const Icon(
              Icons.dashboard_customize,
              color: Colors.blueAccent,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BUS UNAJ - 01',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _StatusText(
                      color: Colors.lightGreenAccent,
                      text: 'En ruta',
                    ),
                    _MiniMeta(
                      icon: Icons.route,
                      text: 'Ruta Biblioteca Central',
                    ),
                    _MiniMeta(icon: Icons.schedule, text: 'Actualizado 09:25'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.notifications_none, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _topCards(double maxWidth) {
    final width = _cardWidth(maxWidth, minWidth: 190, gap: 12);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _metricCard(
          width: width,
          title: 'Velocidad actual',
          value: '48',
          unit: 'km/h',
          icon: Icons.speed,
          color: Colors.blueAccent,
          detail: 'Dentro de limite',
        ),
        _metricCard(
          width: width,
          title: 'Velocidad maxima',
          value: '72',
          unit: 'km/h',
          icon: Icons.network_check,
          color: Colors.redAccent,
          detail: 'Limite: 60 km/h',
        ),
        _metricCard(
          width: width,
          title: 'Combustible',
          value: '58',
          unit: '%',
          icon: Icons.local_gas_station,
          color: Colors.lightGreenAccent,
          detail: 'Est. restante 96 km',
        ),
        _metricCard(
          width: width,
          title: 'Tiempo detenido',
          value: '00:18',
          unit: '',
          icon: Icons.timer_outlined,
          color: Colors.orangeAccent,
          detail: 'Detenciones > 5 min: 1',
        ),
      ],
    );
  }

  Widget _routePanel() {
    return _sectionPanel(
      title: 'Ubicacion en tiempo real',
      action: 'Ver mapa completo',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 220, child: _RoutePreview()),
          SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _MetaItem(
                icon: Icons.route,
                title: 'Km recorridos',
                value: '18.4 km',
                color: Colors.lightBlueAccent,
              ),
              _MetaItem(
                icon: Icons.alt_route,
                title: 'Desvios de ruta',
                value: '1 hoy',
                color: Colors.orangeAccent,
              ),
              _MetaItem(
                icon: Icons.social_distance,
                title: 'Mayor desvio',
                value: '142 m',
                color: Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stopsPanel() {
    return Column(
      children: [
        _sectionPanel(
          title: 'Proxima parada',
          action: '+1 min',
          child: const Row(
            children: [
              _CircleIcon(icon: Icons.directions_bus),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biblioteca Central',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('ETA 2 min', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sectionPanel(
          title: 'Llegadas a paradas',
          action: 'Ver todas',
          child: const Column(
            children: [
              _StopRow(nombre: 'Terminal', hora: '07:00', diferencia: '+1 min'),
              _StopRow(nombre: 'Facultad', hora: '07:08', diferencia: '+1 min'),
              _StopRow(
                nombre: 'Biblioteca',
                hora: '07:16',
                diferencia: '-1 min',
              ),
              _StopRow(
                nombre: 'Polideportivo',
                hora: '07:24',
                diferencia: '+1 min',
              ),
              _StopRow(nombre: 'Campus', hora: '07:32', diferencia: '-1 min'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _categoryCards(double maxWidth) {
    final width = _cardWidth(maxWidth, minWidth: 270, gap: 12);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _categoryCard(
          width: width,
          title: 'Checklist',
          subtitle: 'Preoperacional',
          scoreText: '100%',
          progress: 1,
          icon: Icons.fact_check,
          color: Colors.lightGreenAccent,
          lines: const [
            'Documentacion verificada',
            'Luces, frenos y neumaticos OK',
            'Equipo de emergencia OK',
          ],
        ),
        _categoryCard(
          width: width,
          title: 'Calidad',
          subtitle: 'Puntualidad, ruta y continuidad',
          scoreText: '96%',
          progress: 0.96,
          icon: Icons.verified_user,
          color: Colors.blueAccent,
          lines: const [
            'Puntualidad promedio: +1 min',
            'Cumplimiento de ruta: 99.2%',
            'Funcionamiento: 6/7 dias',
          ],
        ),
        _categoryCard(
          width: width,
          title: 'Ambiente',
          subtitle: 'Consumo y emisiones',
          scoreText: '82%',
          progress: 0.82,
          icon: Icons.eco,
          color: Colors.greenAccent,
          lines: const [
            'Consumo de combustible: 18.2 L',
            'Emisiones estimadas: 48.8 kg CO2',
            'Rendimiento: 2.31 km/L',
          ],
        ),
        _categoryCard(
          width: width,
          title: 'Seguridad',
          subtitle: 'Velocidad, incidentes y estado',
          scoreText: '78%',
          progress: 0.78,
          icon: Icons.health_and_safety,
          color: Colors.redAccent,
          lines: const [
            'Excesos de velocidad: 6',
            'Incidentes / averias: 1',
            'Estado del vehiculo: Operativo',
          ],
        ),
      ],
    );
  }

  Widget _indicatorsPanel(double maxWidth) {
    final width = _cardWidth(
      maxWidth >= 980 ? maxWidth * 0.58 : maxWidth,
      minWidth: 150,
      gap: 10,
    );
    return _sectionPanel(
      title: 'Indicadores principales',
      action: 'Ejemplo',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _indicatorTile(
            width: width,
            title: 'Cumplimiento de ruta',
            value: '99.2%',
            detail: 'Estable',
            icon: Icons.shield,
            color: Colors.lightGreenAccent,
            progress: 0.99,
          ),
          _indicatorTile(
            width: width,
            title: 'Excesos velocidad',
            value: '6',
            detail: '+2 vs ayer',
            icon: Icons.speed,
            color: Colors.redAccent,
            progress: 0.62,
          ),
          _indicatorTile(
            width: width,
            title: 'Desvios de ruta',
            value: '1',
            detail: '142 m',
            icon: Icons.alt_route,
            color: Colors.orangeAccent,
            progress: 0.32,
          ),
          _indicatorTile(
            width: width,
            title: 'Consumo hoy',
            value: '18.2 L',
            detail: '2.31 km/L',
            icon: Icons.local_gas_station,
            color: Colors.lightGreenAccent,
            progress: 0.58,
          ),
          _indicatorTile(
            width: width,
            title: 'Tiempo detenido',
            value: '1',
            detail: '> 5 min',
            icon: Icons.timer_outlined,
            color: Colors.orangeAccent,
            progress: 0.42,
          ),
          _indicatorTile(
            width: width,
            title: 'Estado vehiculo',
            value: 'Operativo',
            detail: 'Checklist 100%',
            icon: Icons.check_circle,
            color: Colors.lightGreenAccent,
            progress: 1,
          ),
        ],
      ),
    );
  }

  Widget _sigPanel() {
    return _sectionPanel(
      title: 'Tablero SIG',
      action: 'Ejemplo',
      child: const Column(
        children: [
          _ScoreRow(
            title: 'Checklist preoperacional',
            value: '100%',
            progress: 1,
            color: Colors.lightGreenAccent,
          ),
          _ScoreRow(
            title: 'Calidad ISO 9001',
            value: '96%',
            progress: 0.96,
            color: Colors.blueAccent,
          ),
          _ScoreRow(
            title: 'Ambiente ISO 14001',
            value: '82%',
            progress: 0.82,
            color: Colors.greenAccent,
          ),
          _ScoreRow(
            title: 'Seguridad ISO 45001',
            value: '78%',
            progress: 0.78,
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _alertsPanel() {
    return _sectionPanel(
      title: 'Alertas activas',
      action: 'Ver todas',
      child: const Column(
        children: [
          _AlertRow(
            icon: Icons.speed,
            title: 'Exceso de velocidad',
            detail: '09:13 - 76 km/h en zona 60 km/h',
            label: 'Alta',
            color: Colors.redAccent,
          ),
          _AlertRow(
            icon: Icons.warning_amber_rounded,
            title: 'Desvio de ruta',
            detail: '08:46 - Fuera de ruta: 142 metros',
            label: 'Media',
            color: Colors.orangeAccent,
          ),
          _AlertRow(
            icon: Icons.timer_outlined,
            title: 'Detencion prolongada',
            detail: '08:30 - Detenido por 7 min',
            label: 'Media',
            color: Colors.orangeAccent,
          ),
          _AlertRow(
            icon: Icons.info_outline,
            title: 'Sin movimiento',
            detail: '08:05 - Motor encendido por 10 min',
            label: 'Baja',
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Widget _fleetPanel() {
    return _sectionPanel(
      title: 'Estado de flota',
      action: 'Operativo',
      child: const Column(
        children: [
          _FleetRow(
            icon: Icons.directions_bus_filled,
            title: 'Vehiculos activos',
            value: '1/1',
          ),
          _FleetRow(
            icon: Icons.signal_cellular_connected_no_internet_4_bar,
            title: 'Sin senal reciente',
            value: '0',
          ),
          _FleetRow(
            icon: Icons.event_busy,
            title: 'Dias que no trabaja',
            value: '0',
          ),
          _FleetRow(
            icon: Icons.report_problem,
            title: 'Incidentes + averias',
            value: '1',
          ),
        ],
      ),
    );
  }

  Widget _responsiveSplit({
    required bool isWide,
    required int leftFlex,
    required int rightFlex,
    required Widget left,
    required Widget right,
  }) {
    if (!isWide) {
      return Column(children: [left, const SizedBox(height: 16), right]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: leftFlex, child: left),
        const SizedBox(width: 16),
        Expanded(flex: rightFlex, child: right),
      ],
    );
  }

  Widget _sectionPanel({
    required String title,
    required String action,
    required Widget child,
  }) {
    return _panelBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                action,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _panelBox({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _metricCard({
    required double width,
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required String detail,
  }) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 130),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(icon, color: color, size: 26),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: value.length > 6 ? 24 : 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    unit,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard({
    required double width,
    required String title,
    required String subtitle,
    required String scoreText,
    required double progress,
    required IconData icon,
    required Color color,
    required List<String> lines,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                scoreText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: scoreText.length > 4 ? 18 : 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: color,
              backgroundColor: Colors.white12,
            ),
          ),
          const SizedBox(height: 12),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: color, size: 15),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      line,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _indicatorTile({
    required double width,
    required String title,
    required String value,
    required String detail,
    required IconData icon,
    required Color color,
    double progress = 0,
    bool filled = false,
  }) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(height: 9),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: filled ? color : Colors.white,
              fontSize: value.length > 6 ? 19 : 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 12),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: filled ? 1 : progress,
              minHeight: 5,
              color: color,
              backgroundColor: Colors.white10,
            ),
          ),
        ],
      ),
    );
  }

  double _cardWidth(
    double maxWidth, {
    required double minWidth,
    required double gap,
  }) {
    final available = maxWidth - 28;
    if (available >= minWidth * 4 + gap * 3) {
      return (available - gap * 3) / 4;
    }
    if (available >= minWidth * 3 + gap * 2) {
      return (available - gap * 2) / 3;
    }
    if (available >= minWidth * 2 + gap) {
      return (available - gap) / 2;
    }
    return available;
  }
}

class _StatusText extends StatelessWidget {
  final Color color;
  final String text;

  const _StatusText({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}

class _MiniMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniMeta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white54, size: 15),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;

  const _CircleIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blueAccent, width: 2),
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _MetaItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  final String nombre;
  final String hora;
  final String diferencia;

  const _StopRow({
    required this.nombre,
    required this.hora,
    required this.diferencia,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: const BoxDecoration(
              color: Colors.white38,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: Text(
              hora,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 58,
            child: Text(
              diferencia,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.lightGreenAccent,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final Color color;

  const _ScoreRow({
    required this.title,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              Text(
                value,
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              color: color,
              backgroundColor: Colors.white12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final String label;
  final Color color;

  const _AlertRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 76,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.45)),
            ),
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _FleetRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _FleetRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePreview extends StatelessWidget {
  const _RoutePreview();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RoutePreviewPainter(),
      child: Stack(
        children: [
          Positioned(right: 12, top: 12, child: _mapButton(Icons.my_location)),
          Positioned(right: 12, top: 62, child: _mapButton(Icons.layers)),
        ],
      ),
    );
  }

  Widget _mapButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1420).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _RoutePreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFF0B1824);
    final border = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, background);
    canvas.drawRRect(rect, border);

    _drawGrid(canvas, size);

    final points = <Offset>[
      Offset(size.width * 0.08, size.height * 0.76),
      Offset(size.width * 0.16, size.height * 0.54),
      Offset(size.width * 0.30, size.height * 0.48),
      Offset(size.width * 0.42, size.height * 0.34),
      Offset(size.width * 0.56, size.height * 0.42),
      Offset(size.width * 0.66, size.height * 0.26),
      Offset(size.width * 0.78, size.height * 0.38),
      Offset(size.width * 0.88, size.height * 0.64),
    ];

    final okPaint = Paint()
      ..color = Colors.lightGreenAccent.withValues(alpha: 0.86)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final warningPaint = Paint()
      ..color = Colors.orangeAccent
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final dangerPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var index = 0; index < points.length - 1; index++) {
      final paint = index == 4
          ? warningPaint
          : index >= 5
          ? dangerPaint
          : okPaint;
      canvas.drawLine(points[index], points[index + 1], paint);
    }

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final fill = Paint()..color = const Color(0xFF123A6A);
      final outline = Paint()
        ..color = Colors.white38
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;

      final isCurrent = index == 4;
      if (isCurrent) {
        canvas.drawCircle(
          point,
          26,
          Paint()..color = Colors.blueAccent.withValues(alpha: 0.18),
        );
        canvas.drawCircle(point, 20, Paint()..color = Colors.blueAccent);
        _drawBusIcon(canvas, point, 10);
      } else {
        canvas.drawCircle(point, 11, fill);
        canvas.drawCircle(point, 11, outline);
        _drawBusIcon(canvas, point, 7);
      }
    }

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Ruta UNAJ - ejemplo',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(16, size.height - textPainter.height - 16),
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;

    for (var x = 20.0; x < size.width; x += 38) {
      canvas.drawLine(Offset(x, 0), Offset(x - 30, size.height), paint);
    }
    for (var y = 18.0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 18), paint);
    }
  }

  void _drawBusIcon(Canvas canvas, Offset center, double size) {
    final bodyPaint = Paint()..color = Colors.white70;
    final windowPaint = Paint()..color = const Color(0xFF123A6A);

    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: size * 1.35, height: size * 1.55),
      Radius.circular(size * 0.18),
    );
    canvas.drawRRect(body, bodyPaint);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - size * 0.18),
        width: size * 0.86,
        height: size * 0.45,
      ),
      windowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RoutePreviewPainter oldDelegate) => false;
}
