/// Responsabilidad: Leer las empresas habilitadas y activas, por razon social.
library;

import 'package:trackmape_sup/app2/configuracion/empresas_habilitadas.dart';
import 'package:trackmape_sup/datos2/consulta_vista/campo_consulta_vista.dart';
import 'package:trackmape_sup/datos2/consulta_vista/orden_consulta_vista.dart';
import 'package:trackmape_sup/datos2/vistas/empresas_vt/empresas_vt_consulta.dart';
import 'package:trackmape_sup/datos2/vistas/empresas_vt/empresas_vt_modelo.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/conexion/equipos_conexion_activa.dart';

class EmpresasListarAccion {
  Future<List<EmpresasVtModelo>> ejecutar() => conexion.empresas.consultar(
    const EmpresasVtConsulta(
      idEmpresa: CampoConsultaVista.enLista(EmpresasHabilitadas.ids),
      activo: CampoConsultaVista.igualA(true),
      ordenarPor: [OrdenConsultaVista(EmpresasVtColumna.razonSocial)],
    ),
  );
}
