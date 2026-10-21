/// Responsabilidad: Clasificar los fallos de la capa de datos sin acoplar la
/// presentacion a codigos de PostgreSQL ni a ningun backend concreto.
library;

// ERROR DATOS TIPO - Clases de fallo que un repositorio puede informar
enum ErrorDatosTipo {
  // El usuario no tiene permiso para la operacion
  autorizacion,

  // Un valor enviado no tiene la forma o el tipo aceptado
  validacion,

  // La operacion rompe una regla de integridad: duplicado, relacion invalida
  integridad,

  // Lo pedido o lo recibido no cumple el contrato de datos esperado
  contrato,

  // El backend no responde o no se puede alcanzar
  noDisponible,

  // El backend respondio con un fallo sin clasificar
  remoto,

  // Fallo de origen desconocido
  desconocido,
}
