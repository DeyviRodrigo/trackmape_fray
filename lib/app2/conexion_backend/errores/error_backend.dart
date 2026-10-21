/// Responsabilidad: Representar un fallo del backend ya clasificado.
///
/// Es lo unico que sale de un mensajero cuando una operacion falla: quien lo
/// recibe no conoce los errores propios de Supabase ni de ningun otro backend.
library;

import 'package:trackmape_sup/app2/conexion_backend/errores/error_backend_tipo.dart';

// ERROR BACKEND - Fallo clasificado con su evidencia tecnica
final class ErrorBackend implements Exception {
  const ErrorBackend(
    this.mensaje, {
    required this.tipo,
    required this.causa,
    required this.rastreo,
    this.codigo,
    this.detalles,
    this.sugerencia,
  });

  final String mensaje;
  final ErrorBackendTipo tipo;

  // Codigo original del backend, si lo informa
  final String? codigo;
  final String? detalles;
  final String? sugerencia;

  // Error original y su rastreo, para diagnostico
  final Object causa;
  final StackTrace rastreo;

  @override
  String toString() =>
      'ErrorBackend(tipo: $tipo, codigo: $codigo, mensaje: $mensaje)';
}
