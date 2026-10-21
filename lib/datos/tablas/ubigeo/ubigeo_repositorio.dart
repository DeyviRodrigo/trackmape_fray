import 'package:trackmape_sup/datos/tablas/ubigeo/ubigeo_fuente.dart';
import 'package:trackmape_sup/datos/tablas/ubigeo/ubigeo_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class UbigeoRepositorio {
  final _fuente = UbigeoFuente();

  Future<List<UbigeoModelo>> obtenerTodos() =>
      ejecutar('Error al obtener ubigeos', () => _fuente.obtenerTodos());

  Future<UbigeoModelo?> obtenerPorId(String id) =>
      ejecutar('Error al obtener ubigeo', () => _fuente.obtenerPorId(id));

  Future<UbigeoModelo> insertar(UbigeoModelo modelo) =>
      ejecutar('Error al insertar ubigeo', () async {
        await _fuente.insertar(modelo);
        return modelo;
      });

  Future<UbigeoModelo> actualizar(UbigeoModelo modelo) =>
      ejecutar('Error al actualizar ubigeo', () async {
        await _fuente.actualizar(modelo);
        return modelo;
      });
}
