/// Responsabilidad: Lugar de la coleccion en un listado (tabla, tarjetas,
/// mapa). Ocupa el espacio sobrante y es lo unico que se desplaza.
library;

import 'package:flutter/material.dart';

class SubzonaVisualizacion extends StatelessWidget {
  const SubzonaVisualizacion({super.key, required this.child});

  /// La coleccion maneja su propio desplazamiento.
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
