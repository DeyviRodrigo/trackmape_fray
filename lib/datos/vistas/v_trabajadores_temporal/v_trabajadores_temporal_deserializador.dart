import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajadores_temporal/v_trabajadores_temporal_modelo.dart';
import 'package:trackmape_sup/recursos/utilidades/utilidades_json.dart';

class VTrabajadoresTemporalDeserializador
    implements DeserializadorContrato<VTrabajadoresTemporalModelo> {
  @override
  VTrabajadoresTemporalModelo desdeJson(Map<String, dynamic> json) {
    return VTrabajadoresTemporalModelo(
      empresa: json['empresa'] as String?,
      sede: json['sede'] as String?,
      id_trabajador: json['id_trabajador'] as String,
      apellido_paterno: json['apellido_paterno'] as String,
      apellido_materno: json['apellido_materno'] as String?,
      nombres: json['nombres'] as String,
      fecha_nacimiento: aDateTimeNulable(json['fecha_nacimiento']),
      genero: json['genero'] as String?,
      cargo: json['cargo'] as String?,
      id_persona: json['id_persona'] as String,
      id_empresa: json['id_empresa'] as String,
      id_sede: json['id_sede'] as String,
      dni: json['dni'] as String?,
      fotografia_url: json['fotografia_url'] as String?,
    );
  }
}
