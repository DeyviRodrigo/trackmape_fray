import 'package:trackmape_sup/datos/tablas/posiciones_temp/posiciones_temp_fuente.dart';
import 'package:trackmape_sup/datos/tablas/posiciones_temp/posiciones_temp_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class PosicionesTempRepositorio {
  final _fuente = PosicionesTempFuente();

  Future<List<PosicionesTempModelo>> obtenerTodos() => ejecutar(
    'Error al obtener posiciones_temp',
    () => _fuente.obtenerTodos(),
  );

  Future<PosicionesTempModelo?> obtenerPorId(String id) => ejecutar(
    'Error al obtener posicion_temp',
    () => _fuente.obtenerPorId(id),
  );

  Future<PosicionesTempModelo> insertar(PosicionesTempModelo modelo) =>
      ejecutar('Error al insertar posicion_temp', () async {
        await _fuente.insertar(modelo);
        return modelo;
      });

  Future<PosicionesTempModelo> actualizar(PosicionesTempModelo modelo) =>
      ejecutar('Error al actualizar posicion_temp', () async {
        await _fuente.actualizar(modelo);
        return modelo;
      });
}
