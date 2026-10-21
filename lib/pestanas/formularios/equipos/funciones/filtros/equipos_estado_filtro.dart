/// Responsabilidad: Reducir el listado de equipos al estado elegido.
library;

import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/equipo_item_vista.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/estado_equipo.dart';

class EquiposEstadoFiltro {
  List<EquipoItemVista> ejecutar(
    List<EquipoItemVista> lista,
    EstadoEquipo? estado,
  ) {
    if (estado == null) return lista;
    return lista.where((fila) => fila.estado == estado).toList(growable: false);
  }
}
