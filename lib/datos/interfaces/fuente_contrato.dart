abstract class FuenteContrato<T> {
  Future<List<T>> obtenerTodos();
  Future<T?> obtenerPorId(String id);
  Future<void> insertar(T modelo);
  Future<void> actualizar(T modelo);
}
