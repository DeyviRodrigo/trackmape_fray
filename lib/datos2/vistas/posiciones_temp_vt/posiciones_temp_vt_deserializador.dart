/// Responsabilidad: Convertir una fila de posiciones_temp_vt, tal como responde la base,
/// en PosicionesTempVtModelo.
library;

import 'package:trackmape_sup/datos2/contratos/general/deserializador_contrato.dart';
import 'package:trackmape_sup/datos2/vistas/posiciones_temp_vt/posiciones_temp_vt_modelo.dart';

// POSICIONES TEMP VT DESERIALIZADOR - De columnas de la base a campos del modelo
class PosicionesTempVtDeserializador
    implements DeserializadorContrato<PosicionesTempVtModelo> {
  const PosicionesTempVtDeserializador();

  @override
  PosicionesTempVtModelo desdeJson(Map<String, dynamic> json) {
    return PosicionesTempVtModelo(
      idPosicion: json['id_posicion'] as String,
      tiempo: json['tiempo'] == null
          ? null
          : DateTime.parse(json['tiempo'] as String),
      fkReceptor: json['fk_receptor'] as String?,
      fkEmisor: json['fk_emisor'] as String?,
      epocaRx: (json['epoca_rx'] as num?)?.toInt(),
      latGrados: (json['lat_grados'] as num?)?.toDouble(),
      lonGrados: (json['lon_grados'] as num?)?.toDouble(),
      altMsnmM: (json['alt_msnm_m'] as num?)?.toInt(),
      haeM: (json['hae_m'] as num?)?.toInt(),
      geoM: (json['geo_m'] as num?)?.toInt(),
      pdop: (json['pdop'] as num?)?.toDouble(),
      hdop: (json['hdop'] as num?)?.toDouble(),
      vdop: (json['vdop'] as num?)?.toDouble(),
      largoPayload: (json['largo_payload'] as num?)?.toInt(),
    );
  }
}
