// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class DocumentosIdentidadModelo implements ModeloContrato {
  final String id_doc;
  final String codigo;
  final String nombre_documento;
  final String? fk_pais_aplicacion;
  final bool activo;
  final String categoria_doc_id;
  final int orden_doc_id;

  const DocumentosIdentidadModelo({
    required this.id_doc,
    required this.codigo,
    required this.nombre_documento,
    this.fk_pais_aplicacion,
    required this.activo,
    required this.categoria_doc_id,
    required this.orden_doc_id,
  });

  @override
  DocumentosIdentidadModelo copyWith({
    String? id_doc,
    String? codigo,
    String? nombre_documento,
    String? fk_pais_aplicacion,
    bool? activo,
    String? categoria_doc_id,
    int? orden_doc_id,
  }) {
    return DocumentosIdentidadModelo(
      id_doc: id_doc ?? this.id_doc,
      codigo: codigo ?? this.codigo,
      nombre_documento: nombre_documento ?? this.nombre_documento,
      fk_pais_aplicacion: fk_pais_aplicacion ?? this.fk_pais_aplicacion,
      activo: activo ?? this.activo,
      categoria_doc_id: categoria_doc_id ?? this.categoria_doc_id,
      orden_doc_id: orden_doc_id ?? this.orden_doc_id,
    );
  }
}
