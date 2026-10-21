/// Responsabilidad: Punto de entrada de las pestanas para leer sedes_vt; todo
/// fallo sale como RepositorioException.
library;

import 'package:trackmape_sup/datos2/contratos/vistas/vista_consultar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/vistas/vista_obtener_uno_contrato.dart';
import 'package:trackmape_sup/datos2/errores/ejecutar_repositorio.dart';
import 'package:trackmape_sup/datos2/vistas/sedes_vt/sedes_vt_consulta.dart';
import 'package:trackmape_sup/datos2/vistas/sedes_vt/sedes_vt_fuente.dart';
import 'package:trackmape_sup/datos2/vistas/sedes_vt/sedes_vt_modelo.dart';

// SEDES VT REPOSITORIO - Lectura de la vista con manejo de errores
class SedesVtRepositorio
    implements
        VistaConsultarContrato<SedesVtModelo, SedesVtConsulta>,
        VistaObtenerUnoContrato<SedesVtModelo, SedesVtConsulta> {
  SedesVtRepositorio([SedesVtFuente? fuente])
    : _fuente = fuente ?? SedesVtFuente();

  final SedesVtFuente _fuente;

  // CONSULTAR - Las filas que cumplen la consulta; una consulta vacia trae todas
  @override
  Future<List<SedesVtModelo>> consultar(SedesVtConsulta consulta) =>
      ejecutarRepositorio(
        'Error al consultar sedes_vt',
        () => _fuente.consultar(consulta),
      );

  // OBTENER UNO - La unica fila que cumple la consulta, o nulo
  @override
  Future<SedesVtModelo?> obtenerUno(SedesVtConsulta consulta) =>
      ejecutarRepositorio(
        'Error al obtener un registro de sedes_vt',
        () => _fuente.obtenerUno(consulta),
      );
}
