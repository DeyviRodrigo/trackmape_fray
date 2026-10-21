/// Responsabilidad: Definir la conversion de una entrada tipada al mapa JSON
/// utilizado para insertar un registro de tabla.
library;

abstract interface class SerializadorInsercionContrato<I> {
  Map<String, dynamic> aJsonInsertar(I entrada);
}
