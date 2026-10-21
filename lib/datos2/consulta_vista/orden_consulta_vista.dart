/// Responsabilidad: Representar un criterio de orden de la consulta de una
/// vista, sobre una columna de esa misma vista.
library;

import 'package:trackmape_sup/datos2/consulta_vista/columna_vista.dart';

// ORDEN CONSULTA VISTA - Columna de la vista y sentido del orden
final class OrdenConsultaVista<C extends ColumnaVista> {
  const OrdenConsultaVista(this.columna, {this.ascendente = true});

  final C columna;
  final bool ascendente;
}
