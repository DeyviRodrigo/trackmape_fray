// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class DocumentoEmpresaFormatoModelo implements ModeloContrato {
  final String id_doc_empresa;
  final String fk_pais;
  final String codigo;
  final String nombre;
  final String regex_validacion;
  final String? ejemplo;
  final String? mensaje_error;
  final bool activo;

  const DocumentoEmpresaFormatoModelo({
    required this.id_doc_empresa,
    required this.fk_pais,
    required this.codigo,
    required this.nombre,
    required this.regex_validacion,
    this.ejemplo,
    this.mensaje_error,
    required this.activo,
  });

  @override
  DocumentoEmpresaFormatoModelo copyWith({
    String? id_doc_empresa,
    String? fk_pais,
    String? codigo,
    String? nombre,
    String? regex_validacion,
    String? ejemplo,
    String? mensaje_error,
    bool? activo,
  }) {
    return DocumentoEmpresaFormatoModelo(
      id_doc_empresa: id_doc_empresa ?? this.id_doc_empresa,
      fk_pais: fk_pais ?? this.fk_pais,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      regex_validacion: regex_validacion ?? this.regex_validacion,
      ejemplo: ejemplo ?? this.ejemplo,
      mensaje_error: mensaje_error ?? this.mensaje_error,
      activo: activo ?? this.activo,
    );
  }
}
