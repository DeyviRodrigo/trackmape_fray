/// Responsabilidad: Leer equipos_control_vt a traves del mensajero y convertir cada fila
/// en EquiposControlVtModelo.
library;

import 'package:trackmape_sup/datos2/contratos/vistas/vista_consultar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/vistas/vista_obtener_uno_contrato.dart';
import 'package:trackmape_sup/app2/conexion_backend/contratos/mensajero_lectura_interfaz.dart';
import 'package:trackmape_sup/app2/conexion_backend/mensajero_activo.dart'
    as backend;
import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_consulta.dart';
import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_deserializador.dart';
import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_modelo.dart';

// EQUIPOS CONTROL VT FUENTE - Lectura de la vista contra el mensajero
class EquiposControlVtFuente
    implements
        VistaConsultarContrato<
          EquiposControlVtModelo,
          EquiposControlVtConsulta
        >,
        VistaObtenerUnoContrato<
          EquiposControlVtModelo,
          EquiposControlVtConsulta
        > {
  // Recibe el mensajero por constructor para poder probarla sin base real;
  // si no se pasa, usa el mensajero activo.
  EquiposControlVtFuente([MensajeroLecturaInterfaz? mensajero])
    : _mensajero = mensajero ?? backend.mensajero;

  static const _vista = 'equipos_control_vt';
  final MensajeroLecturaInterfaz _mensajero;
  final _deserializador = const EquiposControlVtDeserializador();

  // CONSULTAR - Las filas que cumplen la consulta
  @override
  Future<List<EquiposControlVtModelo>> consultar(
    EquiposControlVtConsulta consulta,
  ) async {
    final filas = await _mensajero.consultar(
      _vista,
      consulta.aFormularioLectura(),
    );
    return filas.map(_deserializador.desdeJson).toList(growable: false);
  }

  // OBTENER UNO - La unica fila que cumple la consulta, o nulo
  @override
  Future<EquiposControlVtModelo?> obtenerUno(
    EquiposControlVtConsulta consulta,
  ) async {
    final fila = await _mensajero.obtenerUno(
      _vista,
      consulta.aFormularioLectura(),
    );
    return fila == null ? null : _deserializador.desdeJson(fila);
  }
}
