import 'package:trackmape_sup/datos/tablas/personas/personas_fuente.dart';
import 'package:trackmape_sup/datos/tablas/personas/personas_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class PersonasRepositorio {
  final _fuente = PersonasFuente();

  Future<List<PersonasModelo>> obtenerTodos() =>
      ejecutar('Error al obtener personas', () => _fuente.obtenerTodos());

  Future<PersonasModelo?> obtenerPorId(String id) =>
      ejecutar('Error al obtener persona', () => _fuente.obtenerPorId(id));

  Future<PersonasModelo> insertar(PersonasModelo modelo) =>
      ejecutar('Error al insertar persona', () async {
        await _fuente.insertar(modelo);
        return modelo;
      });

  Future<PersonasModelo> insertarYRetornar(PersonasModelo modelo) => ejecutar(
    'Error al insertar persona',
    () => _fuente.insertarYRetornar(modelo),
  );

  Future<PersonasModelo> actualizar(PersonasModelo modelo) =>
      ejecutar('Error al actualizar persona', () async {
        await _fuente.actualizar(modelo);
        return modelo;
      });
}
