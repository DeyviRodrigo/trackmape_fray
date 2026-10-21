/// Responsabilidad: Contrato de lectura del mensajero: traer registros segun
/// la hoja de consulta.
library;

import 'package:trackmape_sup/app2/conexion_backend/contratos/formulario_lectura.dart';

// INTERFAZ LECTURA - Consultas sobre tablas y vistas
abstract interface class MensajeroLecturaInterfaz {
  // CONSULTAR - Lista de registros. Una consulta vacia trae todos
  Future<List<Map<String, dynamic>>> consultar(
    String tabla, [
    FormularioLectura consulta = const FormularioLectura(),
  ]);

  // OBTENER UNO - Un registro o nulo. Falla si la consulta encuentra mas de uno
  Future<Map<String, dynamic>?> obtenerUno(
    String tabla,
    FormularioLectura consulta,
  );
}
