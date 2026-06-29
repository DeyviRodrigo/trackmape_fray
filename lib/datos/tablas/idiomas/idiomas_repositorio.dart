import 'package:trackmape_sup/datos/tablas/idiomas/idiomas_fuente.dart';
import 'package:trackmape_sup/datos/tablas/idiomas/idiomas_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class IdiomasRepositorio {
  final _fuente = IdiomasFuente();

  Future<List<IdiomasModelo>> obtenerTodos() =>
      ejecutar('Error al obtener idiomas', () => _fuente.obtenerTodos());

  Future<IdiomasModelo?> obtenerPorId(String id) =>
      ejecutar('Error al obtener idioma', () => _fuente.obtenerPorId(id));

  Future<IdiomasModelo> insertar(IdiomasModelo modelo) =>
      ejecutar('Error al insertar idioma', () async {
        await _fuente.insertar(modelo);
        return modelo;
      });

  Future<IdiomasModelo> actualizar(IdiomasModelo modelo) =>
      ejecutar('Error al actualizar idioma', () async {
        await _fuente.actualizar(modelo);
        return modelo;
      });
}
