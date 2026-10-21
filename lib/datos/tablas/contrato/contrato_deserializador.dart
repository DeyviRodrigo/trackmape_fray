import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/contrato/contrato_modelo.dart';
import 'package:trackmape_sup/recursos/utilidades/utilidades_json.dart';

class ContratoDeserializador implements DeserializadorContrato<ContratoModelo> {
  @override
  ContratoModelo desdeJson(Map<String, dynamic> json) {
    return ContratoModelo(
      id_contrato: json['id_contrato'] as String,
      fk_trabajador: json['fk_trabajador'] as String,
      cargo: json['cargo'] as String,
      tipo_contrato: json['tipo_contrato'] as String?,
      fecha_inicio: aDateTimeNulable(json['fecha_inicio'])!,
      fecha_fin: aDateTimeNulable(json['fecha_fin']),
      remuneracion: aDoubleNulable(json['remuneracion']),
      frecuencia_pago: json['frecuencia_pago'] as String?,
      fk_moneda: json['fk_moneda'] as String?,
      documento_url: json['documento_url'] as String?,
      observacion: json['observacion'] as String?,
      columnas_extras: json['columnas_extras'] as Map<String, dynamic>?,
      turno: json['turno'] as String?,
      modalidad: json['modalidad'] as String?,
      sistema: json['sistema'] as String?,
    );
  }
}
