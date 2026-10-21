/// Responsabilidad: Declarar los datos de cada escritura sobre equipos_control
/// (equipos de control).
///
/// Es espejo de la tabla. Al insertar, las columnas sin valor por defecto son
/// obligatorias (las anulables se pasan explicitamente, aunque sea nulo) y las
/// que tienen valor por defecto son CampoEscritura: ausentes, la base pone el
/// suyo.
library;

import 'package:trackmape_sup/datos2/contratos/tablas/campo_escritura.dart';

// EQUIPOS CONTROL INSERTAR - Datos de una fila nueva
class EquiposControlInsertar {
  const EquiposControlInsertar({
    required this.fkEmpresa,
    required this.fkSede,
    required this.nombre,
    required this.ubicacion,
    required this.idEquipoFabrica,
    required this.tipoEquipoControl,
    required this.codigoEquipoControl,
    required this.direccionMac,
    required this.observaciones,
    required this.fkAreaAsociada,
    required this.fkEquipoAsociado,
    required this.fechaInicio,
    required this.fechaFinal,
    this.idEquipoControl = const CampoEscritura.ausente(),
  });

  final String fkEmpresa;
  final String? fkSede;
  final String? nombre;
  final String? ubicacion;
  final String? idEquipoFabrica;
  final String? tipoEquipoControl;
  final String? codigoEquipoControl;
  final String? direccionMac;
  final String? observaciones;
  final String? fkAreaAsociada;
  final String? fkEquipoAsociado;
  final DateTime? fechaInicio;
  final DateTime? fechaFinal;
  final CampoEscritura<String> idEquipoControl;
}

// EQUIPOS CONTROL ACTUALIZAR - Solo las columnas que cambian.
// La clave no se actualiza y activo se cambia con desactivar o activar.
class EquiposControlActualizar {
  const EquiposControlActualizar({
    this.fkEmpresa = const CampoEscritura.ausente(),
    this.fkSede = const CampoEscritura.ausente(),
    this.nombre = const CampoEscritura.ausente(),
    this.ubicacion = const CampoEscritura.ausente(),
    this.idEquipoFabrica = const CampoEscritura.ausente(),
    this.tipoEquipoControl = const CampoEscritura.ausente(),
    this.codigoEquipoControl = const CampoEscritura.ausente(),
    this.direccionMac = const CampoEscritura.ausente(),
    this.observaciones = const CampoEscritura.ausente(),
    this.fkAreaAsociada = const CampoEscritura.ausente(),
    this.fkEquipoAsociado = const CampoEscritura.ausente(),
    this.fechaInicio = const CampoEscritura.ausente(),
    this.fechaFinal = const CampoEscritura.ausente(),
  });

  final CampoEscritura<String> fkEmpresa;
  final CampoEscritura<String?> fkSede;
  final CampoEscritura<String?> nombre;
  final CampoEscritura<String?> ubicacion;
  final CampoEscritura<String?> idEquipoFabrica;
  final CampoEscritura<String?> tipoEquipoControl;
  final CampoEscritura<String?> codigoEquipoControl;
  final CampoEscritura<String?> direccionMac;
  final CampoEscritura<String?> observaciones;
  final CampoEscritura<String?> fkAreaAsociada;
  final CampoEscritura<String?> fkEquipoAsociado;
  final CampoEscritura<DateTime?> fechaInicio;
  final CampoEscritura<DateTime?> fechaFinal;
}
