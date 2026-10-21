import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/personas/personas_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/personas/personas_modelo.dart';
import 'package:trackmape_sup/datos/tablas/personas/personas_serializador.dart';

class PersonasFuente implements FuenteContrato<PersonasModelo> {
  final _deserializador = PersonasDeserializador();
  final _serializador = PersonasSerializador();
  static const _tabla = 'personas';

  @override
  Future<List<PersonasModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<PersonasModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(_tabla, 'id_persona', id);
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(PersonasModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  Future<PersonasModelo> insertarYRetornar(PersonasModelo modelo) async {
    final respuesta = await mensajero.insertarYRetornar(
      _tabla,
      _serializador.aJson(modelo),
    );
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> actualizar(PersonasModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_persona',
      modelo.id_persona,
    );
  }
}
