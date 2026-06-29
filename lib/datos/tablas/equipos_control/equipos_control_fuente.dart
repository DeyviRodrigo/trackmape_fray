import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/equipos_control/equipos_control_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/equipos_control/equipos_control_modelo.dart';
import 'package:trackmape_sup/datos/tablas/equipos_control/equipos_control_serializador.dart';

class EquiposControlFuente implements FuenteContrato<EquiposControlModelo> {
  final _deserializador = EquiposControlDeserializador();
  final _serializador = EquiposControlSerializador();
  static const _tabla = 'equipos_control';

  @override
  Future<List<EquiposControlModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<EquiposControlModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(
      _tabla,
      'id_equipo_control',
      id,
    );
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(EquiposControlModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(EquiposControlModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_equipo_control',
      modelo.id_equipo_control,
    );
  }
}
