// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class PersonaDocumentosModelo implements ModeloContrato {
  final String id_persona_doc;
  final String fk_persona;
  final String fk_pais_emisor;
  final String fk_tipo_doc;
  final String num_documento;
  final String? cod_verificacion;
  final bool activo;

  const PersonaDocumentosModelo({
    required this.id_persona_doc,
    required this.fk_persona,
    required this.fk_pais_emisor,
    required this.fk_tipo_doc,
    required this.num_documento,
    this.cod_verificacion,
    required this.activo,
  });

  @override
  PersonaDocumentosModelo copyWith({
    String? id_persona_doc,
    String? fk_persona,
    String? fk_pais_emisor,
    String? fk_tipo_doc,
    String? num_documento,
    String? cod_verificacion,
    bool? activo,
  }) {
    return PersonaDocumentosModelo(
      id_persona_doc: id_persona_doc ?? this.id_persona_doc,
      fk_persona: fk_persona ?? this.fk_persona,
      fk_pais_emisor: fk_pais_emisor ?? this.fk_pais_emisor,
      fk_tipo_doc: fk_tipo_doc ?? this.fk_tipo_doc,
      num_documento: num_documento ?? this.num_documento,
      cod_verificacion: cod_verificacion ?? this.cod_verificacion,
      activo: activo ?? this.activo,
    );
  }
}
