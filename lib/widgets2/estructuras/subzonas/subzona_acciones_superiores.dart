/// Responsabilidad: Fila superior del contenido de un listado donde van la
/// busqueda y los filtros. Solo los acomoda; quien la usa decide cuales van.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';

class SubzonaAccionesSuperiores extends StatelessWidget {
  const SubzonaAccionesSuperiores({super.key, required this.acciones});

  /// Para que la busqueda ocupe el ancho sobrante, se envuelve en `Expanded`.
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    return Row(spacing: Espaciado.pequeno, children: acciones);
  }
}
