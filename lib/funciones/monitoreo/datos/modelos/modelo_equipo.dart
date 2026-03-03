/// ============================================
/// MODELO EQUIPO - NUEVA ESTRUCTURA
/// ============================================
/// Adaptado para:
/// - UUID como id_equipo_control
/// - fk_empresa obligatorio
/// - Campo 'activo' en lugar de 'habilitado'
/// - Campo 'nombre' en lugar de 'nombre_equipo_control'
/// - Campo 'id_equipo_fabrica' para ID del celular
///
class ModeloEquipo {
  final String id;                  // id_equipo_control (UUID)
  final String? fkEmpresa;          // FK a empresas
  final String? fkSede;             // FK a sedes (opcional)
  final String? idEquipoFabrica;    // ID del dispositivo físico
  final String? tipoEquipo;
  final String? codigo;             // codigo_equipo_control
  final String? nombre;             // Antes era nombre_equipo_control
  final String? ubicacion;
  final String? direccionMac;
  final bool activo;                // Antes era habilitado
  final String? observaciones;
  final String? fkAreaAsociada;
  final String? fkEquipoAsociado;

  ModeloEquipo({
    required this.id,
    this.fkEmpresa,
    this.fkSede,
    this.idEquipoFabrica,
    this.tipoEquipo,
    this.codigo,
    this.nombre,
    this.ubicacion,
    this.direccionMac,
    this.activo = true,
    this.observaciones,
    this.fkAreaAsociada,
    this.fkEquipoAsociado,
  });

  /// Constructor desde JSON (respuesta de Supabase)
  factory ModeloEquipo.fromJson(Map<String, dynamic> json) {
    return ModeloEquipo(
      id: json['id_equipo_control']?.toString() ?? '',
      fkEmpresa: json['fk_empresa']?.toString(),
      fkSede: json['fk_sede']?.toString(),
      idEquipoFabrica: json['id_equipo_fabrica']?.toString(),
      tipoEquipo: json['tipo_equipo_control']?.toString(),
      codigo: json['codigo_equipo_control']?.toString(),
      nombre: json['nombre']?.toString(),
      ubicacion: json['ubicacion']?.toString(),
      direccionMac: json['direccion_mac']?.toString(),
      activo: json['activo'] == true,
      observaciones: json['observaciones']?.toString(),
      fkAreaAsociada: json['fk_area_asociada']?.toString(),
      fkEquipoAsociado: json['fk_equipo_asociado']?.toString(),
    );
  }

  /// Convertir a JSON para enviar a Supabase
  Map<String, dynamic> toJson() {
    return {
      'id_equipo_control': id,
      'fk_empresa': fkEmpresa,
      'fk_sede': fkSede,
      'id_equipo_fabrica': idEquipoFabrica,
      'tipo_equipo_control': tipoEquipo,
      'codigo_equipo_control': codigo,
      'nombre': nombre,
      'ubicacion': ubicacion,
      'direccion_mac': direccionMac,
      'activo': activo,
      'observaciones': observaciones,
      'fk_area_asociada': fkAreaAsociada,
      'fk_equipo_asociado': fkEquipoAsociado,
    };
  }

  /// Nombre para mostrar (preferencia: nombre > codigo > id)
  String get nombreMostrar {
    if (nombre != null && nombre!.isNotEmpty) return nombre!;
    if (codigo != null && codigo!.isNotEmpty) return codigo!;
    return id.substring(0, 8); // Primeros 8 caracteres del UUID
  }

  @override
  String toString() => 'ModeloEquipo($codigo - $nombre)';
}
