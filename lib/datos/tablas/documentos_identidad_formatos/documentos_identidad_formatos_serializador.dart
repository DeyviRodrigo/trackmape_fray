import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/documentos_identidad_formatos/documentos_identidad_formatos_modelo.dart';

class DocumentosIdentidadFormatosSerializador
    implements SerializadorContrato<DocumentosIdentidadFormatosModelo> {
  @override
  Map<String, dynamic> aJson(DocumentosIdentidadFormatosModelo modelo) {
    return {
      if (modelo.id_formato_doc.isNotEmpty)
        'id_formato_doc': modelo.id_formato_doc,
      'fk_doc': modelo.fk_doc,
      'nombre_formato': modelo.nombre_formato,
      'regex_validacion': modelo.regex_validacion,
      'ejemplo': modelo.ejemplo,
      'mensaje_error': modelo.mensaje_error,
      'activo': modelo.activo,
      'orden': modelo.orden,
    };
  }
}
