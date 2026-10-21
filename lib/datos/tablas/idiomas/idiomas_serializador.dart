import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/idiomas/idiomas_modelo.dart';

class IdiomasSerializador implements SerializadorContrato<IdiomasModelo> {
  @override
  Map<String, dynamic> aJson(IdiomasModelo modelo) {
    return {
      'codigo': modelo.codigo,
      'nombre_idioma': modelo.nombre_idioma,
      'activo': modelo.activo,
    };
  }
}
