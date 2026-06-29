import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/vistas/v_empresas/v_empresas_modelo.dart';
import 'package:trackmape_sup/recursos/utilidades/utilidades_json.dart';

class VEmpresasDeserializador
    implements DeserializadorContrato<VEmpresasModelo> {
  @override
  VEmpresasModelo desdeJson(Map<String, dynamic> json) {
    return VEmpresasModelo(
      id_empresa: json['id_empresa'] as String,
      pais: json['pais'] as String?,
      tipo_documento: json['tipo_documento'] as String?,
      numero_documento: json['numero_documento'] as String?,
      razon_social: json['razon_social'] as String?,
      nombre_comercial: json['nombre_comercial'] as String?,
      estado: json['estado'] as String?,
      condicion: json['condicion'] as String?,
      ubigeo: aListaMapasNulable(json['ubigeo']),
      direccion: json['direccion'] as String?,
      celular: json['celular'] as String?,
      email: json['email'] as String?,
      pagina_web: json['pagina_web'] as String?,
      logo_url: json['logo_url'] as String?,
      total_sedes: json['total_sedes'] as int,
      total_sedes_activas: json['total_sedes_activas'] as int,
      total_trabajadores: json['total_trabajadores'] as int,
      total_trabajadores_activos: json['total_trabajadores_activos'] as int,
      empresa_verificada: json['empresa_verificada'] as bool?,
      fuente_verificacion: json['fuente_verificacion'] as String?,
      fecha_verificacion: aDateTimeNulable(json['fecha_verificacion']),
      empresa_activa: json['empresa_activa'] as bool?,
      columnas_extras: json['columnas_extras'] as Map<String, dynamic>?,
    );
  }
}
