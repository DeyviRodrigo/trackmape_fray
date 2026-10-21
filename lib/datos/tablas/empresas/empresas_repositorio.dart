import 'package:trackmape_sup/datos/tablas/empresas/empresas_fuente.dart';
import 'package:trackmape_sup/datos/tablas/empresas/empresas_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class EmpresasRepositorio {
  final _fuente = EmpresasFuente();

  Future<List<EmpresasModelo>> obtenerTodos() =>
      ejecutar('Error al obtener empresas', () => _fuente.obtenerTodos());

  Future<EmpresasModelo?> obtenerPorId(String id) =>
      ejecutar('Error al obtener empresa', () => _fuente.obtenerPorId(id));

  Future<EmpresasModelo> insertar(EmpresasModelo modelo) =>
      ejecutar('Error al insertar empresa', () async {
        await _fuente.insertar(modelo);
        return modelo;
      });

  Future<EmpresasModelo> actualizar(EmpresasModelo modelo) =>
      ejecutar('Error al actualizar empresa', () async {
        await _fuente.actualizar(modelo);
        return modelo;
      });

  Future<void> desactivar(String id) =>
      ejecutar('Error al Eliminar empresa', () => _fuente.desactivar(id));
}
