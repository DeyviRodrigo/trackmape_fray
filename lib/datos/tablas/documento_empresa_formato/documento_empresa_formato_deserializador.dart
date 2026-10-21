import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/documento_empresa_formato/documento_empresa_formato_modelo.dart';

class DocumentoEmpresaFormatoDeserializador
    implements DeserializadorContrato<DocumentoEmpresaFormatoModelo> {
  @override
  DocumentoEmpresaFormatoModelo desdeJson(Map<String, dynamic> json) {
    return DocumentoEmpresaFormatoModelo(
      id_doc_empresa: json['id_doc_empresa'] as String,
      fk_pais: json['fk_pais'] as String,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      regex_validacion: json['regex_validacion'] as String,
      ejemplo: json['ejemplo'] as String?,
      mensaje_error: json['mensaje_error'] as String?,
      activo: json['activo'] as bool,
    );
  }
}
