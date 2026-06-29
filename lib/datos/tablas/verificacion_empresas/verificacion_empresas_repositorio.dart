import 'package:trackmape_sup/datos/tablas/verificacion_empresas/verificacion_empresas_fuente.dart';
import 'package:trackmape_sup/datos/tablas/verificacion_empresas/verificacion_empresas_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class VerificacionEmpresasRepositorio {
  final _fuente = VerificacionEmpresasFuente();

  Future<List<VerificacionEmpresasModelo>> obtenerTodos() => ejecutar(
    'Error al obtener verificaciones de empresas',
    () => _fuente.obtenerTodos(),
  );

  Future<VerificacionEmpresasModelo?> obtenerPorId(String id) => ejecutar(
    'Error al obtener verificacion de empresa',
    () => _fuente.obtenerPorId(id),
  );

  Future<VerificacionEmpresasModelo> insertar(
    VerificacionEmpresasModelo modelo,
  ) => ejecutar('Error al insertar verificacion de empresa', () async {
    await _fuente.insertar(modelo);
    return modelo;
  });

  Future<VerificacionEmpresasModelo> actualizar(
    VerificacionEmpresasModelo modelo,
  ) => ejecutar('Error al actualizar verificacion de empresa', () async {
    await _fuente.actualizar(modelo);
    return modelo;
  });
}
