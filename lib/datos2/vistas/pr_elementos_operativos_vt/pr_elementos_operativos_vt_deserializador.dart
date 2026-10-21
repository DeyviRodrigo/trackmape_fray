/// Responsabilidad: Convertir una fila de pr_elementos_operativos_vt, tal como responde la base,
/// en PrElementosOperativosVtModelo.
library;

import 'package:trackmape_sup/datos2/contratos/general/deserializador_contrato.dart';
import 'package:trackmape_sup/datos2/vistas/pr_elementos_operativos_vt/pr_elementos_operativos_vt_modelo.dart';

// PR ELEMENTOS OPERATIVOS VT DESERIALIZADOR - De columnas de la base a campos del modelo
class PrElementosOperativosVtDeserializador
    implements DeserializadorContrato<PrElementosOperativosVtModelo> {
  const PrElementosOperativosVtDeserializador();

  @override
  PrElementosOperativosVtModelo desdeJson(Map<String, dynamic> json) {
    return PrElementosOperativosVtModelo(
      idElemento: json['id_elemento'] as String,
      fkEmpresa: json['fk_empresa'] as String,
      empresa: json['empresa'] as String?,
      fkSede: json['fk_sede'] as String?,
      sede: json['sede'] as String?,
      categoria: json['categoria'] as String,
      tipoOperativo: json['tipo_operativo'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      geojson: json['geojson'] as Map<String, dynamic>,
      color: json['color'] as String,
      prioridad: (json['prioridad'] as num).toInt(),
      activo: json['activo'] as bool,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      fechaActualizacion: DateTime.parse(json['fecha_actualizacion'] as String),
    );
  }
}
