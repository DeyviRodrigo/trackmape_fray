/// Responsabilidad: Escribir en posiciones a traves del mensajero.
library;

import 'package:trackmape_sup/app2/conexion_backend/contratos/mensajero_escritura_interfaz.dart';
import 'package:trackmape_sup/app2/conexion_backend/mensajero_activo.dart'
    as backend;
import 'package:trackmape_sup/datos2/contratos/tablas/tabla_insertar_contrato.dart';
import 'package:trackmape_sup/datos2/tablas/posiciones/posiciones_comandos.dart';
import 'package:trackmape_sup/datos2/tablas/posiciones/posiciones_serializador.dart';

// POSICIONES FUENTE - Escritura de la tabla contra el mensajero
class PosicionesFuente implements TablaInsertarContrato<PosicionesInsertar> {
  // Recibe el mensajero por constructor para poder probarla sin base real;
  // si no se pasa, usa el mensajero activo.
  PosicionesFuente([MensajeroEscrituraInterfaz? mensajero])
    : _mensajero = mensajero ?? backend.mensajero;

  static const _tabla = 'posiciones';
  final MensajeroEscrituraInterfaz _mensajero;
  final _serializador = const PosicionesSerializador();

  // INSERTAR - Una fila nueva, sin pedir respuesta
  @override
  Future<void> insertar(PosicionesInsertar entrada) =>
      _mensajero.insertar(_tabla, _serializador.aJsonInsertar(entrada));
}
