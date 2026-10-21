import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/sedes/sedes_modelo.dart';

class SedesSerializador implements SerializadorContrato<SedesModelo> {
  @override
  Map<String, dynamic> aJson(SedesModelo modelo) {
    return {
      if (modelo.id_sede.isNotEmpty) 'id_sede': modelo.id_sede,
      'fk_empresa': modelo.fk_empresa,
      'nombre': modelo.nombre,
      'tipo_sede': modelo.tipo_sede,
      'fk_responsable': modelo.fk_responsable,
      'celular': modelo.celular,
      'email': modelo.email,
      'pagina_web': modelo.pagina_web,
      'logo_url': modelo.logo_url,
      'fk_ubigeo': modelo.fk_ubigeo,
      'direccion': modelo.direccion,
      'columnas_extras': modelo.columnas_extras,
      'activo': modelo.activo,
      'zona_horaria': modelo.zona_horaria,
    };
  }
}
