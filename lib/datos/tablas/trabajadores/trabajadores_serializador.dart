import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/trabajadores/trabajadores_modelo.dart';

class TrabajadoresSerializador
    implements SerializadorContrato<TrabajadoresModelo> {
  @override
  Map<String, dynamic> aJson(TrabajadoresModelo modelo) {
    return {
      if (modelo.id_trabajador.isNotEmpty)
        'id_trabajador': modelo.id_trabajador,
      'fk_persona': modelo.fk_persona,
      'fk_sede': modelo.fk_sede,
      'celular': modelo.celular,
      'email': modelo.email,
      'fk_contacto_emergencia': modelo.fk_contacto_emergencia,
      'fk_referido': modelo.fk_referido,
      'observaciones': modelo.observaciones,
      'fotografia_url': modelo.fotografia_url,
      'columnas_extras': modelo.columnas_extras,
      'fk_ubigeo': modelo.fk_ubigeo,
      'direccion': modelo.direccion,
      'fk_empresa': modelo.fk_empresa,
      'activo': modelo.activo,
    };
  }
}
