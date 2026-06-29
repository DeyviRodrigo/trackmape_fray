import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/sedes/sedes_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/sedes/sedes_modelo.dart';
import 'package:trackmape_sup/datos/tablas/sedes/sedes_serializador.dart';

class SedesFuente implements FuenteContrato<SedesModelo> {
  final _deserializador = SedesDeserializador();
  final _serializador = SedesSerializador();
  static const _tabla = 'sedes';

  @override
  Future<List<SedesModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<SedesModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(_tabla, 'id_sede', id);
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(SedesModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(SedesModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_sede',
      modelo.id_sede,
    );
  }
}
