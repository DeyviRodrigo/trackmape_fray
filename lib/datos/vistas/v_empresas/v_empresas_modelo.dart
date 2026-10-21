// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class VEmpresasModelo implements ModeloContrato {
  final String id_empresa;
  final String? pais;
  final String? tipo_documento;
  final String? numero_documento;
  final String? razon_social;
  final String? nombre_comercial;
  final String? estado;
  final String? condicion;
  final List<Map<String, dynamic>>? ubigeo;
  final String? direccion;
  final String? celular;
  final String? email;
  final String? pagina_web;
  final String? logo_url;
  final int total_sedes;
  final int total_sedes_activas;
  final int total_trabajadores;
  final int total_trabajadores_activos;
  final bool? empresa_verificada;
  final String? fuente_verificacion;
  final DateTime? fecha_verificacion;
  final bool? empresa_activa;
  final Map<String, dynamic>? columnas_extras;

  const VEmpresasModelo({
    required this.id_empresa,
    this.pais,
    this.tipo_documento,
    this.numero_documento,
    this.razon_social,
    this.nombre_comercial,
    this.estado,
    this.condicion,
    this.ubigeo,
    this.direccion,
    this.celular,
    this.email,
    this.pagina_web,
    this.logo_url,
    required this.total_sedes,
    required this.total_sedes_activas,
    required this.total_trabajadores,
    required this.total_trabajadores_activos,
    this.empresa_verificada,
    this.fuente_verificacion,
    this.fecha_verificacion,
    this.empresa_activa,
    this.columnas_extras,
  });

  @override
  VEmpresasModelo copyWith({
    String? id_empresa,
    String? pais,
    String? tipo_documento,
    String? numero_documento,
    String? razon_social,
    String? nombre_comercial,
    String? estado,
    String? condicion,
    List<Map<String, dynamic>>? ubigeo,
    String? direccion,
    String? celular,
    String? email,
    String? pagina_web,
    String? logo_url,
    int? total_sedes,
    int? total_sedes_activas,
    int? total_trabajadores,
    int? total_trabajadores_activos,
    bool? empresa_verificada,
    String? fuente_verificacion,
    DateTime? fecha_verificacion,
    bool? empresa_activa,
    Map<String, dynamic>? columnas_extras,
  }) {
    return VEmpresasModelo(
      id_empresa: id_empresa ?? this.id_empresa,
      pais: pais ?? this.pais,
      tipo_documento: tipo_documento ?? this.tipo_documento,
      numero_documento: numero_documento ?? this.numero_documento,
      razon_social: razon_social ?? this.razon_social,
      nombre_comercial: nombre_comercial ?? this.nombre_comercial,
      estado: estado ?? this.estado,
      condicion: condicion ?? this.condicion,
      ubigeo: ubigeo ?? this.ubigeo,
      direccion: direccion ?? this.direccion,
      celular: celular ?? this.celular,
      email: email ?? this.email,
      pagina_web: pagina_web ?? this.pagina_web,
      logo_url: logo_url ?? this.logo_url,
      total_sedes: total_sedes ?? this.total_sedes,
      total_sedes_activas: total_sedes_activas ?? this.total_sedes_activas,
      total_trabajadores: total_trabajadores ?? this.total_trabajadores,
      total_trabajadores_activos:
          total_trabajadores_activos ?? this.total_trabajadores_activos,
      empresa_verificada: empresa_verificada ?? this.empresa_verificada,
      fuente_verificacion: fuente_verificacion ?? this.fuente_verificacion,
      fecha_verificacion: fecha_verificacion ?? this.fecha_verificacion,
      empresa_activa: empresa_activa ?? this.empresa_activa,
      columnas_extras: columnas_extras ?? this.columnas_extras,
    );
  }
}
