/// Responsabilidad: Punto de entrada de las pestanas para leer empresas_vt; todo
/// fallo sale como RepositorioException.
library;

import 'package:trackmape_sup/datos2/contratos/vistas/vista_consultar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/vistas/vista_obtener_uno_contrato.dart';
import 'package:trackmape_sup/datos2/errores/ejecutar_repositorio.dart';
import 'package:trackmape_sup/datos2/vistas/empresas_vt/empresas_vt_consulta.dart';
import 'package:trackmape_sup/datos2/vistas/empresas_vt/empresas_vt_fuente.dart';
import 'package:trackmape_sup/datos2/vistas/empresas_vt/empresas_vt_modelo.dart';

// EMPRESAS VT REPOSITORIO - Lectura de la vista con manejo de errores
class EmpresasVtRepositorio
    implements
        VistaConsultarContrato<EmpresasVtModelo, EmpresasVtConsulta>,
        VistaObtenerUnoContrato<EmpresasVtModelo, EmpresasVtConsulta> {
  EmpresasVtRepositorio([EmpresasVtFuente? fuente])
    : _fuente = fuente ?? EmpresasVtFuente();

  final EmpresasVtFuente _fuente;

  // CONSULTAR - Las filas que cumplen la consulta; una consulta vacia trae todas
  @override
  Future<List<EmpresasVtModelo>> consultar(EmpresasVtConsulta consulta) =>
      ejecutarRepositorio(
        'Error al consultar empresas_vt',
        () => _fuente.consultar(consulta),
      );

  // OBTENER UNO - La unica fila que cumple la consulta, o nulo
  @override
  Future<EmpresasVtModelo?> obtenerUno(EmpresasVtConsulta consulta) =>
      ejecutarRepositorio(
        'Error al obtener un registro de empresas_vt',
        () => _fuente.obtenerUno(consulta),
      );
}
