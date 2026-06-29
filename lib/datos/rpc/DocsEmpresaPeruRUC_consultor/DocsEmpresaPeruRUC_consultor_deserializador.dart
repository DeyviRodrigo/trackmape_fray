// ignore_for_file: file_names

import 'package:trackmape_sup/datos/rpc/DocsEmpresaPeruRUC_consultor/DocsEmpresaPeruRUC_consultor_resultado.dart';
import 'package:trackmape_sup/datos/vistas/v_empresas/v_empresas_deserializador.dart';
import 'package:trackmape_sup/recursos/utilidades/utilidades_json.dart';

class DocsEmpresaPeruRUCConsultorDeserializador {
  final _deserializadorVEmpresas = VEmpresasDeserializador();

  DocsEmpresaPeruRUCConsultorResultado desdeJson(Map<String, dynamic> json) {
    return DocsEmpresaPeruRUCConsultorResultado(
      ok: json['ok'] as bool,
      ruc: json['ruc'] as String,
      ultima_verificacion_ok: aDateTimeNulable(json['ultima_verificacion_ok']),
      empresa: _deserializadorVEmpresas.desdeJson(
        Map<String, dynamic>.from(json['empresa'] as Map),
      ),
    );
  }
}
