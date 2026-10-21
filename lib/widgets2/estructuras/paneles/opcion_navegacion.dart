/// Responsabilidad: Describir una opcion del panel de navegacion: con que se
/// identifica, que texto e icono muestra.
library;

import 'package:flutter/widgets.dart';

class OpcionNavegacion {
  const OpcionNavegacion({
    required this.id,
    required this.etiqueta,
    required this.icono,
  });

  /// Lo que el panel avisa al elegirla (por ejemplo la ruta).
  final String id;
  final String etiqueta;
  final IconData icono;
}
