/// Responsabilidad: Definir los niveles de elevación y construir sus sombras con
/// el color de sombra del tema activo.
library;

import 'package:flutter/painting.dart';

abstract final class Elevacion {
  static const double nivel0 = 0; // a ras: cards con borde, tablas
  static const double nivel1 = 1; // cards destacadas
  static const double nivel2 = 3; // menús, selectores
  static const double nivel3 = 6; // acciones flotantes
  static const double nivel4 = 8; // hojas superpuestas, panel de navegación
  static const double nivel5 = 12; // diálogos
}

abstract final class Sombras {
  /// Sombra para un nivel de [Elevacion]. El color llega del tema
  /// (`context.colores.sombra`) para que funcione en claro y oscuro.
  static List<BoxShadow> de(double nivel, Color color) {
    if (nivel <= 0) return const [];
    return [
      BoxShadow(
        color: color,
        blurRadius: nivel * 2,
        offset: Offset(0, nivel / 2),
      ),
    ];
  }
}
