/// Responsabilidad: Representar una fila de la vista sedes_vt (sedes).
library;

// SEDES VT MODELO - Una fila de la vista, con sus tipos de Dart
class SedesVtModelo {
  const SedesVtModelo({
    required this.idSede,
    required this.fkEmpresa,
    required this.nombre,
    this.empresa,
    this.tipoSede,
    this.fkResponsable,
    this.celular,
    this.email,
    this.paginaWeb,
    this.logoUrl,
    this.fkUbigeo,
    this.direccion,
    this.columnasExtras,
    this.activo,
    this.zonaHoraria,
  });

  final String idSede;
  final String fkEmpresa;
  final String? empresa;
  final String nombre;
  final String? tipoSede;
  final String? fkResponsable;
  final String? celular;
  final String? email;
  final String? paginaWeb;
  final String? logoUrl;
  final String? fkUbigeo;
  final String? direccion;
  final Map<String, dynamic>? columnasExtras;
  final bool? activo;
  final String? zonaHoraria;
}
