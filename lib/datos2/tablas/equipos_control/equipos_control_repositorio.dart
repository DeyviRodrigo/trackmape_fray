/// Responsabilidad: Punto de entrada de las pestanas para escribir en equipos_control;
/// todo fallo sale como RepositorioException.
library;

import 'package:trackmape_sup/datos2/errores/ejecutar_repositorio.dart';
import 'package:trackmape_sup/datos2/contratos/tablas/tabla_insertar_retornar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/tablas/tabla_actualizar_contrato.dart';
import 'package:trackmape_sup/datos2/tablas/equipos_control/equipos_control_comandos.dart';
import 'package:trackmape_sup/datos2/tablas/equipos_control/equipos_control_fuente.dart';

// EQUIPOS CONTROL REPOSITORIO - Escritura de la tabla con manejo de errores
class EquiposControlRepositorio
    implements
        TablaInsertarRetornarContrato<EquiposControlInsertar, String>,
        TablaActualizarContrato<String, EquiposControlActualizar> {
  EquiposControlRepositorio([EquiposControlFuente? fuente])
    : _fuente = fuente ?? EquiposControlFuente();

  final EquiposControlFuente _fuente;

  @override
  Future<String> insertarYRetornar(EquiposControlInsertar entrada) =>
      ejecutarRepositorio(
        'Error al insertar en equipos_control',
        () => _fuente.insertarYRetornar(entrada),
      );

  @override
  Future<void> actualizar(String clave, EquiposControlActualizar cambios) =>
      ejecutarRepositorio(
        'Error al actualizar equipos_control',
        () => _fuente.actualizar(clave, cambios),
      );
}
