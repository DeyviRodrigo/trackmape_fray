/// Responsabilidad: Leer empresas_vt a traves del mensajero y convertir cada fila
/// en EmpresasVtModelo.
library;

import 'package:trackmape_sup/datos2/contratos/vistas/vista_consultar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/vistas/vista_obtener_uno_contrato.dart';
import 'package:trackmape_sup/app2/conexion_backend/contratos/mensajero_lectura_interfaz.dart';
import 'package:trackmape_sup/app2/conexion_backend/mensajero_activo.dart'
    as backend;
import 'package:trackmape_sup/datos2/vistas/empresas_vt/empresas_vt_consulta.dart';
import 'package:trackmape_sup/datos2/vistas/empresas_vt/empresas_vt_deserializador.dart';
import 'package:trackmape_sup/datos2/vistas/empresas_vt/empresas_vt_modelo.dart';

// EMPRESAS VT FUENTE - Lectura de la vista contra el mensajero
class EmpresasVtFuente
    implements
        VistaConsultarContrato<EmpresasVtModelo, EmpresasVtConsulta>,
        VistaObtenerUnoContrato<EmpresasVtModelo, EmpresasVtConsulta> {
  // Recibe el mensajero por constructor para poder probarla sin base real;
  // si no se pasa, usa el mensajero activo.
  EmpresasVtFuente([MensajeroLecturaInterfaz? mensajero])
    : _mensajero = mensajero ?? backend.mensajero;

  static const _vista = 'empresas_vt';
  final MensajeroLecturaInterfaz _mensajero;
  final _deserializador = const EmpresasVtDeserializador();

  // CONSULTAR - Las filas que cumplen la consulta
  @override
  Future<List<EmpresasVtModelo>> consultar(EmpresasVtConsulta consulta) async {
    final filas = await _mensajero.consultar(
      _vista,
      consulta.aFormularioLectura(),
    );
    return filas.map(_deserializador.desdeJson).toList(growable: false);
  }

  // OBTENER UNO - La unica fila que cumple la consulta, o nulo
  @override
  Future<EmpresasVtModelo?> obtenerUno(EmpresasVtConsulta consulta) async {
    final fila = await _mensajero.obtenerUno(
      _vista,
      consulta.aFormularioLectura(),
    );
    return fila == null ? null : _deserializador.desdeJson(fila);
  }
}
