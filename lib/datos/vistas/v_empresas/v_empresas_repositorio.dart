import 'package:trackmape_sup/datos/vistas/v_empresas/v_empresas_fuente.dart';
import 'package:trackmape_sup/datos/vistas/v_empresas/v_empresas_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class VEmpresasRepositorio {
  final _fuente = VEmpresasFuente();

  Future<List<VEmpresasModelo>> obtenerTodos() =>
      ejecutar('Error al obtener v_empresas', () => _fuente.obtenerTodos());

  Future<VEmpresasModelo?> obtenerPorId(String id) =>
      ejecutar('Error al obtener v_empresa', () => _fuente.obtenerPorId(id));
}
