import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/persona_documentos/persona_documentos_modelo.dart';

class PersonaDocumentosSerializador
    implements SerializadorContrato<PersonaDocumentosModelo> {
  @override
  Map<String, dynamic> aJson(PersonaDocumentosModelo modelo) {
    return {
      if (modelo.id_persona_doc.isNotEmpty)
        'id_persona_doc': modelo.id_persona_doc,
      'fk_persona': modelo.fk_persona,
      'fk_pais_emisor': modelo.fk_pais_emisor,
      'fk_tipo_doc': modelo.fk_tipo_doc,
      'num_documento': modelo.num_documento,
      'cod_verificacion': modelo.cod_verificacion,
      'activo': modelo.activo,
    };
  }
}
