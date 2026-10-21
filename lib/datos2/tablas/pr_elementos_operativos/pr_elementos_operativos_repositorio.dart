/// Responsabilidad: Punto de entrada de las pestanas para escribir en pr_elementos_operativos;
/// todo fallo sale como RepositorioException.
library;

import 'package:trackmape_sup/datos2/errores/ejecutar_repositorio.dart';
import 'package:trackmape_sup/datos2/contratos/tablas/tabla_insertar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/tablas/tabla_actualizar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/tablas/tabla_desactivar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/tablas/tabla_activar_contrato.dart';
import 'package:trackmape_sup/datos2/tablas/pr_elementos_operativos/pr_elementos_operativos_comandos.dart';
import 'package:trackmape_sup/datos2/tablas/pr_elementos_operativos/pr_elementos_operativos_fuente.dart';

// PR ELEMENTOS OPERATIVOS REPOSITORIO - Escritura de la tabla con manejo de errores
class PrElementosOperativosRepositorio
    implements
        TablaInsertarContrato<PrElementosOperativosInsertar>,
        TablaActualizarContrato<String, PrElementosOperativosActualizar>,
        TablaDesactivarContrato<String>,
        TablaActivarContrato<String> {
  PrElementosOperativosRepositorio([PrElementosOperativosFuente? fuente])
    : _fuente = fuente ?? PrElementosOperativosFuente();

  final PrElementosOperativosFuente _fuente;

  @override
  Future<void> insertar(PrElementosOperativosInsertar entrada) =>
      ejecutarRepositorio(
        'Error al insertar en pr_elementos_operativos',
        () => _fuente.insertar(entrada),
      );

  @override
  Future<void> actualizar(
    String clave,
    PrElementosOperativosActualizar cambios,
  ) => ejecutarRepositorio(
    'Error al actualizar pr_elementos_operativos',
    () => _fuente.actualizar(clave, cambios),
  );

  @override
  Future<void> desactivar(String clave) => ejecutarRepositorio(
    'Error al desactivar en pr_elementos_operativos',
    () => _fuente.desactivar(clave),
  );

  @override
  Future<void> activar(String clave) => ejecutarRepositorio(
    'Error al activar en pr_elementos_operativos',
    () => _fuente.activar(clave),
  );
}
