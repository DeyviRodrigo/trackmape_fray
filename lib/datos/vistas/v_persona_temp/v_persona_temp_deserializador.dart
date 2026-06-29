import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/vistas/v_persona_temp/v_persona_temp_modelo.dart';
import 'package:trackmape_sup/recursos/utilidades/utilidades_json.dart';

class VPersonaTempDeserializador
    implements DeserializadorContrato<VPersonaTempModelo> {
  @override
  VPersonaTempModelo desdeJson(Map<String, dynamic> json) {
    return VPersonaTempModelo(
      id_persona: json['id_persona'] as String,
      id_trabajador: json['id_trabajador'] as String,
      nombres: json['nombres'] as String,
      apellido_paterno: json['apellido_paterno'] as String,
      apellido_materno: json['apellido_materno'] as String?,
      fecha_nacimiento: aDateTimeNulable(json['fecha_nacimiento']),
      genero: json['genero'] as String?,
      activo: json['activo'] as bool,
      pais_nombre: json['pais_nombre'] as String?,
      documento_numero: json['documento_numero'] as String?,
      documento_tipo: json['documento_tipo'] as String?,
      empresa_nombre: json['empresa_nombre'] as String?,
    );
  }
}
