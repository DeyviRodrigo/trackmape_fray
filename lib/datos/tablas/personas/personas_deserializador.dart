import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/personas/personas_modelo.dart';
import 'package:trackmape_sup/recursos/utilidades/utilidades_json.dart';

class PersonasDeserializador implements DeserializadorContrato<PersonasModelo> {
  @override
  PersonasModelo desdeJson(Map<String, dynamic> json) {
    return PersonasModelo(
      id_persona: json['id_persona'] as String,
      fk_pais: json['fk_pais'] as String,
      nombres: json['nombres'] as String,
      apellido_paterno: json['apellido_paterno'] as String,
      apellido_materno: json['apellido_materno'] as String?,
      fecha_nacimiento: aDateTimeNulable(json['fecha_nacimiento']),
      genero: json['genero'] as String?,
      activo: json['activo'] as bool,
    );
  }
}
