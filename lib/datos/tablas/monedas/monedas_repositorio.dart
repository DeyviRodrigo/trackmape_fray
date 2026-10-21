import 'package:trackmape_sup/datos/tablas/monedas/monedas_fuente.dart';
import 'package:trackmape_sup/datos/tablas/monedas/monedas_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class MonedasRepositorio {
  final _fuente = MonedasFuente();

  Future<List<MonedasModelo>> obtenerTodos() =>
      ejecutar('Error al obtener monedas', () => _fuente.obtenerTodos());

  Future<MonedasModelo?> obtenerPorId(String id) =>
      ejecutar('Error al obtener moneda', () => _fuente.obtenerPorId(id));

  Future<MonedasModelo> insertar(MonedasModelo modelo) =>
      ejecutar('Error al insertar moneda', () async {
        await _fuente.insertar(modelo);
        return modelo;
      });

  Future<MonedasModelo> actualizar(MonedasModelo modelo) =>
      ejecutar('Error al actualizar moneda', () async {
        await _fuente.actualizar(modelo);
        return modelo;
      });
}
