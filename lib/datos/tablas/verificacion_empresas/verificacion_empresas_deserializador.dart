import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/verificacion_empresas/verificacion_empresas_modelo.dart';
import 'package:trackmape_sup/recursos/utilidades/utilidades_json.dart';

class VerificacionEmpresasDeserializador
    implements DeserializadorContrato<VerificacionEmpresasModelo> {
  @override
  VerificacionEmpresasModelo desdeJson(Map<String, dynamic> json) {
    return VerificacionEmpresasModelo(
      id_verificacion_empresa: json['id_verificacion_empresa'] as String,
      fk_empresa: json['fk_empresa'] as String?,
      verificado: json['verificado'] as bool?,
      fuente_verificacion: json['fuente_verificacion'] as String?,
      fecha_verificacion: aDateTimeNulable(json['fecha_verificacion']),
    );
  }
}
