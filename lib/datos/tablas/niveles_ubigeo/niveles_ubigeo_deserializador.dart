import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/niveles_ubigeo/niveles_ubigeo_modelo.dart';

class NivelesUbigeoDeserializador
    implements DeserializadorContrato<NivelesUbigeoModelo> {
  @override
  NivelesUbigeoModelo desdeJson(Map<String, dynamic> json) {
    return NivelesUbigeoModelo(
      id_nivel_ubigeo: json['id_nivel_ubigeo'] as String,
      fk_pais: json['fk_pais'] as String?,
      nombre_nivel: json['nombre_nivel'] as String,
      nivel: json['nivel'] as int,
      activo: json['activo'] as bool,
    );
  }
}
