import 'package:trackmape_sup/datos/tablas/trabajadores/trabajadores_fuente.dart';
import 'package:trackmape_sup/datos/tablas/trabajadores/trabajadores_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class TrabajadoresRepositorio {
  final _fuente = TrabajadoresFuente();

  Future<List<TrabajadoresModelo>> obtenerTodos() =>
      ejecutar('Error al obtener trabajadores', () => _fuente.obtenerTodos());

  Future<TrabajadoresModelo?> obtenerPorId(String id) =>
      ejecutar('Error al obtener trabajador', () => _fuente.obtenerPorId(id));

  Future<TrabajadoresModelo> insertar(TrabajadoresModelo modelo) =>
      ejecutar('Error al insertar trabajador', () async {
        await _fuente.insertar(modelo);
        return modelo;
      });

  Future<TrabajadoresModelo> insertarYRetornar(TrabajadoresModelo modelo) =>
      ejecutar(
        'Error al insertar trabajador',
        () => _fuente.insertarYRetornar(modelo),
      );

  Future<TrabajadoresModelo> actualizar(TrabajadoresModelo modelo) =>
      ejecutar('Error al actualizar trabajador', () async {
        await _fuente.actualizar(modelo);
        return modelo;
      });

  Future<void> desactivar(String id) =>
      ejecutar('Error al Eliminar trabajador', () => _fuente.desactivar(id));
}
