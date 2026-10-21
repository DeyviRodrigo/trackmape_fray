/// Responsabilidad: Definir duraciones y curvas de animación compartidas.
library;

import 'package:flutter/animation.dart';

abstract final class Duraciones {
  static const Duration instantanea = Duration.zero;

  // hover, foco
  static const Duration rapida = Duration(milliseconds: 100);

  // cambios de color
  static const Duration corta = Duration(milliseconds: 150);

  // expandir, colapsar
  static const Duration media = Duration(milliseconds: 250);

  // abrir hojas, paneles
  static const Duration larga = Duration(milliseconds: 400);

  // transiciones de página
  static const Duration muyLarga = Duration(milliseconds: 600);
}

abstract final class Curvas {
  static const Curve estandar = Curves.easeInOutCubic; // la más común
  static const Curve entrada = Curves.easeOutCubic; // algo que aparece
  static const Curve salida = Curves.easeInCubic; // algo que desaparece
  // movimientos grandes
  static const Curve enfatica = Curves.easeInOutCubicEmphasized;
  static const Curve lineal = Curves.linear; // progreso, rotación continua
}
