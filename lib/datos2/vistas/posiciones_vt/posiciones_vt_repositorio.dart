/// Responsabilidad: Punto de entrada de las pestanas para leer posiciones_vt; todo
/// fallo sale como RepositorioException.
library;

import 'package:trackmape_sup/datos2/contratos/vistas/vista_consultar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/vistas/vista_obtener_uno_contrato.dart';
import 'package:trackmape_sup/datos2/errores/ejecutar_repositorio.dart';
import 'package:trackmape_sup/datos2/vistas/posiciones_vt/posiciones_vt_consulta.dart';
import 'package:trackmape_sup/datos2/vistas/posiciones_vt/posiciones_vt_fuente.dart';
import 'package:trackmape_sup/datos2/vistas/posiciones_vt/posiciones_vt_modelo.dart';

// POSICIONES VT REPOSITORIO - Lectura de la vista con manejo de errores
class PosicionesVtRepositorio
    implements
        VistaConsultarContrato<PosicionesVtModelo, PosicionesVtConsulta>,
        VistaObtenerUnoContrato<PosicionesVtModelo, PosicionesVtConsulta> {
  PosicionesVtRepositorio([PosicionesVtFuente? fuente])
    : _fuente = fuente ?? PosicionesVtFuente();

  final PosicionesVtFuente _fuente;

  // CONSULTAR - Las filas que cumplen la consulta; una consulta vacia trae todas
  @override
  Future<List<PosicionesVtModelo>> consultar(PosicionesVtConsulta consulta) =>
      ejecutarRepositorio(
        'Error al consultar posiciones_vt',
        () => _fuente.consultar(consulta),
      );

  // OBTENER UNO - La unica fila que cumple la consulta, o nulo
  @override
  Future<PosicionesVtModelo?> obtenerUno(PosicionesVtConsulta consulta) =>
      ejecutarRepositorio(
        'Error al obtener un registro de posiciones_vt',
        () => _fuente.obtenerUno(consulta),
      );
}
