import 'package:trackmape_sup/datos/tablas/empresas/empresas_repositorio.dart';
import 'package:trackmape_sup/datos/tablas/equipos_control/equipos_control_repositorio.dart';
import 'package:trackmape_sup/datos/tablas/posiciones/posiciones_repositorio.dart';
import 'package:trackmape_sup/datos/tablas/posiciones_temp/posiciones_temp_repositorio.dart';
import 'package:trackmape_sup/datos/tablas/sedes/sedes_repositorio.dart';

class OperacionConexion {
  final EmpresasRepositorio empresas = EmpresasRepositorio();
  final SedesRepositorio sedes = SedesRepositorio();
  final EquiposControlRepositorio equiposControl = EquiposControlRepositorio();
  final PosicionesRepositorio posiciones = PosicionesRepositorio();
  final PosicionesTempRepositorio posicionesTemp = PosicionesTempRepositorio();
}
