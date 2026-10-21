/// Responsabilidad: Escribir en equipos_control a traves del mensajero.
library;

import 'package:trackmape_sup/app2/conexion_backend/contratos/seleccion_registro.dart';
import 'package:trackmape_sup/app2/conexion_backend/contratos/mensajero_escritura_interfaz.dart';
import 'package:trackmape_sup/app2/conexion_backend/mensajero_activo.dart'
    as backend;
import 'package:trackmape_sup/datos2/contratos/tablas/tabla_insertar_retornar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/tablas/tabla_actualizar_contrato.dart';
import 'package:trackmape_sup/datos2/tablas/equipos_control/equipos_control_comandos.dart';
import 'package:trackmape_sup/datos2/tablas/equipos_control/equipos_control_serializador.dart';

// EQUIPOS CONTROL FUENTE - Escritura de la tabla contra el mensajero
class EquiposControlFuente
    implements
        TablaInsertarRetornarContrato<EquiposControlInsertar, String>,
        TablaActualizarContrato<String, EquiposControlActualizar> {
  // Recibe el mensajero por constructor para poder probarla sin base real;
  // si no se pasa, usa el mensajero activo.
  EquiposControlFuente([MensajeroEscrituraInterfaz? mensajero])
    : _mensajero = mensajero ?? backend.mensajero;

  static const _tabla = 'equipos_control';
  static const _clave = 'id_equipo_control';
  final MensajeroEscrituraInterfaz _mensajero;
  final _serializador = const EquiposControlSerializador();

  // INSERTAR Y RETORNAR - Una fila nueva; devuelve la clave que asigno la base
  @override
  Future<String> insertarYRetornar(EquiposControlInsertar entrada) async {
    final fila = await _mensajero.insertarYRetornar(
      _tabla,
      _serializador.aJsonInsertar(entrada),
    );
    return fila[_clave] as String;
  }

  // ACTUALIZAR - Solo las columnas presentes de la fila con esa clave
  @override
  Future<void> actualizar(String clave, EquiposControlActualizar cambios) =>
      _mensajero.actualizar(
        _tabla,
        _serializador.aJsonActualizar(cambios),
        SeleccionRegistro(_clave, clave),
      );
}
