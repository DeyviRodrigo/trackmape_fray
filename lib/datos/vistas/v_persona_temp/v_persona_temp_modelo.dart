// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class VPersonaTempModelo implements ModeloContrato {
  final String id_persona;
  final String id_trabajador;
  final String nombres;
  final String apellido_paterno;
  final String? apellido_materno;
  final DateTime? fecha_nacimiento;
  final String? genero;
  final bool activo;
  final String? pais_nombre;
  final String? documento_numero;
  final String? documento_tipo;
  final String? empresa_nombre;

  const VPersonaTempModelo({
    required this.id_persona,
    required this.id_trabajador,
    required this.nombres,
    required this.apellido_paterno,
    this.apellido_materno,
    this.fecha_nacimiento,
    this.genero,
    required this.activo,
    this.pais_nombre,
    this.documento_numero,
    this.documento_tipo,
    this.empresa_nombre,
  });

  @override
  VPersonaTempModelo copyWith({
    String? id_persona,
    String? id_trabajador,
    String? nombres,
    String? apellido_paterno,
    String? apellido_materno,
    DateTime? fecha_nacimiento,
    String? genero,
    bool? activo,
    String? pais_nombre,
    String? documento_numero,
    String? documento_tipo,
    String? empresa_nombre,
  }) {
    return VPersonaTempModelo(
      id_persona: id_persona ?? this.id_persona,
      id_trabajador: id_trabajador ?? this.id_trabajador,
      nombres: nombres ?? this.nombres,
      apellido_paterno: apellido_paterno ?? this.apellido_paterno,
      apellido_materno: apellido_materno ?? this.apellido_materno,
      fecha_nacimiento: fecha_nacimiento ?? this.fecha_nacimiento,
      genero: genero ?? this.genero,
      activo: activo ?? this.activo,
      pais_nombre: pais_nombre ?? this.pais_nombre,
      documento_numero: documento_numero ?? this.documento_numero,
      documento_tipo: documento_tipo ?? this.documento_tipo,
      empresa_nombre: empresa_nombre ?? this.empresa_nombre,
    );
  }
}
