/// Responsabilidad: Acciones superpuestas a la visualizacion de un listado
/// (por ejemplo Agregar). Las apila de abajo hacia arriba.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';

class SubzonaAccionesFlotantes extends StatelessWidget {
  const SubzonaAccionesFlotantes({super.key, required this.acciones});

  /// La ultima queda abajo, mas cerca de la mano.
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: Espaciado.pequeno,
      children: acciones,
    );
  }
}
