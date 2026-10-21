import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/ubigeo/ubigeo_modelo.dart';

class UbigeoDeserializador implements DeserializadorContrato<UbigeoModelo> {
  @override
  UbigeoModelo desdeJson(Map<String, dynamic> json) {
    return UbigeoModelo(
      id_ubigeo: json['id_ubigeo'] as String,
      fk_pais: json['fk_pais'] as String?,
      fk_nivel: json['fk_nivel'] as String?,
      fk_padre: json['fk_padre'] as String?,
      nombre: json['nombre'] as String?,
      codigo: json['codigo'] as int?,
      codigos_adicionales: json['codigos_adicionales'] as Map<String, dynamic>?,
      activo: json['activo'] as bool?,
    );
  }
}
