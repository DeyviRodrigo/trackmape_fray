/// Responsabilidad: Leer los equipos de las empresas habilitadas, ordenados
/// por nombre.
library;

import 'package:trackmape_sup/app2/configuracion/empresas_habilitadas.dart';
import 'package:trackmape_sup/datos2/consulta_vista/campo_consulta_vista.dart';
import 'package:trackmape_sup/datos2/consulta_vista/orden_consulta_vista.dart';
import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_consulta.dart';
import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_modelo.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/conexion/equipos_conexion_activa.dart';

class EquiposListarAccion {
  Future<List<EquiposControlVtModelo>> ejecutar() =>
      conexion.vistaPrincipal.consultar(
        const EquiposControlVtConsulta(
          fkEmpresa: CampoConsultaVista.enLista(EmpresasHabilitadas.ids),
          ordenarPor: [OrdenConsultaVista(EquiposControlVtColumna.nombre)],
        ),
      );
}
