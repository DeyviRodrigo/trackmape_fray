import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/posiciones_temp/posiciones_temp_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/posiciones_temp/posiciones_temp_modelo.dart';
import 'package:trackmape_sup/datos/tablas/posiciones_temp/posiciones_temp_serializador.dart';

class PosicionesTempFuente implements FuenteContrato<PosicionesTempModelo> {
  final _deserializador = PosicionesTempDeserializador();
  final _serializador = PosicionesTempSerializador();
  static const _tabla = 'posiciones_temp';

  @override
  Future<List<PosicionesTempModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<PosicionesTempModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(_tabla, 'id_posicion', id);
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(PosicionesTempModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(PosicionesTempModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_posicion',
      modelo.id_posicion,
    );
  }
}
