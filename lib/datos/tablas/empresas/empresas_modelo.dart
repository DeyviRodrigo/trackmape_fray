// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class EmpresasModelo implements ModeloContrato {
  final String id_empresa;
  final String fk_pais;
  final String fk_tipo_doc;
  final String numero_documento;
  final String razon_social;
  final String? nombre_comercial;
  final String? estado;
  final String? condicion;
  final String? fk_ubigeo;
  final String? direccion;
  final Map<String, dynamic>? columnas_extras;
  final String? fk_responsable;
  final String? celular;
  final String? email;
  final String? pagina_web;
  final String? logo_url;
  final bool? activo;

  const EmpresasModelo({
    required this.id_empresa,
    required this.fk_pais,
    required this.fk_tipo_doc,
    required this.numero_documento,
    required this.razon_social,
    this.nombre_comercial,
    this.estado,
    this.condicion,
    this.fk_ubigeo,
    this.direccion,
    this.columnas_extras,
    this.fk_responsable,
    this.celular,
    this.email,
    this.pagina_web,
    this.logo_url,
    this.activo,
  });

  @override
  EmpresasModelo copyWith({
    String? id_empresa,
    String? fk_pais,
    String? fk_tipo_doc,
    String? numero_documento,
    String? razon_social,
    String? nombre_comercial,
    String? estado,
    String? condicion,
    String? fk_ubigeo,
    String? direccion,
    Map<String, dynamic>? columnas_extras,
    String? fk_responsable,
    String? celular,
    String? email,
    String? pagina_web,
    String? logo_url,
    bool? activo,
  }) {
    return EmpresasModelo(
      id_empresa: id_empresa ?? this.id_empresa,
      fk_pais: fk_pais ?? this.fk_pais,
      fk_tipo_doc: fk_tipo_doc ?? this.fk_tipo_doc,
      numero_documento: numero_documento ?? this.numero_documento,
      razon_social: razon_social ?? this.razon_social,
      nombre_comercial: nombre_comercial ?? this.nombre_comercial,
      estado: estado ?? this.estado,
      condicion: condicion ?? this.condicion,
      fk_ubigeo: fk_ubigeo ?? this.fk_ubigeo,
      direccion: direccion ?? this.direccion,
      columnas_extras: columnas_extras ?? this.columnas_extras,
      fk_responsable: fk_responsable ?? this.fk_responsable,
      celular: celular ?? this.celular,
      email: email ?? this.email,
      pagina_web: pagina_web ?? this.pagina_web,
      logo_url: logo_url ?? this.logo_url,
      activo: activo ?? this.activo,
    );
  }
}
