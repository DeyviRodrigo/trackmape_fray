import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/empresas/empresas_modelo.dart';

class EmpresasSerializador implements SerializadorContrato<EmpresasModelo> {
  @override
  Map<String, dynamic> aJson(EmpresasModelo modelo) {
    return {
      if (modelo.id_empresa.isNotEmpty) 'id_empresa': modelo.id_empresa,
      'fk_pais': modelo.fk_pais,
      'fk_tipo_doc': modelo.fk_tipo_doc,
      'numero_documento': modelo.numero_documento,
      'razon_social': modelo.razon_social,
      'nombre_comercial': modelo.nombre_comercial,
      'estado': modelo.estado,
      'condicion': modelo.condicion,
      'fk_ubigeo': modelo.fk_ubigeo,
      'direccion': modelo.direccion,
      'columnas_extras': modelo.columnas_extras,
      'fk_responsable': modelo.fk_responsable,
      'celular': modelo.celular,
      'email': modelo.email,
      'pagina_web': modelo.pagina_web,
      'logo_url': modelo.logo_url,
      if (modelo.activo != null) 'activo': modelo.activo,
    };
  }
}
