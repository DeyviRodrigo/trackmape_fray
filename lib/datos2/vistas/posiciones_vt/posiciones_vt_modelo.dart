/// Responsabilidad: Representar una fila de la vista posiciones_vt (posiciones GPS (historial)).
library;

// POSICIONES VT MODELO - Una fila de la vista, con sus tipos de Dart
class PosicionesVtModelo {
  const PosicionesVtModelo({
    required this.idPosicion,
    this.tiempo,
    this.fkReceptor,
    this.fkEmisor,
    this.epocaRx,
    this.latGrados,
    this.lonGrados,
    this.altMsnmM,
    this.haeM,
    this.geoM,
    this.pdop,
    this.hdop,
    this.vdop,
    this.largoPayload,
  });

  final String idPosicion;
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
}
