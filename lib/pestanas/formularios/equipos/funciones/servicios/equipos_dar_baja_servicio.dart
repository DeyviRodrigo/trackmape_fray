/// Responsabilidad: Dar de baja un equipo poniendo su fecha final en hoy.
library;

import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/acciones/equipos_actualizar_accion.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/transformadores/a_comando/equipo_baja_comando_transformador.dart';

class EquiposDarBajaServicio {
  final _actualizar = EquiposActualizarAccion();

  Future<void> ejecutar(String id) => _actualizar.ejecutar(
    id,
    EquipoBajaComandoTransformador.darBaja(DateTime.now()),
  );
}
