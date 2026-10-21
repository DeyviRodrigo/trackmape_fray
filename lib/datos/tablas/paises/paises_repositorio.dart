import 'package:trackmape_sup/datos/tablas/paises/paises_fuente.dart';
import 'package:trackmape_sup/datos/tablas/paises/paises_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class PaisesRepositorio {
  final _fuente = PaisesFuente();

  Future<List<PaisesModelo>> obtenerTodos() =>
      ejecutar('Error al obtener paises', () => _fuente.obtenerTodos());

  Future<PaisesModelo?> obtenerPorId(String id) =>
      ejecutar('Error al obtener pais', () => _fuente.obtenerPorId(id));

  Future<PaisesModelo> insertar(PaisesModelo modelo) =>
      ejecutar('Error al insertar pais', () async {
        await _fuente.insertar(modelo);
        return modelo;
      });

  Future<PaisesModelo> actualizar(PaisesModelo modelo) =>
      ejecutar('Error al actualizar pais', () async {
        await _fuente.actualizar(modelo);
        return modelo;
      });
}
