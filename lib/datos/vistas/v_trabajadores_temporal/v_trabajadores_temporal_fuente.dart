import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_vista_contrato.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajadores_temporal/v_trabajadores_temporal_deserializador.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajadores_temporal/v_trabajadores_temporal_modelo.dart';

class VTrabajadoresTemporalFuente
    implements FuenteVistaContrato<VTrabajadoresTemporalModelo> {
  final _deserializador = VTrabajadoresTemporalDeserializador();
  static const _vista = 'v_trabajadores_temporal';

  @override
  Future<List<VTrabajadoresTemporalModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_vista);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<VTrabajadoresTemporalModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(
      _vista,
      'id_trabajador',
      id,
    );
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  Future<List<VTrabajadoresTemporalModelo>> listarPorEmpresa(
    String idEmpresa,
  ) async {
    final respuesta = await mensajero.listarPor(
      _vista,
      'id_empresa',
      idEmpresa,
    );
    return respuesta.map(_deserializador.desdeJson).toList();
  }
}
