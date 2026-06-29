import 'package:trackmape_sup/datos/vistas/v_trabajador_credenciales_temp/v_trabajador_credenciales_temp_fuente.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajador_credenciales_temp/v_trabajador_credenciales_temp_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class VTrabajadorCredencialesTempRepositorio {
  final _fuente = VTrabajadorCredencialesTempFuente();

  Future<List<VTrabajadorCredencialesTempModelo>> listarPorTrabajador(
    String idTrabajador,
  ) => ejecutar(
    'Error al listar credenciales',
    () => _fuente.listarPorTrabajador(idTrabajador),
  );
}
