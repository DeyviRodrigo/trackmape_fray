// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class DocumentosIdentidadFormatosModelo implements ModeloContrato {
  final String id_formato_doc;
  final String fk_doc;
  final String nombre_formato;
  final String regex_validacion;
  final String? ejemplo;
  final String mensaje_error;
  final bool activo;
  final int orden;

  const DocumentosIdentidadFormatosModelo({
    required this.id_formato_doc,
    required this.fk_doc,
    required this.nombre_formato,
    required this.regex_validacion,
    this.ejemplo,
    required this.mensaje_error,
    required this.activo,
    required this.orden,
  });

  @override
  DocumentosIdentidadFormatosModelo copyWith({
    String? id_formato_doc,
    String? fk_doc,
    String? nombre_formato,
    String? regex_validacion,
    String? ejemplo,
    String? mensaje_error,
    bool? activo,
    int? orden,
  }) {
    return DocumentosIdentidadFormatosModelo(
      id_formato_doc: id_formato_doc ?? this.id_formato_doc,
      fk_doc: fk_doc ?? this.fk_doc,
      nombre_formato: nombre_formato ?? this.nombre_formato,
      regex_validacion: regex_validacion ?? this.regex_validacion,
      ejemplo: ejemplo ?? this.ejemplo,
      mensaje_error: mensaje_error ?? this.mensaje_error,
      activo: activo ?? this.activo,
      orden: orden ?? this.orden,
    );
  }
}
