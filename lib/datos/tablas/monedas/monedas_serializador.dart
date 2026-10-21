import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/monedas/monedas_modelo.dart';

class MonedasSerializador implements SerializadorContrato<MonedasModelo> {
  @override
  Map<String, dynamic> aJson(MonedasModelo modelo) {
    return {
      if (modelo.id_moneda.isNotEmpty) 'id_moneda': modelo.id_moneda,
      'codigo': modelo.codigo,
      'nombre_moneda': modelo.nombre_moneda,
      'simbolo': modelo.simbolo,
      'decimales': modelo.decimales,
      'activo': modelo.activo,
      'fk_pais_emisor': modelo.fk_pais_emisor,
    };
  }
}
