// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class VTrabajadoresTempModelo implements ModeloContrato {
  final String id_trabajador;
  final String fk_persona;
  final String fk_empresa;
  final String? fk_sede;
  final String? celular;
  final String? email;
  final String? direccion;
  final String? fotografia_url;
  final String? observaciones;
  final bool activo;
  final String? fk_contacto_emergencia;
  final String? fk_referido;
  final String empresa_nombre;
  final String? sede_nombre;

  const VTrabajadoresTempModelo({
    required this.id_trabajador,
    required this.fk_persona,
    required this.fk_empresa,
    this.fk_sede,
    this.celular,
    this.email,
    this.direccion,
    this.fotografia_url,
    this.observaciones,
    required this.activo,
    this.fk_contacto_emergencia,
    this.fk_referido,
    required this.empresa_nombre,
    this.sede_nombre,
  });

  @override
  VTrabajadoresTempModelo copyWith({
    String? id_trabajador,
    String? fk_persona,
    String? fk_empresa,
    String? fk_sede,
    String? celular,
    String? email,
    String? direccion,
    String? fotografia_url,
    String? observaciones,
    bool? activo,
    String? fk_contacto_emergencia,
    String? fk_referido,
    String? empresa_nombre,
    String? sede_nombre,
  }) {
    return VTrabajadoresTempModelo(
      id_trabajador: id_trabajador ?? this.id_trabajador,
      fk_persona: fk_persona ?? this.fk_persona,
      fk_empresa: fk_empresa ?? this.fk_empresa,
      fk_sede: fk_sede ?? this.fk_sede,
      celular: celular ?? this.celular,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      fotografia_url: fotografia_url ?? this.fotografia_url,
      observaciones: observaciones ?? this.observaciones,
      activo: activo ?? this.activo,
      fk_contacto_emergencia:
          fk_contacto_emergencia ?? this.fk_contacto_emergencia,
      fk_referido: fk_referido ?? this.fk_referido,
      empresa_nombre: empresa_nombre ?? this.empresa_nombre,
      sede_nombre: sede_nombre ?? this.sede_nombre,
    );
  }
}
