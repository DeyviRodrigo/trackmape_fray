import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/paises/paises_modelo.dart';

class PaisesSerializador implements SerializadorContrato<PaisesModelo> {
  @override
  Map<String, dynamic> aJson(PaisesModelo modelo) {
    return {
      if (modelo.id_pais.isNotEmpty) 'id_pais': modelo.id_pais,
      'iso2': modelo.iso2,
      'iso3': modelo.iso3,
      'nombre_pais': modelo.nombre_pais,
      'prefijo_tel': modelo.prefijo_tel,
      'fk_moneda_pred': modelo.fk_moneda_pred,
      'activo': modelo.activo,
      'fk_idioma_pred': modelo.fk_idioma_pred,
    };
  }
}
