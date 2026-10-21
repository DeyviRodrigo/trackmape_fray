/// Responsabilidad: Punto de entrada de las pestanas para leer equipos_control_vt; todo
/// fallo sale como RepositorioException.
library;

import 'package:trackmape_sup/datos2/contratos/vistas/vista_consultar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/vistas/vista_obtener_uno_contrato.dart';
import 'package:trackmape_sup/datos2/errores/ejecutar_repositorio.dart';
import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_consulta.dart';
import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_fuente.dart';
import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_modelo.dart';

// EQUIPOS CONTROL VT REPOSITORIO - Lectura de la vista con manejo de errores
class EquiposControlVtRepositorio
    implements
        VistaConsultarContrato<
          EquiposControlVtModelo,
          EquiposControlVtConsulta
        >,
        VistaObtenerUnoContrato<
          EquiposControlVtModelo,
          EquiposControlVtConsulta
        > {
  EquiposControlVtRepositorio([EquiposControlVtFuente? fuente])
    : _fuente = fuente ?? EquiposControlVtFuente();

  final EquiposControlVtFuente _fuente;

  // CONSULTAR - Las filas que cumplen la consulta; una consulta vacia trae todas
  @override
  Future<List<EquiposControlVtModelo>> consultar(
    EquiposControlVtConsulta consulta,
  ) => ejecutarRepositorio(
    'Error al consultar equipos_control_vt',
    () => _fuente.consultar(consulta),
  );

  // OBTENER UNO - La unica fila que cumple la consulta, o nulo
  @override
  Future<EquiposControlVtModelo?> obtenerUno(
    EquiposControlVtConsulta consulta,
  ) => ejecutarRepositorio(
    'Error al obtener un registro de equipos_control_vt',
    () => _fuente.obtenerUno(consulta),
  );
}
