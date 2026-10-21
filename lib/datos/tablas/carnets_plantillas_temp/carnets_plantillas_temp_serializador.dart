import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/carnets_plantillas_temp/carnets_plantillas_temp_modelo.dart';

class CarnetsPlantillasTempSerializador
    implements SerializadorContrato<CarnetsPlantillasTempModelo> {
  @override
  Map<String, dynamic> aJson(CarnetsPlantillasTempModelo modelo) {
    return {
      if (modelo.id_plantilla.isNotEmpty) 'id_plantilla': modelo.id_plantilla,
      'fk_empresa': modelo.fk_empresa,
      'fk_sede': modelo.fk_sede,
      'nombre': modelo.nombre,
      'orientacion': modelo.orientacion,
      'fondo_url': modelo.fondo_url,
      'logo_url': modelo.logo_url,
      'campos': modelo.campos,
      if (modelo.fecha_eliminacion != null)
        'fecha_eliminacion': modelo.fecha_eliminacion!.toIso8601String(),
    };
  }
}
