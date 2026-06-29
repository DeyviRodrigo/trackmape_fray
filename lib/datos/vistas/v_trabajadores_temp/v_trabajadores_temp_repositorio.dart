import 'package:trackmape_sup/datos/vistas/v_trabajadores_temp/v_trabajadores_temp_fuente.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajadores_temp/v_trabajadores_temp_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class VTrabajadoresTempRepositorio {
  final _fuente = VTrabajadoresTempFuente();

  Future<VTrabajadoresTempModelo?> obtenerPorId(String idTrabajador) =>
      ejecutar(
        'Error al obtener v_trabajadores_temp',
        () => _fuente.obtenerPorId(idTrabajador),
      );
}
