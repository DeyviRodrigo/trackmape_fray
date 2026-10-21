/// Excepcion lanzada por la capa de repositorio.
///
/// Preserva el contexto funcional (que operacion fallo),
/// la causa original (tipo de error de infraestructura)
/// y el stack trace real para diagnostico.
class RepositorioException implements Exception {
  const RepositorioException(
    this.mensaje, {
    required this.causa,
    required this.rastreo,
  });

  final String mensaje;
  final Object causa;
  final StackTrace rastreo;

  @override
  String toString() => 'RepositorioException: $mensaje\nCausa: $causa';
}
