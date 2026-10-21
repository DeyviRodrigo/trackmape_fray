import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/ubigeo/ubigeo_modelo.dart';

class UbigeoSerializador implements SerializadorContrato<UbigeoModelo> {
  @override
  Map<String, dynamic> aJson(UbigeoModelo modelo) {
    return {
      if (modelo.id_ubigeo.isNotEmpty) 'id_ubigeo': modelo.id_ubigeo,
      'fk_pais': modelo.fk_pais,
      'fk_nivel': modelo.fk_nivel,
      'fk_padre': modelo.fk_padre,
      'nombre': modelo.nombre,
      'codigo': modelo.codigo,
      'codigos_adicionales': modelo.codigos_adicionales,
      'activo': modelo.activo,
    };
  }
}
