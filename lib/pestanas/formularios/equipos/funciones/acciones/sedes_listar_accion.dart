/// Responsabilidad: Leer las sedes activas de las empresas habilitadas, por
/// nombre.
library;

import 'package:trackmape_sup/app2/configuracion/empresas_habilitadas.dart';
import 'package:trackmape_sup/datos2/consulta_vista/campo_consulta_vista.dart';
import 'package:trackmape_sup/datos2/consulta_vista/orden_consulta_vista.dart';
import 'package:trackmape_sup/datos2/vistas/sedes_vt/sedes_vt_consulta.dart';
import 'package:trackmape_sup/datos2/vistas/sedes_vt/sedes_vt_modelo.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/conexion/equipos_conexion_activa.dart';

class SedesListarAccion {
  Future<List<SedesVtModelo>> ejecutar() => conexion.sedes.consultar(
    const SedesVtConsulta(
      fkEmpresa: CampoConsultaVista.enLista(EmpresasHabilitadas.ids),
      activo: CampoConsultaVista.igualA(true),
      ordenarPor: [OrdenConsultaVista(SedesVtColumna.nombre)],
    ),
  );
}
