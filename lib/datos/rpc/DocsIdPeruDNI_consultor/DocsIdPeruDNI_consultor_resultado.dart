// ignore_for_file: file_names, non_constant_identifier_names

class DocsIdPeruDNIConsultorResultado {
  final String id_persona;
  final String id_persona_doc;
  final String dni;
  final String? nombres;
  final String? apellido_paterno;
  final String? apellido_materno;
  final DateTime? ultima_verificacion_ok;

  const DocsIdPeruDNIConsultorResultado({
    required this.id_persona,
    required this.id_persona_doc,
    required this.dni,
    this.nombres,
    this.apellido_paterno,
    this.apellido_materno,
    this.ultima_verificacion_ok,
  });
}
