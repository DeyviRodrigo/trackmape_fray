// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class PosicionesTempModelo implements ModeloContrato {
  final String id_posicion;
  final DateTime? tiempo;
  final String? fk_receptor;
  final String? fk_emisor;
  final int? epoca_rx;
  final double? lat_grados;
  final double? lon_grados;
  final int? alt_msnm_m;
  final int? hae_m;
  final int? geo_m;
  final double? pdop;
  final double? hdop;
  final double? vdop;
  final int? largo_payload;

  const PosicionesTempModelo({
    required this.id_posicion,
    this.tiempo,
    this.fk_receptor,
    this.fk_emisor,
    this.epoca_rx,
    this.lat_grados,
    this.lon_grados,
    this.alt_msnm_m,
    this.hae_m,
    this.geo_m,
    this.pdop,
    this.hdop,
    this.vdop,
    this.largo_payload,
  });

  @override
  PosicionesTempModelo copyWith({
    String? id_posicion,
    DateTime? tiempo,
    String? fk_receptor,
    String? fk_emisor,
    int? epoca_rx,
    double? lat_grados,
    double? lon_grados,
    int? alt_msnm_m,
    int? hae_m,
    int? geo_m,
    double? pdop,
    double? hdop,
    double? vdop,
    int? largo_payload,
  }) {
    return PosicionesTempModelo(
      id_posicion: id_posicion ?? this.id_posicion,
      tiempo: tiempo ?? this.tiempo,
      fk_receptor: fk_receptor ?? this.fk_receptor,
      fk_emisor: fk_emisor ?? this.fk_emisor,
      epoca_rx: epoca_rx ?? this.epoca_rx,
      lat_grados: lat_grados ?? this.lat_grados,
      lon_grados: lon_grados ?? this.lon_grados,
      alt_msnm_m: alt_msnm_m ?? this.alt_msnm_m,
      hae_m: hae_m ?? this.hae_m,
      geo_m: geo_m ?? this.geo_m,
      pdop: pdop ?? this.pdop,
      hdop: hdop ?? this.hdop,
      vdop: vdop ?? this.vdop,
      largo_payload: largo_payload ?? this.largo_payload,
    );
  }
}
