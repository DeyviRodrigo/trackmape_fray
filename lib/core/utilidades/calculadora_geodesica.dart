import 'dart:math' as math;

class CalculadoraGeodesica {
  /// Calcula la velocidad en km/h entre dos puntos
  static double calcularVelocidad(
      double lat1, double lon1, DateTime tiempo1,
      double lat2, double lon2, DateTime tiempo2,
      ) {
    // 1. Calcular distancia usando Haversine
    const double radioTierra = 6371; // Radio en kilómetros

    double dLat = _gradosARadianes(lat2 - lat1);
    double dLon = _gradosARadianes(lon2 - lon1);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_gradosARadianes(lat1)) * math.cos(_gradosARadianes(lat2)) *
            math.sin(dLon / 2) * math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distanciaEnKm = radioTierra * c;

    // 2. Calcular tiempo en horas
    double diferenciaTiempoHoras = tiempo2.difference(tiempo1).inSeconds / 3600;

    if (diferenciaTiempoHoras == 0) return 0.0;

    // 3. Velocidad = Distancia / Tiempo
    return (distanciaEnKm / diferenciaTiempoHoras).abs();
  }

  static double _gradosARadianes(double grados) => grados * (math.pi / 180);
}