import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/credenciales_acceso/credenciales_acceso_modelo.dart';

class CredencialesAccesoDeserializador
    implements DeserializadorContrato<CredencialesAccesoModelo> {
  @override
  CredencialesAccesoModelo desdeJson(Map<String, dynamic> json) {
    return CredencialesAccesoModelo(
      id_credencial: json['id_credencial'] as String,
      fk_trabajador: json['fk_trabajador'] as String,
      tecnologia: json['tecnologia'] as String,
      valor: json['valor'] as String,
      clave: json['clave'] as String?,
      activo: json['activo'] as bool,
    );
  }
}
