/// Responsabilidad: Representar un fallo normalizado de repositorio conservando
/// evidencia tecnica estructurada y un mensaje funcional seguro.
library;

import 'package:trackmape_sup/datos2/errores/error_datos_tipo.dart';

// REPOSITORIO EXCEPTION - Unico fallo que sale de un repositorio
final class RepositorioException implements Exception {
  const RepositorioException(
    this.mensaje, {
    required this.tipo,
    required this.causa,
    required this.rastreo,
    this.codigo,
    this.detalles,
    this.sugerencia,
  });

  final String mensaje;
  final ErrorDatosTipo tipo;
  final String? codigo;
  final String? detalles;
  final String? sugerencia;
  final Object causa;
  final StackTrace rastreo;

  @override
  String toString() =>
      'RepositorioException(tipo: $tipo, codigo: $codigo, mensaje: $mensaje)';
}
