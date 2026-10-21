/// Responsabilidad: Cambiar las columnas indicadas de un equipo.
library;

import 'package:trackmape_sup/datos2/tablas/equipos_control/equipos_control_comandos.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/conexion/equipos_conexion_activa.dart';

class EquiposActualizarAccion {
  Future<void> ejecutar(String id, EquiposControlActualizar cambios) =>
      conexion.tablaPrincipal.actualizar(id, cambios);
}
