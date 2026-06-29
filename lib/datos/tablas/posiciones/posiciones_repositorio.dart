import 'package:trackmape_sup/datos/tablas/posiciones/posiciones_fuente.dart';
import 'package:trackmape_sup/datos/tablas/posiciones/posiciones_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class PosicionesRepositorio {
  final _fuente = PosicionesFuente();

  Future<List<PosicionesModelo>> obtenerTodos() =>
      ejecutar('Error al obtener posiciones', () => _fuente.obtenerTodos());

  Future<PosicionesModelo?> obtenerPorId(String id) =>
      ejecutar('Error al obtener posicion', () => _fuente.obtenerPorId(id));

  Future<PosicionesModelo> insertar(PosicionesModelo modelo) =>
      ejecutar('Error al insertar posicion', () async {
        await _fuente.insertar(modelo);
        return modelo;
      });

  Future<PosicionesModelo> actualizar(PosicionesModelo modelo) =>
      ejecutar('Error al actualizar posicion', () async {
        await _fuente.actualizar(modelo);
        return modelo;
      });
}
