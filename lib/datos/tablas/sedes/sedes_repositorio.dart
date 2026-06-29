import 'package:trackmape_sup/datos/tablas/sedes/sedes_fuente.dart';
import 'package:trackmape_sup/datos/tablas/sedes/sedes_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class SedesRepositorio {
  final _fuente = SedesFuente();

  Future<List<SedesModelo>> obtenerTodos() =>
      ejecutar('Error al obtener sedes', () => _fuente.obtenerTodos());

  Future<SedesModelo?> obtenerPorId(String id) =>
      ejecutar('Error al obtener sede', () => _fuente.obtenerPorId(id));

  Future<SedesModelo> insertar(SedesModelo modelo) =>
      ejecutar('Error al insertar sede', () async {
        await _fuente.insertar(modelo);
        return modelo;
      });

  Future<SedesModelo> actualizar(SedesModelo modelo) =>
      ejecutar('Error al actualizar sede', () async {
        await _fuente.actualizar(modelo);
        return modelo;
      });
}
