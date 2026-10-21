/// Responsabilidad: Convertir una fila de equipos_control_vt, tal como responde la base,
/// en EquiposControlVtModelo.
library;

import 'package:trackmape_sup/datos2/contratos/general/deserializador_contrato.dart';
import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_modelo.dart';

// EQUIPOS CONTROL VT DESERIALIZADOR - De columnas de la base a campos del modelo
class EquiposControlVtDeserializador
    implements DeserializadorContrato<EquiposControlVtModelo> {
  const EquiposControlVtDeserializador();

  @override
  EquiposControlVtModelo desdeJson(Map<String, dynamic> json) {
    return EquiposControlVtModelo(
      idEquipoControl: json['id_equipo_control'] as String,
      fkEmpresa: json['fk_empresa'] as String,
      empresa: json['empresa'] as String?,
      fkSede: json['fk_sede'] as String?,
      sede: json['sede'] as String?,
      nombre: json['nombre'] as String?,
      ubicacion: json['ubicacion'] as String?,
      idEquipoFabrica: json['id_equipo_fabrica'] as String?,
      tipoEquipoControl: json['tipo_equipo_control'] as String?,
      codigoEquipoControl: json['codigo_equipo_control'] as String?,
      direccionMac: json['direccion_mac'] as String?,
      observaciones: json['observaciones'] as String?,
      fkAreaAsociada: json['fk_area_asociada'] as String?,
      fkEquipoAsociado: json['fk_equipo_asociado'] as String?,
      fechaInicio: json['fecha_inicio'] == null
          ? null
          : DateTime.parse(json['fecha_inicio'] as String),
      fechaFinal: json['fecha_final'] == null
          ? null
          : DateTime.parse(json['fecha_final'] as String),
    );
  }
}
