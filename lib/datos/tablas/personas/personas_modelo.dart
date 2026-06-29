// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class PersonasModelo implements ModeloContrato {
  final String id_persona;
  final String fk_pais;
  final String nombres;
  final String apellido_paterno;
  final String? apellido_materno;
  final DateTime? fecha_nacimiento;
  final String? genero;
  final bool activo;

  const PersonasModelo({
    required this.id_persona,
    required this.fk_pais,
    required this.nombres,
    required this.apellido_paterno,
    this.apellido_materno,
    this.fecha_nacimiento,
    this.genero,
    required this.activo,
  });

  @override
  PersonasModelo copyWith({
    String? id_persona,
    String? fk_pais,
    String? nombres,
    String? apellido_paterno,
    String? apellido_materno,
    DateTime? fecha_nacimiento,
    String? genero,
    bool? activo,
  }) {
    return PersonasModelo(
      id_persona: id_persona ?? this.id_persona,
      fk_pais: fk_pais ?? this.fk_pais,
      nombres: nombres ?? this.nombres,
      apellido_paterno: apellido_paterno ?? this.apellido_paterno,
      apellido_materno: apellido_materno ?? this.apellido_materno,
      fecha_nacimiento: fecha_nacimiento ?? this.fecha_nacimiento,
      genero: genero ?? this.genero,
      activo: activo ?? this.activo,
    );
  }
}
