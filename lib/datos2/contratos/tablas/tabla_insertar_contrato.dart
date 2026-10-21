/// Responsabilidad: Definir la capacidad de insertar un registro de tabla a
/// partir de una entrada tipada, sin pedir respuesta.
library;

abstract interface class TablaInsertarContrato<I> {
  Future<void> insertar(I entrada);
}
