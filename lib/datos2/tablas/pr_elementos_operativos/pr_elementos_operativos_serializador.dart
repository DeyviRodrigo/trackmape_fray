/// Responsabilidad: Convertir los comandos de pr_elementos_operativos en el mapa que recibe la
/// base, con los nombres de columna y el formato de cada tipo.
library;

import 'package:trackmape_sup/datos2/contratos/tablas/serializador_actualizacion_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/tablas/serializador_insercion_contrato.dart';
import 'package:trackmape_sup/datos2/tablas/pr_elementos_operativos/pr_elementos_operativos_comandos.dart';

// PR ELEMENTOS OPERATIVOS SERIALIZADOR - De comandos a columnas de la base
class PrElementosOperativosSerializador
    implements
        SerializadorInsercionContrato<PrElementosOperativosInsertar>,
        SerializadorActualizacionContrato<PrElementosOperativosActualizar> {
  const PrElementosOperativosSerializador();

  // INSERTAR - Columnas obligatorias siempre; con valor por defecto, si estan
  @override
  Map<String, dynamic> aJsonInsertar(PrElementosOperativosInsertar entrada) {
    final resultado = <String, dynamic>{};
    resultado['fk_empresa'] = entrada.fkEmpresa;
    resultado['fk_sede'] = entrada.fkSede;
    resultado['categoria'] = entrada.categoria;
    resultado['tipo_operativo'] = entrada.tipoOperativo;
    resultado['nombre'] = entrada.nombre;
    resultado['descripcion'] = entrada.descripcion;
    resultado['geojson'] = entrada.geojson;
    if (entrada.idElemento.presente) {
      resultado['id_elemento'] = entrada.idElemento.valor;
    }
    if (entrada.color.presente) {
      resultado['color'] = entrada.color.valor;
    }
    if (entrada.prioridad.presente) {
      resultado['prioridad'] = entrada.prioridad.valor;
    }
    if (entrada.activo.presente) {
      resultado['activo'] = entrada.activo.valor;
    }
    if (entrada.fechaCreacion.presente) {
      resultado['fecha_creacion'] = entrada.fechaCreacion.valor
          ?.toUtc()
          .toIso8601String();
    }
    if (entrada.fechaActualizacion.presente) {
      resultado['fecha_actualizacion'] = entrada.fechaActualizacion.valor
          ?.toUtc()
          .toIso8601String();
    }
    return resultado;
  }

  // ACTUALIZAR - Solo las columnas presentes
  @override
  Map<String, dynamic> aJsonActualizar(
    PrElementosOperativosActualizar cambios,
  ) {
    final resultado = <String, dynamic>{};
    if (cambios.fkEmpresa.presente) {
      resultado['fk_empresa'] = cambios.fkEmpresa.valor;
    }
    if (cambios.fkSede.presente) {
      resultado['fk_sede'] = cambios.fkSede.valor;
    }
    if (cambios.categoria.presente) {
      resultado['categoria'] = cambios.categoria.valor;
    }
    if (cambios.tipoOperativo.presente) {
      resultado['tipo_operativo'] = cambios.tipoOperativo.valor;
    }
    if (cambios.nombre.presente) {
      resultado['nombre'] = cambios.nombre.valor;
    }
    if (cambios.descripcion.presente) {
      resultado['descripcion'] = cambios.descripcion.valor;
    }
    if (cambios.geojson.presente) {
      resultado['geojson'] = cambios.geojson.valor;
    }
    if (cambios.color.presente) {
      resultado['color'] = cambios.color.valor;
    }
    if (cambios.prioridad.presente) {
      resultado['prioridad'] = cambios.prioridad.valor;
    }
    if (cambios.fechaCreacion.presente) {
      resultado['fecha_creacion'] = cambios.fechaCreacion.valor
          ?.toUtc()
          .toIso8601String();
    }
    if (cambios.fechaActualizacion.presente) {
      resultado['fecha_actualizacion'] = cambios.fechaActualizacion.valor
          ?.toUtc()
          .toIso8601String();
    }
    return resultado;
  }
}
