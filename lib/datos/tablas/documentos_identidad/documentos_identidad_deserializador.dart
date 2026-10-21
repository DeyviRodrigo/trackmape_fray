import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/documentos_identidad/documentos_identidad_modelo.dart';

class DocumentosIdentidadDeserializador
    implements DeserializadorContrato<DocumentosIdentidadModelo> {
  @override
  DocumentosIdentidadModelo desdeJson(Map<String, dynamic> json) {
    return DocumentosIdentidadModelo(
      id_doc: json['id_doc'] as String,
      codigo: json['codigo'] as String,
      nombre_documento: json['nombre_documento'] as String,
      fk_pais_aplicacion: json['fk_pais_aplicacion'] as String?,
      activo: json['activo'] as bool,
      categoria_doc_id: json['categoria_doc_id'] as String,
      orden_doc_id: json['orden_doc_id'] as int,
    );
  }
}
