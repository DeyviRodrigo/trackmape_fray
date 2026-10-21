/// Responsabilidad: Definir las opacidades para capas de interacción, estados
/// deshabilitados y velos. Siguen los valores de capa de estado de Material 3.
library;

abstract final class Opacidad {
  static const double hover = 0.08; // capa al pasar el puntero
  static const double foco = 0.12; // capa con foco de teclado
  static const double presionado = 0.12; // capa al pulsar
  static const double seleccionado = 0.12; // fondo de un elemento seleccionado
  static const double arrastre = 0.16; // elemento en arrastre
  static const double deshabilitado = 0.38; // contenido deshabilitado
  static const double velo = 0.5; // fondo detrás de diálogos y hojas
  static const double opaco = 1;
}
