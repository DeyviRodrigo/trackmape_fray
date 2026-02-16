class ModeloEquipo {
  final String id;
  final String nombre;
  final String tipo;
  final String codigo;
  final double latitud;
  final double longitud;
  final String estado;
  // --- CAMPO NUEVO INTEGRADO ---
  final bool habilitado;

  ModeloEquipo({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.codigo,
    required this.latitud,
    required this.longitud,
    required this.estado,
    required this.habilitado, // Lo añadimos al constructor
  });

  factory ModeloEquipo.fromJson(Map<String, dynamic> json) => ModeloEquipo(
    id: json['id_equipo_control'].toString(),
    nombre: json['nombre_equipo_control'] ?? 'Sin Nombre',
    tipo: json['tipo_equipo_control'] ?? 'General',
    codigo: json['codigo_equipo_control'] ?? '',
    latitud: (json['latitud'] ?? 0.0).toDouble(),
    longitud: (json['longitud'] ?? 0.0).toDouble(),
    estado: json['estado'] ?? 'Desconectado',
    // Mapeamos el campo habilitado de la base de datos (bool)
    habilitado: json['habilitado'] ?? true,
  );

  // Añadimos un copyWith para facilitar la edición en la página de perfil
  ModeloEquipo copyWith({
    String? nombre,
    String? codigo,
    bool? habilitado,
  }) {
    return ModeloEquipo(
      id: id,
      nombre: nombre ?? this.nombre,
      tipo: tipo,
      codigo: codigo ?? this.codigo,
      latitud: latitud,
      longitud: longitud,
      estado: estado,
      habilitado: habilitado ?? this.habilitado,
    );
  }
}