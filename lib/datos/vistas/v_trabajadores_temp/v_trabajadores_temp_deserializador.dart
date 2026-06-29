import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajadores_temp/v_trabajadores_temp_modelo.dart';

class VTrabajadoresTempDeserializador
    implements DeserializadorContrato<VTrabajadoresTempModelo> {
  @override
  VTrabajadoresTempModelo desdeJson(Map<String, dynamic> json) {
    return VTrabajadoresTempModelo(
      id_trabajador: json['id_trabajador'] as String,
      fk_persona: json['fk_persona'] as String,
      fk_empresa: json['fk_empresa'] as String,
      fk_sede: json['fk_sede'] as String?,
      celular: json['celular'] as String?,
      email: json['email'] as String?,
      direccion: json['direccion'] as String?,
      fotografia_url: json['fotografia_url'] as String?,
      observaciones: json['observaciones'] as String?,
      activo: json['activo'] as bool,
      fk_contacto_emergencia: json['fk_contacto_emergencia'] as String?,
      fk_referido: json['fk_referido'] as String?,
      empresa_nombre: json['empresa_nombre'] as String,
      sede_nombre: json['sede_nombre'] as String?,
    );
  }
}
