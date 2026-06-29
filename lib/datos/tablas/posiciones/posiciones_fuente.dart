import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/posiciones/posiciones_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/posiciones/posiciones_modelo.dart';
import 'package:trackmape_sup/datos/tablas/posiciones/posiciones_serializador.dart';

class PosicionesFuente implements FuenteContrato<PosicionesModelo> {
  final _deserializador = PosicionesDeserializador();
  final _serializador = PosicionesSerializador();
  static const _tabla = 'posiciones';

  @override
  Future<List<PosicionesModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<PosicionesModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(_tabla, 'id_posicion', id);
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(PosicionesModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(PosicionesModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_posicion',
      modelo.id_posicion,
    );
  }
}
