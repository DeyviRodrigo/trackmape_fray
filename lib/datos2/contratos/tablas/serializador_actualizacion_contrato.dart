/// Responsabilidad: Definir la conversion de cambios tipados al mapa JSON
/// utilizado para actualizar un registro de tabla.
library;

abstract interface class SerializadorActualizacionContrato<U> {
  Map<String, dynamic> aJsonActualizar(U cambios);
}
