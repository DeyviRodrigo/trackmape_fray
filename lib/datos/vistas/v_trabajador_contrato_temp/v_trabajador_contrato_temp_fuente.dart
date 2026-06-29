import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_vista_contrato.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajador_contrato_temp/v_trabajador_contrato_temp_deserializador.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajador_contrato_temp/v_trabajador_contrato_temp_modelo.dart';

class VTrabajadorContratoTempFuente
    implements FuenteVistaContrato<VTrabajadorContratoTempModelo> {
  final _deserializador = VTrabajadorContratoTempDeserializador();
  static const _vista = 'v_trabajador_contrato_temp';

  @override
  Future<List<VTrabajadorContratoTempModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_vista);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<VTrabajadorContratoTempModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(_vista, 'id_contrato', id);
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  Future<List<VTrabajadorContratoTempModelo>> listarPorTrabajador(
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
