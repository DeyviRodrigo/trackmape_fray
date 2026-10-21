/// Responsabilidad: Definir la capacidad de desactivar un registro de tabla
/// identificado por su clave, sin eliminarlo (borrado logico).
library;

abstract interface class TablaDesactivarContrato<K> {
  Future<void> desactivar(K clave);
}
