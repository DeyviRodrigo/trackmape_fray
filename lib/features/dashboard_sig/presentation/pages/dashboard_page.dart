import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/dashboard_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardRepository _repository = DashboardRepository();
  late Future<DashboardMetrics> _futureMetrics;

  @override
  void initState() {
    super.initState();
    _futureMetrics = _repository.obtenerMetricas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark mode profundo
      appBar: AppBar(
        title: const Text('SIG Analítico', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.orange),
            onPressed: () {
              setState(() {
                _futureMetrics = _repository.obtenerMetricas();
              });
            },
          )
        ],
      ),
      body: FutureBuilder<DashboardMetrics>(
        future: _futureMetrics,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          }

          final metrics = snapshot.data!;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Rendimiento Operativo",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 20),
                
                // Indicadores Principales
                Row(
                  children: [
                    Expanded(
                      child: _buildIndicatorCard(
                        "Velocidad\nExcesiva",
                        "${metrics.excesosVelocidad}",
                        "Alertas",
                        Icons.speed,
                        Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildIndicatorCard(
                        "Motor en\nRalentí",
                        "${metrics.minutosRalenti}",
                        "Minutos",
                        Icons.cloud_off,
                        Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildIndicatorCard(
                        "Productividad\nRuta",
                        "${metrics.porcentajeEficiencia.toStringAsFixed(1)}",
                        "%",
                        Icons.timeline,
                        Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildIndicatorCard(
                        "Viajes\nTotales",
                        "${metrics.totalViajes}",
                        "Completados",
                        Icons.local_shipping,
                        Colors.orangeAccent,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                const Text(
                  "Impacto SIG (ISO)",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Gráfico Radar o de Barras
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const style = TextStyle(color: Colors.white70, fontSize: 10);
                              Widget text;
                              switch (value.toInt()) {
                                case 0: text = const Text('Seguridad\n(45001)', style: style, textAlign: TextAlign.center); break;
                                case 1: text = const Text('Ambiente\n(14001)', style: style, textAlign: TextAlign.center); break;
                                case 2: text = const Text('Calidad\n(9001)', style: style, textAlign: TextAlign.center); break;
                                default: text = const Text('', style: style); break;
                              }
                              return SideTitleWidget(meta: meta, space: 10, child: text);
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        _buildBar(0, 100 - (metrics.excesosVelocidad * 10).toDouble().clamp(0, 100), Colors.redAccent), // ISO 45001 Score
                        _buildBar(1, 100 - (metrics.minutosRalenti * 2).toDouble().clamp(0, 100), Colors.blueAccent),  // ISO 14001 Score
                        _buildBar(2, metrics.porcentajeEficiencia, Colors.greenAccent),  // ISO 9001 Score
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  BarChartGroupData _buildBar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 25,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: const Color(0xFF2A2A2A),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorCard(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.2),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  unit,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
