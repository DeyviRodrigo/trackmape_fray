/// Responsabilidad: Definir la escala de espaciados (padding, margin, gap)
/// sobre una grilla de 4 puntos, con un paso intermedio de 2 para ajustes finos.
library;

abstract final class Espaciado {
  static const double ninguno = 0; // sin espacio
  static const double micro = 2; // ajuste fino entre icono y texto
  static const double minimo = 4; // separación mínima, padding de iconos
  static const double pequeno = 8; // gap compacto entre elementos
  static const double medio = 12; // padding moderado, campos de formulario
  static const double base = 16; // padding estándar — el más común
  static const double comodo = 20; // algo más de aire
  static const double amplio = 24; // padding de secciones y diálogos
  static const double holgado = 32; // separación entre grupos
  static const double extraHolgado = 40; // separación entre bloques
  static const double espacioso = 48; // separaciones grandes
  static const double maximo = 64; // márgenes de página amplios
}
