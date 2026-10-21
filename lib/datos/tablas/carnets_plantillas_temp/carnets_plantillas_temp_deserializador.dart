import 'package:trackmape_sup/datos/interfaces/deserializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/carnets_plantillas_temp/carnets_plantillas_temp_modelo.dart';
import 'package:trackmape_sup/recursos/utilidades/utilidades_json.dart';

class CarnetsPlantillasTempDeserializador
    implements DeserializadorContrato<CarnetsPlantillasTempModelo> {
  @override
  CarnetsPlantillasTempModelo desdeJson(Map<String, dynamic> json) {
    return CarnetsPlantillasTempModelo(
      id_plantilla: json['id_plantilla'] as String,
      fk_empresa: json['fk_empresa'] as String?,
      fk_sede: json['fk_sede'] as String?,
      nombre: json['nombre'] as String,
      orientacion: json['orientacion'] as String? ?? 'horizontal',
      fondo_url: json['fondo_url'] as String?,
      logo_url: json['logo_url'] as String?,
      campos: (json['campos'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      fecha_creacion: aDateTimeNulable(json['fecha_creacion'])!,
      fecha_eliminacion: aDateTimeNulable(json['fecha_eliminacion']),
    );
  }
}
