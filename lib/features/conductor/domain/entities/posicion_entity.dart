class PosicionEntity {
  final double latitud;
  final double longitud;
  final double altitud;
  final double velocidad;
  final double rumbo;
  final DateTime tiempo;

  PosicionEntity({
    required this.latitud,
    required this.longitud,
    required this.altitud,
    required this.velocidad,
    required this.rumbo,
    required this.tiempo,
  });
}
