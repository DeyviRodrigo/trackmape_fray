/// Responsabilidad: Cargar lo que necesita la pagina de listado.
library;

import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_modelo.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/acciones/equipos_listar_accion.dart';

class EquiposMostrarDatosServicio {
  final _listar = EquiposListarAccion();

  Future<List<EquiposControlVtModelo>> ejecutar() => _listar.ejecutar();
}
