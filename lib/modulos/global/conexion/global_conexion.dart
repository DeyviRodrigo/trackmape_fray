import 'package:trackmape_sup/datos/tablas/paises/paises_repositorio.dart';
import 'package:trackmape_sup/datos/vistas/v_empresas/v_empresas_repositorio.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajadores_temporal/v_trabajadores_temporal_repositorio.dart';

class GlobalConexion {
  final PaisesRepositorio paises = PaisesRepositorio();
  final VEmpresasRepositorio vEmpresas = VEmpresasRepositorio();
  final VTrabajadoresTemporalRepositorio vTrabajadoresTemporal =
      VTrabajadoresTemporalRepositorio();
}
