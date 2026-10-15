import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardMetrics {
  final int excesosVelocidad;
  final int minutosRalenti;
  final double porcentajeEficiencia;
  final int totalViajes;

  DashboardMetrics({
    required this.excesosVelocidad,
    required this.minutosRalenti,
    required this.porcentajeEficiencia,
    required this.totalViajes,
  });
}

class DashboardRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<DashboardMetrics> obtenerMetricas() async {
    try {
      // Obtenemos todas las posiciones de prueba (idealmente de las últimas 24h)
      final response = await _supabase
          .from('posiciones')
          .select()
          .order('tiempo', ascending: true);

      final posiciones = List<Map<String, dynamic>>.from(response);

      if (posiciones.isEmpty) {
        return DashboardMetrics(
          excesosVelocidad: 0,
          minutosRalenti: 0,
          porcentajeEficiencia: 0,
          totalViajes: 0,
        );
      }

      int excesos = 0;
      int conteoRalenti = 0;
      int conteoMovimiento = 0;

      for (var pos in posiciones) {
        final double velocidad = (pos['velocidad'] as num?)?.toDouble() ?? 0.0;

        // Entornos Mineros (Conversión a metros por segundo m/s)
        // Límite de 30 km/h = 8.33 m/s
        const double limiteMinaMs = 8.33;
        // Ralentí menor a 2 km/h = 0.55 m/s (filtra el "ruido" del GPS estático)
        const double limiteRalentiMs = 0.55;

        // ISO 45001: Seguridad (Más de 30 km/h en mina)
        if (velocidad > limiteMinaMs) {
          excesos++;
        }

        // ISO 14001: Medio Ambiente (Velocidad menor a 2 km/h se considera detenido/ralentí)
        // Por cada registro (asumimos cada 5 min de prueba), sumamos 5 mins
        if (velocidad < limiteRalentiMs) {
          conteoRalenti++;
        } else {
          conteoMovimiento++;
        }
      }

      // ISO 9001: Calidad y Productividad (% del tiempo en movimiento)
      final int totalRegistros = posiciones.length;
      final double eficiencia = (conteoMovimiento / totalRegistros) * 100;

      return DashboardMetrics(
        excesosVelocidad: excesos,
        minutosRalenti: conteoRalenti * 5, // Estimado de 5 mins por registro para la prueba
        porcentajeEficiencia: eficiencia,
        totalViajes: 1, // En una app real, agruparíamos por jornada
      );
    } catch (e) {
      print("Error obteniendo métricas: $e");
      return DashboardMetrics(
        excesosVelocidad: 0,
        minutosRalenti: 0,
        porcentajeEficiencia: 0,
        totalViajes: 0,
      );
    }
  }
}
