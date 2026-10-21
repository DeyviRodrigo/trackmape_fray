/// Responsabilidad: Convertir una fila de sedes_vt, tal como responde la base,
/// en SedesVtModelo.
library;

import 'package:trackmape_sup/datos2/contratos/general/deserializador_contrato.dart';
import 'package:trackmape_sup/datos2/vistas/sedes_vt/sedes_vt_modelo.dart';

// SEDES VT DESERIALIZADOR - De columnas de la base a campos del modelo
class SedesVtDeserializador implements DeserializadorContrato<SedesVtModelo> {
  const SedesVtDeserializador();

  @override
  SedesVtModelo desdeJson(Map<String, dynamic> json) {
    return SedesVtModelo(
      idSede: json['id_sede'] as String,
      fkEmpresa: json['fk_empresa'] as String,
      empresa: json['empresa'] as String?,
      nombre: json['nombre'] as String,
      tipoSede: json['tipo_sede'] as String?,
      fkResponsable: json['fk_responsable'] as String?,
      celular: json['celular'] as String?,
      email: json['email'] as String?,
      paginaWeb: json['pagina_web'] as String?,
      logoUrl: json['logo_url'] as String?,
      fkUbigeo: json['fk_ubigeo'] as String?,
      direccion: json['direccion'] as String?,
      columnasExtras: json['columnas_extras'] as Map<String, dynamic>?,
      activo: json['activo'] as bool?,
      zonaHoraria: json['zona_horaria'] as String?,
    );
  }
}
