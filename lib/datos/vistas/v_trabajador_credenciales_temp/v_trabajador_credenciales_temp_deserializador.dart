import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajador_credenciales_temp/v_trabajador_credenciales_temp_modelo.dart';

class VTrabajadorCredencialesTempDeserializador
    implements DeserializadorContrato<VTrabajadorCredencialesTempModelo> {
  @override
  VTrabajadorCredencialesTempModelo desdeJson(Map<String, dynamic> json) {
    return VTrabajadorCredencialesTempModelo(
      id_credencial: json['id_credencial'] as String,
      fk_trabajador: json['fk_trabajador'] as String,
      tecnologia: json['tecnologia'] as String,
      valor: json['valor'] as String,
      clave: json['clave'] as String?,
      activo: json['activo'] as bool,
    );
  }
}
