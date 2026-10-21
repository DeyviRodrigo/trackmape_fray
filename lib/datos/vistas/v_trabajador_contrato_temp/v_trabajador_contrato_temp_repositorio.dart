import 'package:trackmape_sup/datos/vistas/v_trabajador_contrato_temp/v_trabajador_contrato_temp_fuente.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajador_contrato_temp/v_trabajador_contrato_temp_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class VTrabajadorContratoTempRepositorio {
  final _fuente = VTrabajadorContratoTempFuente();

  Future<List<VTrabajadorContratoTempModelo>> listarPorTrabajador(
    String idTrabajador,
  ) => ejecutar(
    'Error al listar contratos',
    () => _fuente.listarPorTrabajador(idTrabajador),
  );
}
