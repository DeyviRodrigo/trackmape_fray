import 'package:trackmape_sup/datos/tablas/niveles_ubigeo/niveles_ubigeo_fuente.dart';
import 'package:trackmape_sup/datos/tablas/niveles_ubigeo/niveles_ubigeo_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class NivelesUbigeoRepositorio {
  final _fuente = NivelesUbigeoFuente();

  Future<List<NivelesUbigeoModelo>> obtenerTodos() =>
      ejecutar('Error al obtener niveles_ubigeo', () => _fuente.obtenerTodos());

  Future<NivelesUbigeoModelo?> obtenerPorId(String id) =>
      ejecutar('Error al obtener nivel_ubigeo', () => _fuente.obtenerPorId(id));

  Future<NivelesUbigeoModelo> insertar(NivelesUbigeoModelo modelo) =>
      ejecutar('Error al insertar nivel_ubigeo', () async {
        await _fuente.insertar(modelo);
        return modelo;
      });

  Future<NivelesUbigeoModelo> actualizar(NivelesUbigeoModelo modelo) =>
      ejecutar('Error al actualizar nivel_ubigeo', () async {
        await _fuente.actualizar(modelo);
        return modelo;
      });
}
