import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/empresas/empresas_modelo.dart';

class EmpresasDeserializador implements DeserializadorContrato<EmpresasModelo> {
  @override
  EmpresasModelo desdeJson(Map<String, dynamic> json) {
    return EmpresasModelo(
      id_empresa: json['id_empresa'] as String,
      fk_pais: json['fk_pais'] as String,
      fk_tipo_doc: json['fk_tipo_doc'] as String,
      numero_documento: json['numero_documento'] as String,
      razon_social: json['razon_social'] as String,
      nombre_comercial: json['nombre_comercial'] as String?,
      estado: json['estado'] as String?,
      condicion: json['condicion'] as String?,
      fk_ubigeo: json['fk_ubigeo'] as String?,
      direccion: json['direccion'] as String?,
      columnas_extras: json['columnas_extras'] as Map<String, dynamic>?,
      fk_responsable: json['fk_responsable'] as String?,
      celular: json['celular'] as String?,
      email: json['email'] as String?,
      pagina_web: json['pagina_web'] as String?,
      logo_url: json['logo_url'] as String?,
      activo: json['activo'] as bool?,
    );
  }
}
