/// Responsabilidad: Definir tamaños fijos de iconos, controles, avatares y
/// superficies de referencia.
library;

abstract final class TamanosIcono {
  static const double pequeno = 16; // dentro de texto o chips
  static const double medio = 20; // dentro de campos y botones compactos
  static const double base = 24; // estándar
  static const double grande = 32; // destacados
  static const double enorme = 48; // estados vacíos, ilustrativos
}

abstract final class TamanosControl {
  static const double alturaCompacta = 32; // tablas densas, chips
  static const double alturaBase = 40; // botones y campos estándar
  static const double alturaComoda = 48; // táctil, formularios en celular
  static const double objetivoTactil = 48; // área mínima pulsable
}

abstract final class TamanosAvatar {
  static const double pequeno = 24;
  static const double medio = 32;
  static const double grande = 40;
  static const double enorme = 64;
}

abstract final class TamanosSuperficie {
  static const double navegacionComprimida = 76; // panel lateral solo iconos
  static const double navegacionExpandida = 296; // panel lateral con etiquetas
  static const double dialogo = 560; // ancho de diálogos y ventanas previas
  static const double lecturaMaxima = 720; // ancho máximo de texto o formulario

  /// Valor de partida para pasar de apilado a fila. Cada pieza puede declarar
  /// el suyo: no es un breakpoint global.
  static const double umbralHorizontal = 720;
}
