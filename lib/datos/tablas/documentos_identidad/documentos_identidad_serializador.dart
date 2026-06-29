import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/documentos_identidad/documentos_identidad_modelo.dart';

class DocumentosIdentidadSerializador
    implements SerializadorContrato<DocumentosIdentidadModelo> {
  @override
  Map<String, dynamic> aJson(DocumentosIdentidadModelo modelo) {
    return {
      if (modelo.id_doc.isNotEmpty) 'id_doc': modelo.id_doc,
      'codigo': modelo.codigo,
      'nombre_documento': modelo.nombre_documento,
      'fk_pais_aplicacion': modelo.fk_pais_aplicacion,
      'activo': modelo.activo,
      'categoria_doc_id': modelo.categoria_doc_id,
      'orden_doc_id': modelo.orden_doc_id,
    };
  }
}
