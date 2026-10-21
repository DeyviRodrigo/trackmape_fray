import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/verificacion_empresas/verificacion_empresas_modelo.dart';

class VerificacionEmpresasSerializador
    implements SerializadorContrato<VerificacionEmpresasModelo> {
  @override
  Map<String, dynamic> aJson(VerificacionEmpresasModelo modelo) {
    return {
      if (modelo.id_verificacion_empresa.isNotEmpty)
        'id_verificacion_empresa': modelo.id_verificacion_empresa,
      'fk_empresa': modelo.fk_empresa,
      'verificado': modelo.verificado,
      'fuente_verificacion': modelo.fuente_verificacion,
      'fecha_verificacion': modelo.fecha_verificacion?.toIso8601String(),
    };
  }
}
