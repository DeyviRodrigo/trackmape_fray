// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class VTrabajadoresTemporalModelo implements ModeloContrato {
  final String? empresa;
  final String? sede;
  final String id_trabajador;
  final String apellido_paterno;
  final String? apellido_materno;
  final String nombres;
  final DateTime? fecha_nacimiento;
  final String? genero;
  final String? cargo;
  final String id_persona;
  final String id_empresa;
  final String id_sede;
  final String? dni;
  final String? fotografia_url;

  const VTrabajadoresTemporalModelo({
    this.empresa,
    this.sede,
    required this.id_trabajador,
    required this.apellido_paterno,
    this.apellido_materno,
    required this.nombres,
    this.fecha_nacimiento,
    this.genero,
    this.cargo,
    required this.id_persona,
    required this.id_empresa,
    required this.id_sede,
    this.dni,
    this.fotografia_url,
  });

  @override
  VTrabajadoresTemporalModelo copyWith({
    String? empresa,
    String? sede,
    String? id_trabajador,
    String? apellido_paterno,
    String? apellido_materno,
    String? nombres,
    DateTime? fecha_nacimiento,
    String? genero,
    String? cargo,
    String? id_persona,
    String? id_empresa,
    String? id_sede,
    String? dni,
    String? fotografia_url,
  }) {
    return VTrabajadoresTemporalModelo(
      empresa: empresa ?? this.empresa,
      sede: sede ?? this.sede,
      id_trabajador: id_trabajador ?? this.id_trabajador,
      apellido_paterno: apellido_paterno ?? this.apellido_paterno,
      apellido_materno: apellido_materno ?? this.apellido_materno,
      nombres: nombres ?? this.nombres,
      fecha_nacimiento: fecha_nacimiento ?? this.fecha_nacimiento,
      genero: genero ?? this.genero,
      cargo: cargo ?? this.cargo,
      id_persona: id_persona ?? this.id_persona,
      id_empresa: id_empresa ?? this.id_empresa,
      id_sede: id_sede ?? this.id_sede,
      dni: dni ?? this.dni,
      fotografia_url: fotografia_url ?? this.fotografia_url,
    );
  }
}
