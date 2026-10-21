/// Responsabilidad: Definir la escala de redondeo de esquinas, como valor
/// numérico y como `BorderRadius` listo para usar.
library;

import 'package:flutter/painting.dart';

abstract final class Radios {
  static const double ninguno = 0; // tablas, separadores
  static const double minimo = 4; // chips, badges, tooltips
  static const double pequeno = 8; // inputs, botones, cards compactas
  static const double medio = 12; // cards, contenedores
  static const double grande = 16; // diálogos, paneles, bottom sheets
  static const double extraGrande = 24; // superficies destacadas
  static const double completo = 999; // píldora — FAB, avatares
}

abstract final class RadiosBorde {
  static const BorderRadius ninguno = BorderRadius.zero;
  static const BorderRadius minimo = BorderRadius.all(
    Radius.circular(Radios.minimo),
  );
  static const BorderRadius pequeno = BorderRadius.all(
    Radius.circular(Radios.pequeno),
  );
  static const BorderRadius medio = BorderRadius.all(
    Radius.circular(Radios.medio),
  );
  static const BorderRadius grande = BorderRadius.all(
    Radius.circular(Radios.grande),
  );
  static const BorderRadius extraGrande = BorderRadius.all(
    Radius.circular(Radios.extraGrande),
  );
  static const BorderRadius completo = BorderRadius.all(
    Radius.circular(Radios.completo),
  );
}
