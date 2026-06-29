import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/niveles_ubigeo/niveles_ubigeo_modelo.dart';

class NivelesUbigeoSerializador
    implements SerializadorContrato<NivelesUbigeoModelo> {
  @override
  Map<String, dynamic> aJson(NivelesUbigeoModelo modelo) {
    return {
      if (modelo.id_nivel_ubigeo.isNotEmpty)
        'id_nivel_ubigeo': modelo.id_nivel_ubigeo,
      'fk_pais': modelo.fk_pais,
      'nombre_nivel': modelo.nombre_nivel,
      'nivel': modelo.nivel,
      'activo': modelo.activo,
    };
  }
}
