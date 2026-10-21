/// Responsabilidad: Representar una fila de la vista pr_elementos_operativos_vt (elementos operativos GIS).
library;

// PR ELEMENTOS OPERATIVOS VT MODELO - Una fila de la vista, con sus tipos de Dart
class PrElementosOperativosVtModelo {
  const PrElementosOperativosVtModelo({
    required this.idElemento,
    required this.fkEmpresa,
    required this.categoria,
    required this.tipoOperativo,
    required this.nombre,
    required this.geojson,
    required this.color,
    required this.prioridad,
    required this.activo,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    this.empresa,
    this.fkSede,
    this.sede,
    this.descripcion,
  });

  final String idElemento;
  final String fkEmpresa;
  final String? empresa;
  final String? fkSede;
  final String? sede;
  final String categoria;
  final String tipoOperativo;
  final String nombre;
  final String? descripcion;
  final Map<String, dynamic> geojson;
  final String color;
  final int prioridad;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;
}
