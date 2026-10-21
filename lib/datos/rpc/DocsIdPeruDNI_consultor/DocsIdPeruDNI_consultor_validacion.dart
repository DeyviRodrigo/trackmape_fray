// ignore_for_file: file_names

import 'package:trackmape_sup/recursos/errores/repositorio_exception.dart';

class DocsIdPeruDNIConsultorValidacion {
  void validar(Map<String, dynamic> json) {
    if (json['ok'] != true) {
      final mensaje =
          json['error']?.toString() ??
          'Error desconocido en DocsIdPeruDNI_consultor';
      throw RepositorioException(
        mensaje,
        causa: mensaje,
        rastreo: StackTrace.current,
      );
    }
  }
}
