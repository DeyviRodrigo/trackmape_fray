import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/paises/paises_modelo.dart';

class PaisesDeserializador implements DeserializadorContrato<PaisesModelo> {
  @override
  PaisesModelo desdeJson(Map<String, dynamic> json) {
    return PaisesModelo(
      id_pais: json['id_pais'] as String,
      iso2: json['iso2'] as String,
      iso3: json['iso3'] as String,
      nombre_pais: json['nombre_pais'] as String,
      prefijo_tel: json['prefijo_tel'] as String?,
      fk_moneda_pred: json['fk_moneda_pred'] as String?,
      activo: json['activo'] as bool,
      fk_idioma_pred: json['fk_idioma_pred'] as String?,
    );
  }
}
