/// Responsabilidad: Definir familias, pesos y la escala tipográfica. Los estilos
/// no llevan color: el tema lo aplica según el modo claro u oscuro.
library;

import 'package:flutter/painting.dart';

abstract final class Fuentes {
  /// `null` usa la fuente del sistema. Para una fuente propia, declararla en
  /// pubspec.yaml y poner aquí su nombre.
  static const String? base = null;
  static const String codigo = 'monospace';
}

abstract final class PesosFuente {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medio = FontWeight.w500;
  static const FontWeight seminegrita = FontWeight.w600;
  static const FontWeight negrita = FontWeight.w700;
}

abstract final class EscalaTipografica {
  static const TextStyle display = TextStyle(
    fontFamily: Fuentes.base,
    fontSize: 36,
    height: 44 / 36,
    fontWeight: PesosFuente.seminegrita,
    letterSpacing: -0.5,
  );
  static const TextStyle tituloGrande = TextStyle(
    fontFamily: Fuentes.base,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: PesosFuente.seminegrita,
    letterSpacing: -0.25,
  );
  static const TextStyle titulo = TextStyle(
    fontFamily: Fuentes.base,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: PesosFuente.seminegrita,
  );
  static const TextStyle subtitulo = TextStyle(
    fontFamily: Fuentes.base,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: PesosFuente.medio,
  );
  static const TextStyle cuerpoGrande = TextStyle(
    fontFamily: Fuentes.base,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: PesosFuente.regular,
  );
  static const TextStyle cuerpo = TextStyle(
    fontFamily: Fuentes.base,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: PesosFuente.regular,
  );
  static const TextStyle nota = TextStyle(
    fontFamily: Fuentes.base,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: PesosFuente.regular,
  );
  static const TextStyle etiqueta = TextStyle(
    fontFamily: Fuentes.base,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: PesosFuente.medio,
    letterSpacing: 0.1,
  );
  static const TextStyle etiquetaPequena = TextStyle(
    fontFamily: Fuentes.base,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: PesosFuente.medio,
    letterSpacing: 0.2,
  );
  static const TextStyle micro = TextStyle(
    fontFamily: Fuentes.base,
    fontSize: 11,
    height: 16 / 11,
    fontWeight: PesosFuente.medio,
    letterSpacing: 0.4,
  );
  static const TextStyle codigo = TextStyle(
    fontFamily: Fuentes.codigo,
    fontSize: 13,
    height: 20 / 13,
    fontWeight: PesosFuente.regular,
  );
}
