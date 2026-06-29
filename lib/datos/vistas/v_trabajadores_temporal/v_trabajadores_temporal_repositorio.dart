import 'package:trackmape_sup/datos/vistas/v_trabajadores_temporal/v_trabajadores_temporal_fuente.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajadores_temporal/v_trabajadores_temporal_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class VTrabajadoresTemporalRepositorio {
  final _fuente = VTrabajadoresTemporalFuente();

  Future<List<VTrabajadoresTemporalModelo>> obtenerTodos() => ejecutar(
    'Error al obtener v_trabajadores_temporal',
    () => _fuente.obtenerTodos(),
  );

  Future<VTrabajadoresTemporalModelo?> obtenerPorId(String id) => ejecutar(
    'Error al obtener v_trabajador_temporal',
    () => _fuente.obtenerPorId(id),
  );

  Future<List<VTrabajadoresTemporalModelo>> listarPorEmpresa(
    String idEmpresa,
  ) => ejecutar(
    'Error al listar trabajadores por empresa',
    () => _fuente.listarPorEmpresa(idEmpresa),
  );
}
