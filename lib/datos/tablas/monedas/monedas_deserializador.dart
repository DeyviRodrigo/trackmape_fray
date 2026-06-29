import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/monedas/monedas_modelo.dart';

class MonedasDeserializador implements DeserializadorContrato<MonedasModelo> {
  @override
  MonedasModelo desdeJson(Map<String, dynamic> json) {
    return MonedasModelo(
      id_moneda: json['id_moneda'] as String,
      codigo: json['codigo'] as String,
      nombre_moneda: json['nombre_moneda'] as String,
      simbolo: json['simbolo'] as String?,
      decimales: json['decimales'] as int,
      activo: json['activo'] as bool,
      fk_pais_emisor: json['fk_pais_emisor'] as String?,
    );
  }
}
