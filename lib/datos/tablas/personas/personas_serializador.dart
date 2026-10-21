import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/personas/personas_modelo.dart';
import 'package:trackmape_sup/recursos/utilidades/utilidades_fecha.dart';

class PersonasSerializador implements SerializadorContrato<PersonasModelo> {
  @override
  Map<String, dynamic> aJson(PersonasModelo modelo) {
    return {
      if (modelo.id_persona.isNotEmpty) 'id_persona': modelo.id_persona,
      'fk_pais': modelo.fk_pais,
      'nombres': modelo.nombres,
      'apellido_paterno': modelo.apellido_paterno,
      'apellido_materno': modelo.apellido_materno,
      'fecha_nacimiento': modelo.fecha_nacimiento != null
          ? formatearFecha(modelo.fecha_nacimiento!)
          : null,
      'genero': modelo.genero,
      'activo': modelo.activo,
    };
  }
}
