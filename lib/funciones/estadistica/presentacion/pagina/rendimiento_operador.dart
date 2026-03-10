import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TripAnalyticsResult {
  final double totalKm;
  final double idleHours;
  final double avgSpeedKmh;
  final int points;

  const TripAnalyticsResult({
    required this.totalKm,
    required this.idleHours,
    required this.avgSpeedKmh,
    required this.points,
  });

  factory TripAnalyticsResult.fromMap(Map<String, dynamic> map) {
    return TripAnalyticsResult(
      totalKm: (map['totalKm'] as num?)?.toDouble() ?? 0.0,
      idleHours: (map['idleHours'] as num?)?.toDouble() ?? 0.0,
      avgSpeedKmh: (map['avgSpeedKmh'] as num?)?.toDouble() ?? 0.0,
      points: (map['points'] as num?)?.toInt() ?? 0,
    );
  }
}

class TripAnalyticsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchPositions({
    required String fkEmisor,
    required DateTime date,
  }) async {
    final inicio = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final fin = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final resp = await _supabase
        .from('posiciones')
        .select('lat_grados, lon_grados, tiempo')
        .eq('fk_emisor', fkEmisor)
        .gte('tiempo', inicio.toIso8601String())
        .lte('tiempo', fin.toIso8601String())
        .order('tiempo', ascending: true);

    return List<Map<String, dynamic>>.from(resp);
  }
}

class TripAnalyticsProcessor {
  Future<TripAnalyticsResult> process(List<Map<String, dynamic>> points) async {
    final resultMap = await compute(_computeTripAnalytics, points);
    return TripAnalyticsResult.fromMap(resultMap);
  }
}

Map<String, dynamic> _computeTripAnalytics(List<Map<String, dynamic>> points) {
  if (points.isEmpty) {
    return {
      'totalKm': 0.0,
      'idleHours': 0.0,
      'avgSpeedKmh': 0.0,
      'points': 0,
    };
  }

  double totalDistanceMeters = 0.0;
  int idleSeconds = 0;
  int movingSeconds = 0;
  int totalSeconds = 0;

  double? prevLat;
  double? prevLon;
  DateTime? prevTime;

  for (final p in points) {
    final lat = (p['lat_grados'] as num?)?.toDouble();
    final lon = (p['lon_grados'] as num?)?.toDouble();
    final tiempoStr = p['tiempo']?.toString();

    if (lat == null || lon == null || tiempoStr == null) continue;
    if (lat == 0.0 || lon == 0.0) continue;

    final currentTime = DateTime.tryParse(tiempoStr);
    if (currentTime == null) continue;

    if (prevLat != null && prevLon != null && prevTime != null) {
      final deltaSeconds = currentTime.difference(prevTime).inSeconds;
      if (deltaSeconds > 0) {
        final dist = _haversineMeters(prevLat, prevLon, lat, lon);
        totalSeconds += deltaSeconds;

        if (dist < 2.0) {
          idleSeconds += deltaSeconds;
        } else {
          totalDistanceMeters += dist;
          movingSeconds += deltaSeconds;
        }
      }
    }

    prevLat = lat;
    prevLon = lon;
    prevTime = currentTime;
  }

  final totalKm = totalDistanceMeters / 1000.0;
  final idleHours = idleSeconds / 3600.0;
  final avgSpeedKmh = movingSeconds > 0
      ? totalKm / (movingSeconds / 3600.0)
      : 0.0;

  return {
    'totalKm': totalKm,
    'idleHours': idleHours,
    'avgSpeedKmh': avgSpeedKmh,
    'points': points.length,
  };
}

double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371000.0;
  final dLat = _degToRad(lat2 - lat1);
  final dLon = _degToRad(lon2 - lon1);

  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_degToRad(lat1)) *
          math.cos(_degToRad(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadius * c;
}

double _degToRad(double deg) => deg * (math.pi / 180.0);

class RendimientoOperador extends StatefulWidget {
  const RendimientoOperador({super.key});

  @override
  State<RendimientoOperador> createState() => _RendimientoOperadorState();
}

class _RendimientoOperadorState extends State<RendimientoOperador> {
  final _repo = TripAnalyticsRepository();
  final _processor = TripAnalyticsProcessor();
  final _fkController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _loading = false;
  String? _error;
  TripAnalyticsResult? _result;

  @override
  void dispose() {
    _fkController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Seleccionar fecha',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _runAnalytics() async {
    final fkEmisor = _fkController.text.trim();
    if (fkEmisor.isEmpty) {
      setState(() {
        _error = 'Ingresa un fk_emisor valido.';
        _result = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final positions = await _repo.fetchPositions(
        fkEmisor: fkEmisor,
        date: _selectedDate,
      );

      if (positions.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'No hay datos para ese dia y operador.';
        });
        return;
      }

      final stats = await _processor.process(positions);

      if (!mounted) return;
      setState(() {
        _loading = false;
        _result = stats;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Error procesando datos: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rendimiento Operador'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF121212),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: isWide ? 220 : constraints.maxWidth,
                      child: OutlinedButton(
                        onPressed: _selectDate,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                        child: Text('Fecha: $dateLabel'),
                      ),
                    ),
                    SizedBox(
                      width: isWide ? 280 : constraints.maxWidth,
                      child: TextField(
                        controller: _fkController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'fk_emisor',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.orange),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isWide ? 160 : constraints.maxWidth,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _runAnalytics,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Calcular'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(color: Colors.orange),
                    ),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                if (_result != null)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _metricCard(
                        title: 'Kilometros Totales',
                        value: '${_result!.totalKm.toStringAsFixed(2)} km',
                      ),
                      _metricCard(
                        title: 'Horas en Ralenti',
                        value: _result!.idleHours.toStringAsFixed(2),
                      ),
                      _metricCard(
                        title: 'Velocidad Promedio',
                        value: '${_result!.avgSpeedKmh.toStringAsFixed(1)} km/h',
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _metricCard({required String title, required String value}) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
