/// Responsabilidad: Leer pr_elementos_operativos_vt a traves del mensajero y convertir cada fila
/// en PrElementosOperativosVtModelo.
library;

import 'package:trackmape_sup/datos2/contratos/vistas/vista_consultar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/vistas/vista_obtener_uno_contrato.dart';
import 'package:trackmape_sup/app2/conexion_backend/contratos/mensajero_lectura_interfaz.dart';
import 'package:trackmape_sup/app2/conexion_backend/mensajero_activo.dart'
    as backend;
import 'package:trackmape_sup/datos2/vistas/pr_elementos_operativos_vt/pr_elementos_operativos_vt_consulta.dart';
import 'package:trackmape_sup/datos2/vistas/pr_elementos_operativos_vt/pr_elementos_operativos_vt_deserializador.dart';
import 'package:trackmape_sup/datos2/vistas/pr_elementos_operativos_vt/pr_elementos_operativos_vt_modelo.dart';

// PR ELEMENTOS OPERATIVOS VT FUENTE - Lectura de la vista contra el mensajero
class PrElementosOperativosVtFuente
    implements
        VistaConsultarContrato<
          PrElementosOperativosVtModelo,
          PrElementosOperativosVtConsulta
        >,
        VistaObtenerUnoContrato<
          PrElementosOperativosVtModelo,
          PrElementosOperativosVtConsulta
        > {
  // Recibe el mensajero por constructor para poder probarla sin base real;
  // si no se pasa, usa el mensajero activo.
  PrElementosOperativosVtFuente([MensajeroLecturaInterfaz? mensajero])
    : _mensajero = mensajero ?? backend.mensajero;

  static const _vista = 'pr_elementos_operativos_vt';
  final MensajeroLecturaInterfaz _mensajero;
  final _deserializador = const PrElementosOperativosVtDeserializador();

  // CONSULTAR - Las filas que cumplen la consulta
  @override
  Future<List<PrElementosOperativosVtModelo>> consultar(
    PrElementosOperativosVtConsulta consulta,
  ) async {
    final filas = await _mensajero.consultar(
      _vista,
      consulta.aFormularioLectura(),
    );
    return filas.map(_deserializador.desdeJson).toList(growable: false);
  }

  // OBTENER UNO - La unica fila que cumple la consulta, o nulo
  @override
  Future<PrElementosOperativosVtModelo?> obtenerUno(
    PrElementosOperativosVtConsulta consulta,
  ) async {
    final fila = await _mensajero.obtenerUno(
      _vista,
      consulta.aFormularioLectura(),
    );
    return fila == null ? null : _deserializador.desdeJson(fila);
  }
}
