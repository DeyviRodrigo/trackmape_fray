/// Responsabilidad: Sostener el detalle de un equipo mientras la pagina lo
/// muestra, y darlo de baja.
library;

import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/servicios/equipos_dar_baja_servicio.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/servicios/equipos_mostrar_detalle_servicio.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/transformadores/a_vista/equipo_detalle_vista_transformador.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/equipo_detalle_vista.dart';
import 'package:trackmape_sup/pestanas/general/funciones/controladores/controlador_presentacion.dart';

class EquiposDetalleControlador extends ControladorPresentacion {
  EquiposDetalleControlador(this._id) {
    // Arranca cargando: la pagina no debe pintar un vacio antes de cargar().
    cargando = true;
  }

  final _mostrarDetalle = EquiposMostrarDetalleServicio();
  final _darBaja = EquiposDarBajaServicio();
  final String _id;

  /// Nulo despues de cargar = el equipo no existe.
  EquipoDetalleVista? registro;

  Future<void> cargar() => ejecutarCarga(() async {
    final crudo = await _mostrarDetalle.ejecutar(_id);
    registro = crudo == null
        ? null
        : EquipoDetalleVistaTransformador.transformar(crudo);
  });

  /// Devuelve `true` si se dio de baja.
  Future<bool> darBaja() async {
    await ejecutarGuardado(() => _darBaja.ejecutar(_id));
    if (error != null) return false;
    await cargar();
    return true;
  }
}
