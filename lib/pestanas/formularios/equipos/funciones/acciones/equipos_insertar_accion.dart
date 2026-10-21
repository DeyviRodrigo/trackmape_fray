/// Responsabilidad: Crear un equipo y devolver su id.
library;

import 'package:trackmape_sup/datos2/tablas/equipos_control/equipos_control_comandos.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/conexion/equipos_conexion_activa.dart';

class EquiposInsertarAccion {
  Future<String> ejecutar(EquiposControlInsertar comando) =>
      conexion.tablaPrincipal.insertarYRetornar(comando);
}
