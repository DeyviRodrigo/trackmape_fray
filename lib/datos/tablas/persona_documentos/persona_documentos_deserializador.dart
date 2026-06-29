import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/persona_documentos/persona_documentos_modelo.dart';

class PersonaDocumentosDeserializador
    implements DeserializadorContrato<PersonaDocumentosModelo> {
  @override
  PersonaDocumentosModelo desdeJson(Map<String, dynamic> json) {
    return PersonaDocumentosModelo(
      id_persona_doc: json['id_persona_doc'] as String,
      fk_persona: json['fk_persona'] as String,
      fk_pais_emisor: json['fk_pais_emisor'] as String,
      fk_tipo_doc: json['fk_tipo_doc'] as String,
      num_documento: json['num_documento'] as String,
      cod_verificacion: json['cod_verificacion'] as String?,
      activo: json['activo'] as bool,
    );
  }
}
