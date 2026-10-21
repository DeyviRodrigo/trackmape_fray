/// Responsabilidad: Clasificar los fallos del backend sin acoplar a quien los
/// recibe a los codigos de una tecnologia concreta (PostgreSQL, PostgREST...).
library;

// ERROR BACKEND TIPO - Clases de fallo que cualquier backend puede producir
enum ErrorBackendTipo {
  // El usuario no tiene permiso para la operacion
  autorizacion,

  // Un valor enviado no tiene la forma o el tipo aceptado
  validacion,

  // La operacion rompe una regla de integridad: duplicado, relacion invalida
  integridad,

  // Lo pedido no existe en el backend: tabla, columna o funcion
  contrato,

  // El backend no responde o no se puede alcanzar
  noDisponible,

  // El backend respondio con un fallo sin clasificar
  remoto,

  // Fallo de origen desconocido
  desconocido,
}
