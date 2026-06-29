import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/sedes/sedes_modelo.dart';

class SedesDeserializador implements DeserializadorContrato<SedesModelo> {
  @override
  SedesModelo desdeJson(Map<String, dynamic> json) {
    return SedesModelo(
      id_sede: json['id_sede'] as String,
      fk_empresa: json['fk_empresa'] as String,
      nombre: json['nombre'] as String,
      tipo_sede: json['tipo_sede'] as String?,
      fk_responsable: json['fk_responsable'] as String?,
      celular: json['celular'] as String?,
      email: json['email'] as String?,
      pagina_web: json['pagina_web'] as String?,
      logo_url: json['logo_url'] as String?,
      fk_ubigeo: json['fk_ubigeo'] as String?,
      direccion: json['direccion'] as String?,
      columnas_extras: json['columnas_extras'] as Map<String, dynamic>?,
      activo: json['activo'] as bool?,
      zona_horaria: json['zona_horaria'] as String?,
    );
  }
}
