/// Responsabilidad: Declarar los repositorios de datos2 que usa la pestana
/// Equipos. Solo las acciones la conocen.
library;

import 'package:trackmape_sup/datos2/tablas/equipos_control/equipos_control_repositorio.dart';
import 'package:trackmape_sup/datos2/vistas/empresas_vt/empresas_vt_repositorio.dart';
import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_repositorio.dart';
import 'package:trackmape_sup/datos2/vistas/sedes_vt/sedes_vt_repositorio.dart';

class EquiposConexion {
  // PRINCIPAL - Escritura en la tabla, lectura en su vista
  final EquiposControlRepositorio tablaPrincipal = EquiposControlRepositorio();
  final EquiposControlVtRepositorio vistaPrincipal =
      EquiposControlVtRepositorio();

  // CATALOGOS - Se leen de su vista, nunca de su tabla
  final EmpresasVtRepositorio empresas = EmpresasVtRepositorio();
  final SedesVtRepositorio sedes = SedesVtRepositorio();
}
