// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class VDocumentoPersonaTempModelo implements ModeloContrato {
  final String id_persona_doc;
  final String fk_persona;
  final String num_documento;
  final bool activo;
  final String? cod_verificacion;
  final String? pais_emisor_nombre;
  final String? doc_codigo;
  final String? doc_nombre;
  final bool verificado;
  final DateTime? fecha_verificacion;

  const VDocumentoPersonaTempModelo({
    required this.id_persona_doc,
    required this.fk_persona,
    required this.num_documento,
    required this.activo,
    this.cod_verificacion,
    this.pais_emisor_nombre,
    this.doc_codigo,
    this.doc_nombre,
    required this.verificado,
    this.fecha_verificacion,
  });

  @override
  VDocumentoPersonaTempModelo copyWith({
    String? id_persona_doc,
    String? fk_persona,
    String? num_documento,
    bool? activo,
    String? cod_verificacion,
    String? pais_emisor_nombre,
    String? doc_codigo,
    String? doc_nombre,
    bool? verificado,
    DateTime? fecha_verificacion,
  }) {
    return VDocumentoPersonaTempModelo(
      id_persona_doc: id_persona_doc ?? this.id_persona_doc,
      fk_persona: fk_persona ?? this.fk_persona,
      num_documento: num_documento ?? this.num_documento,
      activo: activo ?? this.activo,
      cod_verificacion: cod_verificacion ?? this.cod_verificacion,
      pais_emisor_nombre: pais_emisor_nombre ?? this.pais_emisor_nombre,
      doc_codigo: doc_codigo ?? this.doc_codigo,
      doc_nombre: doc_nombre ?? this.doc_nombre,
      verificado: verificado ?? this.verificado,
      fecha_verificacion: fecha_verificacion ?? this.fecha_verificacion,
    );
  }
}
