// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class TrabajadoresModelo implements ModeloContrato {
  final String id_trabajador;
  final String? fk_persona;
  final String? fk_sede;
  final String? celular;
  final String? email;
  final String? fk_contacto_emergencia;
  final String? fk_referido;
  final String? observaciones;
  final String? fotografia_url;
  final Map<String, dynamic>? columnas_extras;
  final String? fk_ubigeo;
  final String? direccion;
  final String fk_empresa;
  final bool activo;

  const TrabajadoresModelo({
    required this.id_trabajador,
    this.fk_persona,
    this.fk_sede,
    this.celular,
    this.email,
    this.fk_contacto_emergencia,
    this.fk_referido,
    this.observaciones,
    this.fotografia_url,
    this.columnas_extras,
    this.fk_ubigeo,
    this.direccion,
    required this.fk_empresa,
    required this.activo,
  });

  @override
  TrabajadoresModelo copyWith({
    String? id_trabajador,
    String? fk_persona,
    String? fk_sede,
    String? celular,
    String? email,
    String? fk_contacto_emergencia,
    String? fk_referido,
    String? observaciones,
    String? fotografia_url,
    Map<String, dynamic>? columnas_extras,
    String? fk_ubigeo,
    String? direccion,
    String? fk_empresa,
    bool? activo,
  }) {
    return TrabajadoresModelo(
      id_trabajador: id_trabajador ?? this.id_trabajador,
      fk_persona: fk_persona ?? this.fk_persona,
      fk_sede: fk_sede ?? this.fk_sede,
      celular: celular ?? this.celular,
      email: email ?? this.email,
      fk_contacto_emergencia:
          fk_contacto_emergencia ?? this.fk_contacto_emergencia,
      fk_referido: fk_referido ?? this.fk_referido,
      observaciones: observaciones ?? this.observaciones,
      fotografia_url: fotografia_url ?? this.fotografia_url,
      columnas_extras: columnas_extras ?? this.columnas_extras,
      fk_ubigeo: fk_ubigeo ?? this.fk_ubigeo,
      direccion: direccion ?? this.direccion,
      fk_empresa: fk_empresa ?? this.fk_empresa,
      activo: activo ?? this.activo,
    );
  }
}
