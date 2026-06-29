import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_vista_contrato.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajadores_temp/v_trabajadores_temp_deserializador.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajadores_temp/v_trabajadores_temp_modelo.dart';

class VTrabajadoresTempFuente
    implements FuenteVistaContrato<VTrabajadoresTempModelo> {
  final _deserializador = VTrabajadoresTempDeserializador();
  static const _vista = 'v_trabajadores_temp';

  @override
  Future<List<VTrabajadoresTempModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_vista);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<VTrabajadoresTempModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(
      _vista,
      'id_trabajador',
      id,
    );
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }
}
