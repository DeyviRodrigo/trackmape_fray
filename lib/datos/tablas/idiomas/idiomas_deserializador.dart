import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/idiomas/idiomas_modelo.dart';

class IdiomasDeserializador implements DeserializadorContrato<IdiomasModelo> {
  @override
  IdiomasModelo desdeJson(Map<String, dynamic> json) {
    return IdiomasModelo(
      codigo: json['codigo'] as String,
      nombre_idioma: json['nombre_idioma'] as String,
      activo: json['activo'] as bool,
    );
  }
}
