import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajador_contrato_temp/v_trabajador_contrato_temp_modelo.dart';
import 'package:trackmape_sup/recursos/utilidades/utilidades_json.dart';

class VTrabajadorContratoTempDeserializador
    implements DeserializadorContrato<VTrabajadorContratoTempModelo> {
  @override
  VTrabajadorContratoTempModelo desdeJson(Map<String, dynamic> json) {
    return VTrabajadorContratoTempModelo(
      id_contrato: json['id_contrato'] as String,
      fk_trabajador: json['fk_trabajador'] as String,
      cargo: json['cargo'] as String,
      tipo_contrato: json['tipo_contrato'] as String?,
      fecha_inicio: DateTime.parse(json['fecha_inicio'] as String),
      fecha_fin: aDateTimeNulable(json['fecha_fin']),
      remuneracion: aDoubleNulable(json['remuneracion']),
      frecuencia_pago: json['frecuencia_pago'] as String?,
      turno: json['turno'] as String?,
      modalidad: json['modalidad'] as String?,
      sistema: json['sistema'] as String?,
      documento_url: json['documento_url'] as String?,
      observacion: json['observacion'] as String?,
      moneda_codigo: json['moneda_codigo'] as String?,
      nombre_moneda: json['nombre_moneda'] as String?,
      moneda_simbolo: json['moneda_simbolo'] as String?,
    );
  }
}
