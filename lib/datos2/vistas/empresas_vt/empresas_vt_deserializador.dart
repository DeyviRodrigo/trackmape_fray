/// Responsabilidad: Convertir una fila de empresas_vt, tal como responde la base,
/// en EmpresasVtModelo.
library;

import 'package:trackmape_sup/datos2/contratos/general/deserializador_contrato.dart';
import 'package:trackmape_sup/datos2/vistas/empresas_vt/empresas_vt_modelo.dart';

// EMPRESAS VT DESERIALIZADOR - De columnas de la base a campos del modelo
class EmpresasVtDeserializador
    implements DeserializadorContrato<EmpresasVtModelo> {
  const EmpresasVtDeserializador();

  @override
  EmpresasVtModelo desdeJson(Map<String, dynamic> json) {
    return EmpresasVtModelo(
      idEmpresa: json['id_empresa'] as String,
      fkPais: json['fk_pais'] as String,
      fkTipoDoc: json['fk_tipo_doc'] as String,
      numeroDocumento: json['numero_documento'] as String,
      razonSocial: json['razon_social'] as String,
      nombreComercial: json['nombre_comercial'] as String?,
      estado: json['estado'] as String?,
      condicion: json['condicion'] as String?,
      fkUbigeo: json['fk_ubigeo'] as String?,
      direccion: json['direccion'] as String?,
      columnasExtras: json['columnas_extras'] as Map<String, dynamic>?,
      fkResponsable: json['fk_responsable'] as String?,
      celular: json['celular'] as String?,
      email: json['email'] as String?,
      paginaWeb: json['pagina_web'] as String?,
      logoUrl: json['logo_url'] as String?,
      activo: json['activo'] as bool?,
    );
  }
}
