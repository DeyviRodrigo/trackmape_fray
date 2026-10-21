/// Responsabilidad: Punto de entrada de las pestanas para leer posiciones_temp_vt; todo
/// fallo sale como RepositorioException.
library;

import 'package:trackmape_sup/datos2/contratos/vistas/vista_consultar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/vistas/vista_obtener_uno_contrato.dart';
import 'package:trackmape_sup/datos2/errores/ejecutar_repositorio.dart';
import 'package:trackmape_sup/datos2/vistas/posiciones_temp_vt/posiciones_temp_vt_consulta.dart';
import 'package:trackmape_sup/datos2/vistas/posiciones_temp_vt/posiciones_temp_vt_fuente.dart';
import 'package:trackmape_sup/datos2/vistas/posiciones_temp_vt/posiciones_temp_vt_modelo.dart';

// POSICIONES TEMP VT REPOSITORIO - Lectura de la vista con manejo de errores
class PosicionesTempVtRepositorio
    implements
        VistaConsultarContrato<
          PosicionesTempVtModelo,
          PosicionesTempVtConsulta
        >,
        VistaObtenerUnoContrato<
          PosicionesTempVtModelo,
          PosicionesTempVtConsulta
        > {
  PosicionesTempVtRepositorio([PosicionesTempVtFuente? fuente])
    : _fuente = fuente ?? PosicionesTempVtFuente();

  final PosicionesTempVtFuente _fuente;

  // CONSULTAR - Las filas que cumplen la consulta; una consulta vacia trae todas
  @override
  Future<List<PosicionesTempVtModelo>> consultar(
    PosicionesTempVtConsulta consulta,
  ) => ejecutarRepositorio(
    'Error al consultar posiciones_temp_vt',
    () => _fuente.consultar(consulta),
  );

  // OBTENER UNO - La unica fila que cumple la consulta, o nulo
  @override
  Future<PosicionesTempVtModelo?> obtenerUno(
    PosicionesTempVtConsulta consulta,
  ) => ejecutarRepositorio(
    'Error al obtener un registro de posiciones_temp_vt',
    () => _fuente.obtenerUno(consulta),
  );
}
