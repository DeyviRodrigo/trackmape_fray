// ignore_for_file: file_names

import 'package:trackmape_sup/datos/rpc/DocsIdPeruDNI_consultor/DocsIdPeruDNI_consultor_resultado.dart';
import 'package:trackmape_sup/recursos/utilidades/utilidades_json.dart';

class DocsIdPeruDNIConsultorDeserializador {
  DocsIdPeruDNIConsultorResultado desdeJson(Map<String, dynamic> json) {
    final modo = json['modo'] as String?;

    if (modo == 'cache') {
      final persona = Map<String, dynamic>.from(json['persona'] as Map);
      final documento = Map<String, dynamic>.from(json['documento'] as Map);
      return DocsIdPeruDNIConsultorResultado(
        id_persona: persona['id_persona'] as String,
        id_persona_doc: documento['id_persona_doc'] as String,
        dni: json['dni'] as String,
        nombres: persona['nombres'] as String?,
        apellido_paterno: persona['apellido_paterno'] as String?,
        apellido_materno: persona['apellido_materno'] as String?,
        ultima_verificacion_ok: aDateTimeNulable(
          json['ultima_verificacion_ok'],
        ),
      );
    } else {
      // modo refresh — anidado: resultado.resultado
      final router = Map<String, dynamic>.from(json['resultado'] as Map);
      final datos = Map<String, dynamic>.from(router['resultado'] as Map);
      return DocsIdPeruDNIConsultorResultado(
        id_persona: datos['id_persona'] as String,
        id_persona_doc: datos['id_persona_doc'] as String,
        dni: datos['dni'] as String,
      );
    }
  }
}
