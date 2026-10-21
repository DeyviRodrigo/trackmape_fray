/// Responsabilidad: Declarar los datos de cada escritura sobre posiciones
/// (posiciones GPS).
///
/// Es espejo de la tabla. Al insertar, las columnas sin valor por defecto son
/// obligatorias (las anulables se pasan explicitamente, aunque sea nulo) y las
/// que tienen valor por defecto son CampoEscritura: ausentes, la base pone el
/// suyo.
library;

import 'package:trackmape_sup/datos2/contratos/tablas/campo_escritura.dart';

// POSICIONES INSERTAR - Datos de una fila nueva
class PosicionesInsertar {
  const PosicionesInsertar({
    required this.tiempo,
    required this.fkReceptor,
    required this.fkEmisor,
    required this.epocaRx,
    required this.latGrados,
    required this.lonGrados,
    required this.altMsnmM,
    required this.haeM,
    required this.geoM,
    required this.pdop,
    required this.hdop,
    required this.vdop,
    required this.largoPayload,
    this.idPosicion = const CampoEscritura.ausente(),
  });

  final DateTime? tiempo;
  final String? fkReceptor;
  final String? fkEmisor;
  final int? epocaRx;
  final double? latGrados;
  final double? lonGrados;
  final int? altMsnmM;
  final int? haeM;
  final int? geoM;
  final double? pdop;
  final double? hdop;
  final double? vdop;
  final int? largoPayload;
  final CampoEscritura<String> idPosicion;
}
