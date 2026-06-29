abstract class FuenteVistaContrato<T> {
  Future<List<T>> obtenerTodos();
  Future<T?> obtenerPorId(String id);
}
