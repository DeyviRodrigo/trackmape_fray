import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/equipos_control/equipos_control_modelo.dart';
import 'package:trackmape_sup/recursos/utilidades/utilidades_json.dart';

class EquiposControlDeserializador
    implements DeserializadorContrato<EquiposControlModelo> {
  @override
  EquiposControlModelo desdeJson(Map<String, dynamic> json) {
    return EquiposControlModelo(
      id_equipo_control: json['id_equipo_control'] as String,
      fk_empresa: json['fk_empresa'] as String,
      fk_sede: json['fk_sede'] as String?,
      nombre: json['nombre'] as String?,
      ubicacion: json['ubicacion'] as String?,
      id_equipo_fabrica: json['id_equipo_fabrica'] as String?,
      tipo_equipo_control: json['tipo_equipo_control'] as String?,
      codigo_equipo_control: json['codigo_equipo_control'] as String?,
      direccion_mac: json['direccion_mac'] as String?,
      observaciones: json['observaciones'] as String?,
      fk_area_asociada: json['fk_area_asociada'] as String?,
      fk_equipo_asociado: json['fk_equipo_asociado'] as String?,
      fecha_inicio: aDateTimeNulable(json['fecha_inicio']),
      fecha_final: aDateTimeNulable(json['fecha_final']),
    );
  }
}
