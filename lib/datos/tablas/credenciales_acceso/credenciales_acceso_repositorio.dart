import 'package:trackmape_sup/datos/tablas/credenciales_acceso/credenciales_acceso_fuente.dart';
import 'package:trackmape_sup/datos/tablas/credenciales_acceso/credenciales_acceso_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class CredencialesAccesoRepositorio {
  final _fuente = CredencialesAccesoFuente();

  Future<List<CredencialesAccesoModelo>> obtenerTodos() => ejecutar(
    'Error al obtener credenciales de acceso',
    () => _fuente.obtenerTodos(),
  );

  Future<CredencialesAccesoModelo?> obtenerPorId(String id) => ejecutar(
    'Error al obtener credencial de acceso',
    () => _fuente.obtenerPorId(id),
  );

  Future<CredencialesAccesoModelo> insertar(CredencialesAccesoModelo modelo) =>
      ejecutar('Error al insertar credencial de acceso', () async {
        await _fuente.insertar(modelo);
        return modelo;
      });

  Future<CredencialesAccesoModelo> actualizar(
    CredencialesAccesoModelo modelo,
  ) => ejecutar('Error al actualizar credencial de acceso', () async {
    await _fuente.actualizar(modelo);
    return modelo;
  });
}
