/// Responsabilidad: Declarar los datos de cada escritura sobre pr_elementos_operativos
/// (elementos operativos GIS).
///
/// Es espejo de la tabla. Al insertar, las columnas sin valor por defecto son
/// obligatorias (las anulables se pasan explicitamente, aunque sea nulo) y las
/// que tienen valor por defecto son CampoEscritura: ausentes, la base pone el
/// suyo.
library;

import 'package:trackmape_sup/datos2/contratos/tablas/campo_escritura.dart';

// PR ELEMENTOS OPERATIVOS INSERTAR - Datos de una fila nueva
class PrElementosOperativosInsertar {
  const PrElementosOperativosInsertar({
    required this.fkEmpresa,
    required this.fkSede,
    required this.categoria,
    required this.tipoOperativo,
    required this.nombre,
    required this.descripcion,
    required this.geojson,
    this.idElemento = const CampoEscritura.ausente(),
    this.color = const CampoEscritura.ausente(),
    this.prioridad = const CampoEscritura.ausente(),
    this.activo = const CampoEscritura.ausente(),
    this.fechaCreacion = const CampoEscritura.ausente(),
    this.fechaActualizacion = const CampoEscritura.ausente(),
  });

  final String fkEmpresa;
  final String? fkSede;
  final String categoria;
  final String tipoOperativo;
  final String nombre;
  final String? descripcion;
  final Map<String, dynamic> geojson;
  final CampoEscritura<String> idElemento;
  final CampoEscritura<String> color;
  final CampoEscritura<int> prioridad;
  final CampoEscritura<bool> activo;
  final CampoEscritura<DateTime> fechaCreacion;
  final CampoEscritura<DateTime> fechaActualizacion;
}

// PR ELEMENTOS OPERATIVOS ACTUALIZAR - Solo las columnas que cambian.
// La clave no se actualiza y activo se cambia con desactivar o activar.
class PrElementosOperativosActualizar {
  const PrElementosOperativosActualizar({
    this.fkEmpresa = const CampoEscritura.ausente(),
    this.fkSede = const CampoEscritura.ausente(),
    this.categoria = const CampoEscritura.ausente(),
    this.tipoOperativo = const CampoEscritura.ausente(),
    this.nombre = const CampoEscritura.ausente(),
    this.descripcion = const CampoEscritura.ausente(),
    this.geojson = const CampoEscritura.ausente(),
    this.color = const CampoEscritura.ausente(),
    this.prioridad = const CampoEscritura.ausente(),
    this.fechaCreacion = const CampoEscritura.ausente(),
    this.fechaActualizacion = const CampoEscritura.ausente(),
  });

  final CampoEscritura<String> fkEmpresa;
  final CampoEscritura<String?> fkSede;
  final CampoEscritura<String> categoria;
  final CampoEscritura<String> tipoOperativo;
  final CampoEscritura<String> nombre;
  final CampoEscritura<String?> descripcion;
  final CampoEscritura<Map<String, dynamic>> geojson;
  final CampoEscritura<String> color;
  final CampoEscritura<int> prioridad;
  final CampoEscritura<DateTime> fechaCreacion;
  final CampoEscritura<DateTime> fechaActualizacion;
}
