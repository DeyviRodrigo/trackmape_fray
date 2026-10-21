import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/trabajadores/trabajadores_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/trabajadores/trabajadores_modelo.dart';
import 'package:trackmape_sup/datos/tablas/trabajadores/trabajadores_serializador.dart';

class TrabajadoresFuente implements FuenteContrato<TrabajadoresModelo> {
  final _deserializador = TrabajadoresDeserializador();
  final _serializador = TrabajadoresSerializador();
  static const _tabla = 'trabajadores';

  @override
  Future<List<TrabajadoresModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<TrabajadoresModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(
      _tabla,
      'id_trabajador',
      id,
    );
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(TrabajadoresModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  Future<TrabajadoresModelo> insertarYRetornar(
    TrabajadoresModelo modelo,
  ) async {
    final respuesta = await mensajero.insertarYRetornar(
      _tabla,
      _serializador.aJson(modelo),
    );
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> actualizar(TrabajadoresModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_trabajador',
      modelo.id_trabajador,
    );
  }

  Future<void> desactivar(String id) async {
    await mensajero.desactivar(_tabla, {'activo': false}, 'id_trabajador', id);
  }
}
