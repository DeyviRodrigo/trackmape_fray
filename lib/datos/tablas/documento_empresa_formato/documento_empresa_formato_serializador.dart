import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/documento_empresa_formato/documento_empresa_formato_modelo.dart';

class DocumentoEmpresaFormatoSerializador
    implements SerializadorContrato<DocumentoEmpresaFormatoModelo> {
  @override
  Map<String, dynamic> aJson(DocumentoEmpresaFormatoModelo modelo) {
    return {
      if (modelo.id_doc_empresa.isNotEmpty)
        'id_doc_empresa': modelo.id_doc_empresa,
      'fk_pais': modelo.fk_pais,
      'codigo': modelo.codigo,
      'nombre': modelo.nombre,
      'regex_validacion': modelo.regex_validacion,
      'ejemplo': modelo.ejemplo,
      'mensaje_error': modelo.mensaje_error,
      'activo': modelo.activo,
    };
  }
}
