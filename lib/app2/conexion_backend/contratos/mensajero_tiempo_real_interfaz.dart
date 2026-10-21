/// Responsabilidad: Contrato de tiempo real del mensajero: recibir los cambios
/// de una tabla mientras se escucha.
library;

import 'package:trackmape_sup/app2/conexion_backend/contratos/formulario_lectura.dart';

// INTERFAZ TIEMPO REAL - Escucha de cambios
abstract interface class MensajeroTiempoRealInterfaz {
  // ESCUCHAR - Flujo con el estado actual de los registros en cada cambio.
  // Un mensajero puede no soportar todas las casillas de la consulta al
  // escuchar: si recibe una que no soporta, falla con un error que la nombra.
  Stream<List<Map<String, dynamic>>> escuchar(
    String tabla,
    List<String> clavePrimaria, [
    FormularioLectura consulta = const FormularioLectura(),
  ]);
}
