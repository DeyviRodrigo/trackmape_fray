/// Responsabilidad: Leer un equipo por su id.
library;

import 'package:trackmape_sup/datos2/consulta_vista/campo_consulta_vista.dart';
import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_consulta.dart';
import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_modelo.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/conexion/equipos_conexion_activa.dart';

class EquiposObtenerAccion {
  Future<EquiposControlVtModelo?> ejecutar(String id) =>
      conexion.vistaPrincipal.obtenerUno(
        EquiposControlVtConsulta(idEquipoControl: CampoConsultaVista.igualA(id)),
      );
}
