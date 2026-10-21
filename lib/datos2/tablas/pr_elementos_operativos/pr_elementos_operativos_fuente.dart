/// Responsabilidad: Escribir en pr_elementos_operativos a traves del mensajero.
library;

import 'package:trackmape_sup/app2/conexion_backend/contratos/seleccion_registro.dart';
import 'package:trackmape_sup/app2/conexion_backend/contratos/mensajero_escritura_interfaz.dart';
import 'package:trackmape_sup/app2/conexion_backend/mensajero_activo.dart'
    as backend;
import 'package:trackmape_sup/datos2/contratos/tablas/tabla_insertar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/tablas/tabla_actualizar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/tablas/tabla_desactivar_contrato.dart';
import 'package:trackmape_sup/datos2/contratos/tablas/tabla_activar_contrato.dart';
import 'package:trackmape_sup/datos2/tablas/pr_elementos_operativos/pr_elementos_operativos_comandos.dart';
import 'package:trackmape_sup/datos2/tablas/pr_elementos_operativos/pr_elementos_operativos_serializador.dart';

// PR ELEMENTOS OPERATIVOS FUENTE - Escritura de la tabla contra el mensajero
class PrElementosOperativosFuente
    implements
        TablaInsertarContrato<PrElementosOperativosInsertar>,
        TablaActualizarContrato<String, PrElementosOperativosActualizar>,
        TablaDesactivarContrato<String>,
        TablaActivarContrato<String> {
  // Recibe el mensajero por constructor para poder probarla sin base real;
  // si no se pasa, usa el mensajero activo.
  PrElementosOperativosFuente([MensajeroEscrituraInterfaz? mensajero])
    : _mensajero = mensajero ?? backend.mensajero;

  static const _tabla = 'pr_elementos_operativos';
  static const _clave = 'id_elemento';
  final MensajeroEscrituraInterfaz _mensajero;
  final _serializador = const PrElementosOperativosSerializador();

  // INSERTAR - Una fila nueva, sin pedir respuesta
  @override
  Future<void> insertar(PrElementosOperativosInsertar entrada) =>
      _mensajero.insertar(_tabla, _serializador.aJsonInsertar(entrada));

  // ACTUALIZAR - Solo las columnas presentes de la fila con esa clave
  @override
  Future<void> actualizar(
    String clave,
    PrElementosOperativosActualizar cambios,
  ) => _mensajero.actualizar(
    _tabla,
    _serializador.aJsonActualizar(cambios),
    SeleccionRegistro(_clave, clave),
  );

  // DESACTIVAR - Borrado logico de la fila con esa clave
  @override
  Future<void> desactivar(String clave) =>
      _mensajero.desactivar(_tabla, SeleccionRegistro(_clave, clave));

  // ACTIVAR - Revierte la baja de la fila con esa clave
  @override
  Future<void> activar(String clave) =>
      _mensajero.activar(_tabla, SeleccionRegistro(_clave, clave));
}
