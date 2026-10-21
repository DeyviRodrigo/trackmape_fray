/// Responsabilidad: Convertir los comandos de equipos_control en el mapa que recibe la
/// base, con los nombres de columna y el formato de cada tipo.
library;

import 'package:trackmape_sup/datos2/contratos/tablas/serializador_actualizacion_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/tablas/serializador_insercion_contrato.dart';
import 'package:trackmape_sup/datos2/tablas/equipos_control/equipos_control_comandos.dart';

// EQUIPOS CONTROL SERIALIZADOR - De comandos a columnas de la base
class EquiposControlSerializador
    implements
        SerializadorInsercionContrato<EquiposControlInsertar>,
        SerializadorActualizacionContrato<EquiposControlActualizar> {
  const EquiposControlSerializador();

  // INSERTAR - Columnas obligatorias siempre; con valor por defecto, si estan
  @override
  Map<String, dynamic> aJsonInsertar(EquiposControlInsertar entrada) {
    final resultado = <String, dynamic>{};
    resultado['fk_empresa'] = entrada.fkEmpresa;
    resultado['fk_sede'] = entrada.fkSede;
    resultado['nombre'] = entrada.nombre;
    resultado['ubicacion'] = entrada.ubicacion;
    resultado['id_equipo_fabrica'] = entrada.idEquipoFabrica;
    resultado['tipo_equipo_control'] = entrada.tipoEquipoControl;
    resultado['codigo_equipo_control'] = entrada.codigoEquipoControl;
    resultado['direccion_mac'] = entrada.direccionMac;
    resultado['observaciones'] = entrada.observaciones;
    resultado['fk_area_asociada'] = entrada.fkAreaAsociada;
    resultado['fk_equipo_asociado'] = entrada.fkEquipoAsociado;
    resultado['fecha_inicio'] = entrada.fechaInicio
        ?.toIso8601String()
        .substring(0, 10);
    resultado['fecha_final'] = entrada.fechaFinal?.toIso8601String().substring(
      0,
      10,
    );
    if (entrada.idEquipoControl.presente) {
      resultado['id_equipo_control'] = entrada.idEquipoControl.valor;
    }
    return resultado;
  }

  // ACTUALIZAR - Solo las columnas presentes
  @override
  Map<String, dynamic> aJsonActualizar(EquiposControlActualizar cambios) {
    final resultado = <String, dynamic>{};
    if (cambios.fkEmpresa.presente) {
      resultado['fk_empresa'] = cambios.fkEmpresa.valor;
    }
    if (cambios.fkSede.presente) {
      resultado['fk_sede'] = cambios.fkSede.valor;
    }
    if (cambios.nombre.presente) {
      resultado['nombre'] = cambios.nombre.valor;
    }
    if (cambios.ubicacion.presente) {
      resultado['ubicacion'] = cambios.ubicacion.valor;
    }
    if (cambios.idEquipoFabrica.presente) {
      resultado['id_equipo_fabrica'] = cambios.idEquipoFabrica.valor;
    }
    if (cambios.tipoEquipoControl.presente) {
      resultado['tipo_equipo_control'] = cambios.tipoEquipoControl.valor;
    }
    if (cambios.codigoEquipoControl.presente) {
      resultado['codigo_equipo_control'] = cambios.codigoEquipoControl.valor;
    }
    if (cambios.direccionMac.presente) {
      resultado['direccion_mac'] = cambios.direccionMac.valor;
    }
    if (cambios.observaciones.presente) {
      resultado['observaciones'] = cambios.observaciones.valor;
    }
    if (cambios.fkAreaAsociada.presente) {
      resultado['fk_area_asociada'] = cambios.fkAreaAsociada.valor;
    }
    if (cambios.fkEquipoAsociado.presente) {
      resultado['fk_equipo_asociado'] = cambios.fkEquipoAsociado.valor;
    }
    if (cambios.fechaInicio.presente) {
      resultado['fecha_inicio'] = cambios.fechaInicio.valor
          ?.toIso8601String()
          .substring(0, 10);
    }
    if (cambios.fechaFinal.presente) {
      resultado['fecha_final'] = cambios.fechaFinal.valor
          ?.toIso8601String()
          .substring(0, 10);
    }
    return resultado;
  }
}
