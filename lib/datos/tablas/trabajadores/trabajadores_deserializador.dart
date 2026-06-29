import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/trabajadores/trabajadores_modelo.dart';

class TrabajadoresDeserializador
    implements DeserializadorContrato<TrabajadoresModelo> {
  @override
  TrabajadoresModelo desdeJson(Map<String, dynamic> json) {
    return TrabajadoresModelo(
      id_trabajador: json['id_trabajador'] as String,
      fk_persona: json['fk_persona'] as String?,
      fk_sede: json['fk_sede'] as String?,
      celular: json['celular'] as String?,
      email: json['email'] as String?,
      fk_contacto_emergencia: json['fk_contacto_emergencia'] as String?,
      fk_referido: json['fk_referido'] as String?,
      observaciones: json['observaciones'] as String?,
      fotografia_url: json['fotografia_url'] as String?,
      columnas_extras: json['columnas_extras'] as Map<String, dynamic>?,
      fk_ubigeo: json['fk_ubigeo'] as String?,
      direccion: json['direccion'] as String?,
      fk_empresa: json['fk_empresa'] as String,
      activo: json['activo'] as bool,
    );
  }
}
