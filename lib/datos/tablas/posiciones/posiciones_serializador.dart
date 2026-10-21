import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/posiciones/posiciones_modelo.dart';

class PosicionesSerializador implements SerializadorContrato<PosicionesModelo> {
  @override
  Map<String, dynamic> aJson(PosicionesModelo modelo) {
    return {
      if (modelo.id_posicion.isNotEmpty) 'id_posicion': modelo.id_posicion,
      'tiempo': modelo.tiempo?.toIso8601String(),
      'fk_receptor': modelo.fk_receptor,
      'fk_emisor': modelo.fk_emisor,
      'epoca_rx': modelo.epoca_rx,
      'lat_grados': modelo.lat_grados,
      'lon_grados': modelo.lon_grados,
      'alt_msnm_m': modelo.alt_msnm_m,
      'hae_m': modelo.hae_m,
      'geo_m': modelo.geo_m,
      'pdop': modelo.pdop,
      'hdop': modelo.hdop,
      'vdop': modelo.vdop,
      'largo_payload': modelo.largo_payload,
    };
  }
}
