import 'package:trackmape_sup/datos/tablas/equipos_control/equipos_control_fuente.dart';
import 'package:trackmape_sup/datos/tablas/equipos_control/equipos_control_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class EquiposControlRepositorio {
  final _fuente = EquiposControlFuente();

  Future<List<EquiposControlModelo>> obtenerTodos() => ejecutar(
    'Error al obtener equipos_control',
    () => _fuente.obtenerTodos(),
  );

  Future<EquiposControlModelo?> obtenerPorId(String id) => ejecutar(
    'Error al obtener equipo_control',
    () => _fuente.obtenerPorId(id),
  );

  Future<EquiposControlModelo> insertar(EquiposControlModelo modelo) =>
      ejecutar('Error al insertar equipo_control', () async {
        await _fuente.insertar(modelo);
        return modelo;
      });

  Future<EquiposControlModelo> actualizar(EquiposControlModelo modelo) =>
      ejecutar('Error al actualizar equipo_control', () async {
        await _fuente.actualizar(modelo);
        return modelo;
      });
}
