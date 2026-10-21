/// Responsabilidad: Cargar lo que necesita la pagina de detalle.
library;

import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_modelo.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/acciones/equipos_obtener_accion.dart';

class EquiposMostrarDetalleServicio {
  final _obtener = EquiposObtenerAccion();

  Future<EquiposControlVtModelo?> ejecutar(String id) => _obtener.ejecutar(id);
}
