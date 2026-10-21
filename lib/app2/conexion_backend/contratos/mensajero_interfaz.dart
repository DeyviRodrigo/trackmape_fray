/// Responsabilidad: Agrupar las cuatro partes del contrato en un mensajero
/// completo, el que expone mensajero_activo.
///
/// Quien consume el mensajero depende solo de la parte que usa: una fuente de
/// vista pide MensajeroLecturaInterfaz, una de tabla MensajeroEscrituraInterfaz.
/// Un mensajero que no pueda cumplir todas las partes implementa solo las suyas.
library;

import 'package:trackmape_sup/app2/conexion_backend/contratos/mensajero_escritura_interfaz.dart';
import 'package:trackmape_sup/app2/conexion_backend/contratos/mensajero_lectura_interfaz.dart';
import 'package:trackmape_sup/app2/conexion_backend/contratos/mensajero_procedimientos_interfaz.dart';
import 'package:trackmape_sup/app2/conexion_backend/contratos/mensajero_tiempo_real_interfaz.dart';

// INTERFAZ MENSAJERO - Lectura, escritura, procedimientos y tiempo real
abstract interface class MensajeroInterfaz
    implements
        MensajeroLecturaInterfaz,
        MensajeroEscrituraInterfaz,
        MensajeroProcedimientosInterfaz,
        MensajeroTiempoRealInterfaz {}
