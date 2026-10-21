/// Responsabilidad: Reducir el listado de equipos por nombre o codigo.
library;

import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/equipo_item_vista.dart';

class EquiposBuscarFiltro {
  List<EquipoItemVista> ejecutar(List<EquipoItemVista> lista, String texto) {
    final consulta = texto.trim().toLowerCase();
    if (consulta.isEmpty) return lista;
    return lista
        .where(
          (fila) =>
              fila.nombre.toLowerCase().contains(consulta) ||
              fila.codigo.toLowerCase().contains(consulta),
        )
        .toList(growable: false);
  }
}
