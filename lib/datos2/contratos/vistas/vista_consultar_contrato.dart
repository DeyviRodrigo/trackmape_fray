/// Responsabilidad: Definir la capacidad de traer los registros de una vista
/// que cumplen una consulta.
///
/// T es el modelo de la vista y C su consulta: cada vista los completa con
/// sus propios tipos.
library;

abstract interface class VistaConsultarContrato<T, C> {
  Future<List<T>> consultar(C consulta);
}
