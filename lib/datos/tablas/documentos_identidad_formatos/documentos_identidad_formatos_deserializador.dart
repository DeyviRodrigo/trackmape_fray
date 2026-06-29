import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/documentos_identidad_formatos/documentos_identidad_formatos_modelo.dart';

class DocumentosIdentidadFormatosDeserializador
    implements DeserializadorContrato<DocumentosIdentidadFormatosModelo> {
  @override
  DocumentosIdentidadFormatosModelo desdeJson(Map<String, dynamic> json) {
    return DocumentosIdentidadFormatosModelo(
      id_formato_doc: json['id_formato_doc'] as String,
      fk_doc: json['fk_doc'] as String,
      nombre_formato: json['nombre_formato'] as String,
      regex_validacion: json['regex_validacion'] as String,
      ejemplo: json['ejemplo'] as String?,
      mensaje_error: json['mensaje_error'] as String,
      activo: json['activo'] as bool,
      orden: json['orden'] as int,
    );
  }
}
