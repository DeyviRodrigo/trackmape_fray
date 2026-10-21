/// Responsabilidad: Ofrecer los tipos presentes en el listado y reducirlo al
/// tipo elegido.
library;

import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/equipo_item_vista.dart';

class EquiposTipoFiltro {
  List<String> opciones(List<EquipoItemVista> lista) =>
      {for (final fila in lista) fila.tipo}.toList()..sort();

  List<EquipoItemVista> ejecutar(List<EquipoItemVista> lista, String? tipo) {
    if (tipo == null) return lista;
    return lista.where((fila) => fila.tipo == tipo).toList(growable: false);
  }
}
