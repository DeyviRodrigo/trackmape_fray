/// Responsabilidad: Contrato de procedimientos del mensajero: ejecutar
/// funciones en el servidor.
library;

// INTERFAZ PROCEDIMIENTOS - Llamadas a funciones RPC
abstract interface class MensajeroProcedimientosInterfaz {
  // RPC - Devuelve la respuesta tal cual: un mapa, una lista o un valor simple
  Future<Object?> rpc(String funcion, Map<String, dynamic> parametros);
}
