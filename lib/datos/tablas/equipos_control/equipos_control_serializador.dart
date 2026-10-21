import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/equipos_control/equipos_control_modelo.dart';
import 'package:trackmape_sup/recursos/utilidades/utilidades_fecha.dart';

class EquiposControlSerializador
    implements SerializadorContrato<EquiposControlModelo> {
  @override
  Map<String, dynamic> aJson(EquiposControlModelo modelo) {
    return {
      if (modelo.id_equipo_control.isNotEmpty)
        'id_equipo_control': modelo.id_equipo_control,
      'fk_empresa': modelo.fk_empresa,
      'fk_sede': modelo.fk_sede,
      'nombre': modelo.nombre,
      'ubicacion': modelo.ubicacion,
      'id_equipo_fabrica': modelo.id_equipo_fabrica,
      'tipo_equipo_control': modelo.tipo_equipo_control,
      'codigo_equipo_control': modelo.codigo_equipo_control,
      'direccion_mac': modelo.direccion_mac,
      'observaciones': modelo.observaciones,
      'fk_area_asociada': modelo.fk_area_asociada,
      'fk_equipo_asociado': modelo.fk_equipo_asociado,
      'fecha_inicio': modelo.fecha_inicio != null
          ? formatearFecha(modelo.fecha_inicio!)
          : null,
      'fecha_final': modelo.fecha_final != null
          ? formatearFecha(modelo.fecha_final!)
          : null,
    };
  }
}
