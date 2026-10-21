/// Responsabilidad: Definir los grosores de línea para bordes, divisores e
/// indicadores de foco.
library;

abstract final class Grosores {
  static const double ninguno = 0;
  static const double fino = 1; // borde y divisor estándar
  static const double medio = 1.5; // borde con algo de énfasis
  static const double grueso = 2; // foco, selección
  static const double enfatico = 3; // indicador activo (pestaña, navegación)
}
