/// Responsabilidad: Punto de entrada de las pestanas para leer pr_elementos_operativos_vt; todo
/// fallo sale como RepositorioException.
library;

import 'package:trackmape_sup/datos2/contratos/vistas/vista_consultar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/vistas/vista_obtener_uno_contrato.dart';
import 'package:trackmape_sup/datos2/errores/ejecutar_repositorio.dart';
import 'package:trackmape_sup/datos2/vistas/pr_elementos_operativos_vt/pr_elementos_operativos_vt_consulta.dart';
import 'package:trackmape_sup/datos2/vistas/pr_elementos_operativos_vt/pr_elementos_operativos_vt_fuente.dart';
import 'package:trackmape_sup/datos2/vistas/pr_elementos_operativos_vt/pr_elementos_operativos_vt_modelo.dart';

// PR ELEMENTOS OPERATIVOS VT REPOSITORIO - Lectura de la vista con manejo de errores
class PrElementosOperativosVtRepositorio
    implements
        VistaConsultarContrato<
          PrElementosOperativosVtModelo,
          PrElementosOperativosVtConsulta
        >,
        VistaObtenerUnoContrato<
          PrElementosOperativosVtModelo,
          PrElementosOperativosVtConsulta
        > {
  PrElementosOperativosVtRepositorio([PrElementosOperativosVtFuente? fuente])
    : _fuente = fuente ?? PrElementosOperativosVtFuente();

  final PrElementosOperativosVtFuente _fuente;

  // CONSULTAR - Las filas que cumplen la consulta; una consulta vacia trae todas
  @override
  Future<List<PrElementosOperativosVtModelo>> consultar(
    PrElementosOperativosVtConsulta consulta,
  ) => ejecutarRepositorio(
    'Error al consultar pr_elementos_operativos_vt',
    () => _fuente.consultar(consulta),
  );

  // OBTENER UNO - La unica fila que cumple la consulta, o nulo
  @override
  Future<PrElementosOperativosVtModelo?> obtenerUno(
    PrElementosOperativosVtConsulta consulta,
  ) => ejecutarRepositorio(
    'Error al obtener un registro de pr_elementos_operativos_vt',
    () => _fuente.obtenerUno(consulta),
  );
}
