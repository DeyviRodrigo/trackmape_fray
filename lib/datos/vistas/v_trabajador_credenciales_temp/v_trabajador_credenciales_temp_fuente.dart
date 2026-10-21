import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_vista_contrato.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajador_credenciales_temp/v_trabajador_credenciales_temp_deserializador.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajador_credenciales_temp/v_trabajador_credenciales_temp_modelo.dart';

class VTrabajadorCredencialesTempFuente
    implements FuenteVistaContrato<VTrabajadorCredencialesTempModelo> {
  final _deserializador = VTrabajadorCredencialesTempDeserializador();
  static const _vista = 'v_trabajador_credenciales_temp';

  @override
  Future<List<VTrabajadorCredencialesTempModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_vista);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<VTrabajadorCredencialesTempModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(
      _vista,
      'id_credencial',
      id,
    );
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  Future<List<VTrabajadorCredencialesTempModelo>> listarPorTrabajador(
    String idTrabajador,
  ) async {
    final respuesta = await mensajero.listarPor(
      _vista,
      'fk_trabajador',
      idTrabajador,
    );
    return respuesta.map(_deserializador.desdeJson).toList();
  }
}
