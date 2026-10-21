/// Responsabilidad: Cargar lo que necesita el formulario: empresas, sedes y,
/// si se edita, el equipo.
library;

import 'package:trackmape_sup/datos2/vistas/empresas_vt/empresas_vt_modelo.dart';
import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_modelo.dart';
import 'package:trackmape_sup/datos2/vistas/sedes_vt/sedes_vt_modelo.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/acciones/empresas_listar_accion.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/acciones/equipos_obtener_accion.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/acciones/sedes_listar_accion.dart';

class EquiposMostrarFormularioServicio {
  final _obtener = EquiposObtenerAccion();
  final _empresas = EmpresasListarAccion();
  final _sedes = SedesListarAccion();

  Future<
    (EquiposControlVtModelo?, List<EmpresasVtModelo>, List<SedesVtModelo>)
  >
  ejecutar(String? id) async {
    final (equipo, empresas, sedes) = await (
      id == null ? Future.value(null) : _obtener.ejecutar(id),
      _empresas.ejecutar(),
      _sedes.ejecutar(),
    ).wait;
    return (equipo, empresas, sedes);
  }
}
