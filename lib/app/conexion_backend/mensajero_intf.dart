abstract class MensajeroIntf {
  Future<List<Map<String, dynamic>>> seleccionar(String tabla);
  Future<List<Map<String, dynamic>>> listarPor(
    String tabla,
    String campo,
    String valor,
  );
  Future<Map<String, dynamic>?> seleccionarPor(
    String tabla,
    String campo,
    String valor,
  );
  Future<void> insertar(String tabla, Map<String, dynamic> datos);
  Future<Map<String, dynamic>> insertarYRetornar(
    String tabla,
    Map<String, dynamic> datos,
  );
  Future<void> actualizar(
    String tabla,
    Map<String, dynamic> datos,
    String campo,
    String valor,
  );
  Future<void> desactivar(
    String tabla,
    Map<String, dynamic> datos,
    String campo,
    String valor,
  );
  Future<Map<String, dynamic>> rpc(String funcion, Map<String, dynamic> params);
}
