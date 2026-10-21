/// Responsabilidad: Definir la capacidad de activar un registro de tabla
/// identificado por su clave, revirtiendo una baja.
library;

abstract interface class TablaActivarContrato<K> {
  Future<void> activar(K clave);
}
