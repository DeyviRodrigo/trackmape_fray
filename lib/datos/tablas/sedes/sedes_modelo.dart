// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class SedesModelo implements ModeloContrato {
  final String id_sede;
  final String fk_empresa;
  final String nombre;
  final String? tipo_sede;
  final String? fk_responsable;
  final String? celular;
  final String? email;
  final String? pagina_web;
  final String? logo_url;
  final String? fk_ubigeo;
  final String? direccion;
  final Map<String, dynamic>? columnas_extras;
  final bool? activo;
  final String? zona_horaria;

  const SedesModelo({
    required this.id_sede,
    required this.fk_empresa,
    required this.nombre,
    this.tipo_sede,
    this.fk_responsable,
    this.celular,
    this.email,
    this.pagina_web,
    this.logo_url,
    this.fk_ubigeo,
    this.direccion,
    this.columnas_extras,
    this.activo,
    this.zona_horaria,
  });

  @override
  SedesModelo copyWith({
    String? id_sede,
    String? fk_empresa,
    String? nombre,
    String? tipo_sede,
    String? fk_responsable,
    String? celular,
    String? email,
    String? pagina_web,
    String? logo_url,
    String? fk_ubigeo,
    String? direccion,
    Map<String, dynamic>? columnas_extras,
    bool? activo,
    String? zona_horaria,
  }) {
    return SedesModelo(
      id_sede: id_sede ?? this.id_sede,
      fk_empresa: fk_empresa ?? this.fk_empresa,
      nombre: nombre ?? this.nombre,
      tipo_sede: tipo_sede ?? this.tipo_sede,
      fk_responsable: fk_responsable ?? this.fk_responsable,
      celular: celular ?? this.celular,
      email: email ?? this.email,
      pagina_web: pagina_web ?? this.pagina_web,
      logo_url: logo_url ?? this.logo_url,
      fk_ubigeo: fk_ubigeo ?? this.fk_ubigeo,
      direccion: direccion ?? this.direccion,
      columnas_extras: columnas_extras ?? this.columnas_extras,
      activo: activo ?? this.activo,
      zona_horaria: zona_horaria ?? this.zona_horaria,
    );
  }
}
