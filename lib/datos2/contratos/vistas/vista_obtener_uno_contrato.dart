/// Responsabilidad: Definir la capacidad de traer el unico registro de una
/// vista que cumple una consulta, o nulo si no hay ninguno.
///
/// T es el modelo de la vista y C su consulta: cada vista los completa con
/// sus propios tipos.
library;

abstract interface class VistaObtenerUnoContrato<T, C> {
  Future<T?> obtenerUno(C consulta);
}
