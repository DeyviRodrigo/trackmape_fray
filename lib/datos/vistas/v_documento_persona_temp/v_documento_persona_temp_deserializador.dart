import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/vistas/v_documento_persona_temp/v_documento_persona_temp_modelo.dart';
import 'package:trackmape_sup/recursos/utilidades/utilidades_json.dart';

class VDocumentoPersonaTempDeserializador
    implements DeserializadorContrato<VDocumentoPersonaTempModelo> {
  @override
  VDocumentoPersonaTempModelo desdeJson(Map<String, dynamic> json) {
    return VDocumentoPersonaTempModelo(
      id_persona_doc: json['id_persona_doc'] as String,
      fk_persona: json['fk_persona'] as String,
      num_documento: json['num_documento'] as String,
      activo: json['activo'] as bool,
      cod_verificacion: json['cod_verificacion'] as String?,
      pais_emisor_nombre: json['pais_emisor_nombre'] as String?,
      doc_codigo: json['doc_codigo'] as String?,
      doc_nombre: json['doc_nombre'] as String?,
      verificado: json['verificado'] as bool? ?? false,
      fecha_verificacion: aDateTimeNulable(json['fecha_verificacion']),
    );
  }
}
