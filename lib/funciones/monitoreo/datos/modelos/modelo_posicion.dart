class ModeloPosicion {
  final int id;
  final DateTime tiempo;
  final String idEmisor;
  final double latitud;
  final double longitud;

  ModeloPosicion({
    required this.id,
    required this.tiempo,
    required this.idEmisor,
    required this.latitud,
    required this.longitud
  });

  // Mapeo exacto de tu tabla 'posiciones'
  factory ModeloPosicion.fromJson(Map<String, dynamic> json) => ModeloPosicion(
    id: json['id_posicion'],
    tiempo: DateTime.parse(json['tiempo']),
    idEmisor: json['fk_emisor'] ?? '',
    latitud: (json['lat_grados'] as num).toDouble(),
    longitud: (json['lon_grados'] as num).toDouble(),
  );
}