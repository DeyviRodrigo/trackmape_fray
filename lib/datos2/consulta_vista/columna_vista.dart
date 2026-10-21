/// Responsabilidad: Definir lo que cumple el enum de columnas de cada vista:
/// conocer el nombre exacto de la columna en PostgreSQL.
///
/// Asi una consulta nunca escribe un nombre de columna como texto suelto: si
/// la columna no existe en el enum, no compila.
library;

abstract interface class ColumnaVista {
  String get nombrePostgresql;
}
