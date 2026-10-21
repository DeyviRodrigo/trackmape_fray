/// Responsabilidad: Convertir los comandos de posiciones en el mapa que recibe la
/// base, con los nombres de columna y el formato de cada tipo.
library;

import 'package:trackmape_sup/datos2/contratos/tablas/serializador_insercion_contrato.dart';
import 'package:trackmape_sup/datos2/tablas/posiciones/posiciones_comandos.dart';

// POSICIONES SERIALIZADOR - De comandos a columnas de la base
class PosicionesSerializador
    implements SerializadorInsercionContrato<PosicionesInsertar> {
  const PosicionesSerializador();

  // INSERTAR - Columnas obligatorias siempre; con valor por defecto, si estan
  @override
  Map<String, dynamic> aJsonInsertar(PosicionesInsertar entrada) {
    final resultado = <String, dynamic>{};
    resultado['tiempo'] = entrada.tiempo?.toIso8601String();
    resultado['fk_receptor'] = entrada.fkReceptor;
    resultado['fk_emisor'] = entrada.fkEmisor;
    resultado['epoca_rx'] = entrada.epocaRx;
    resultado['lat_grados'] = entrada.latGrados;
    resultado['lon_grados'] = entrada.lonGrados;
    resultado['alt_msnm_m'] = entrada.altMsnmM;
    resultado['hae_m'] = entrada.haeM;
    resultado['geo_m'] = entrada.geoM;
    resultado['pdop'] = entrada.pdop;
    resultado['hdop'] = entrada.hdop;
    resultado['vdop'] = entrada.vdop;
    resultado['largo_payload'] = entrada.largoPayload;
    if (entrada.idPosicion.presente) {
      resultado['id_posicion'] = entrada.idPosicion.valor;
    }
    return resultado;
  }
}
