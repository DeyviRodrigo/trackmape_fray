import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/posiciones/posiciones_modelo.dart';
import 'package:trackmape_sup/recursos/utilidades/utilidades_json.dart';

class PosicionesDeserializador
    implements DeserializadorContrato<PosicionesModelo> {
  @override
  PosicionesModelo desdeJson(Map<String, dynamic> json) {
    return PosicionesModelo(
      id_posicion: json['id_posicion'] as String,
      tiempo: aDateTimeNulable(json['tiempo']),
      fk_receptor: json['fk_receptor'] as String?,
      fk_emisor: json['fk_emisor'] as String?,
      epoca_rx: aIntNulable(json['epoca_rx']),
      lat_grados: aDoubleNulable(json['lat_grados']),
      lon_grados: aDoubleNulable(json['lon_grados']),
      alt_msnm_m: aIntNulable(json['alt_msnm_m']),
      hae_m: aIntNulable(json['hae_m']),
      geo_m: aIntNulable(json['geo_m']),
      pdop: aDoubleNulable(json['pdop']),
      hdop: aDoubleNulable(json['hdop']),
      vdop: aDoubleNulable(json['vdop']),
      largo_payload: aIntNulable(json['largo_payload']),
    );
  }
}
