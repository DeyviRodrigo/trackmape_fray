import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/contrato/contrato_modelo.dart';
import 'package:trackmape_sup/recursos/utilidades/utilidades_fecha.dart';

class ContratoSerializador implements SerializadorContrato<ContratoModelo> {
  @override
  Map<String, dynamic> aJson(ContratoModelo modelo) {
    return {
      if (modelo.id_contrato.isNotEmpty) 'id_contrato': modelo.id_contrato,
      'fk_trabajador': modelo.fk_trabajador,
      'cargo': modelo.cargo,
      'tipo_contrato': modelo.tipo_contrato,
      'fecha_inicio': formatearFecha(modelo.fecha_inicio),
      'fecha_fin': modelo.fecha_fin != null
          ? formatearFecha(modelo.fecha_fin!)
          : null,
      'remuneracion': modelo.remuneracion,
      'frecuencia_pago': modelo.frecuencia_pago,
      'fk_moneda': modelo.fk_moneda,
      'documento_url': modelo.documento_url,
      'observacion': modelo.observacion,
      'columnas_extras': modelo.columnas_extras,
      'turno': modelo.turno,
      'modalidad': modelo.modalidad,
      'sistema': modelo.sistema,
    };
  }
}
