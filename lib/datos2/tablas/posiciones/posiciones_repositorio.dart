/// Responsabilidad: Punto de entrada de las pestanas para escribir en posiciones;
/// todo fallo sale como RepositorioException.
library;

import 'package:trackmape_sup/datos2/errores/ejecutar_repositorio.dart';
import 'package:trackmape_sup/datos2/contratos/tablas/tabla_insertar_contrato.dart';
import 'package:trackmape_sup/datos2/tablas/posiciones/posiciones_comandos.dart';
import 'package:trackmape_sup/datos2/tablas/posiciones/posiciones_fuente.dart';

// POSICIONES REPOSITORIO - Escritura de la tabla con manejo de errores
class PosicionesRepositorio
    implements TablaInsertarContrato<PosicionesInsertar> {
  PosicionesRepositorio([PosicionesFuente? fuente])
    : _fuente = fuente ?? PosicionesFuente();

  final PosicionesFuente _fuente;

  @override
  Future<void> insertar(PosicionesInsertar entrada) => ejecutarRepositorio(
    'Error al insertar en posiciones',
    () => _fuente.insertar(entrada),
  );
}
