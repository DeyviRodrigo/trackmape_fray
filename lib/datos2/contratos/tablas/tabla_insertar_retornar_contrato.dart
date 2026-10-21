/// Responsabilidad: Definir la capacidad de insertar un registro de tabla y
/// recibir la clave que la base le asigno.
///
/// Devuelve la clave y no el registro: las tablas son de escritura y no tienen
/// modelo de lectura. Quien necesite el registro completo lo lee de su vista.
library;

abstract interface class TablaInsertarRetornarContrato<I, K> {
  Future<K> insertarYRetornar(I entrada);
}
