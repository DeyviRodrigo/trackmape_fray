/// Responsabilidad: Definir la capacidad de actualizar un registro de tabla
/// mediante su clave y un conjunto de cambios tipados.
library;

abstract interface class TablaActualizarContrato<K, U> {
  Future<void> actualizar(K clave, U cambios);
}
