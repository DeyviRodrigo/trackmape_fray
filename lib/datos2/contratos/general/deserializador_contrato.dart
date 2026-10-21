/// Responsabilidad: Definir la conversion de una respuesta JSON en un objeto
/// del tipo T.
library;

abstract interface class DeserializadorContrato<T> {
  T desdeJson(Map<String, dynamic> json);
}
