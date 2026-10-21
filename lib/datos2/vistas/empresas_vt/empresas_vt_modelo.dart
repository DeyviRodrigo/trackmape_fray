/// Responsabilidad: Representar una fila de la vista empresas_vt (empresas).
library;

// EMPRESAS VT MODELO - Una fila de la vista, con sus tipos de Dart
class EmpresasVtModelo {
  const EmpresasVtModelo({
    required this.idEmpresa,
    required this.fkPais,
    required this.fkTipoDoc,
    required this.numeroDocumento,
    required this.razonSocial,
    this.nombreComercial,
    this.estado,
    this.condicion,
    this.fkUbigeo,
    this.direccion,
    this.columnasExtras,
    this.fkResponsable,
    this.celular,
    this.email,
    this.paginaWeb,
    this.logoUrl,
    this.activo,
  });

  final String idEmpresa;
  final String fkPais;
  final String fkTipoDoc;
  final String numeroDocumento;
  final String razonSocial;
  final String? nombreComercial;
  final String? estado;
  final String? condicion;
  final String? fkUbigeo;
  final String? direccion;
  final Map<String, dynamic>? columnasExtras;
  final String? fkResponsable;
  final String? celular;
  final String? email;
  final String? paginaWeb;
  final String? logoUrl;
  final bool? activo;
}
