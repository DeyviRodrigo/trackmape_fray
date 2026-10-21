/// Responsabilidad: Contrato de escritura del mensajero: insertar, actualizar
/// y dar de baja registros.
///
/// Ningun metodo elimina registros: dar de baja es desactivar, y la fila se
/// conserva en la base de datos. Las escrituras que alcanzan registros
/// existentes reciben SeleccionRegistro, que no puede estar vacia.
library;

import 'package:trackmape_sup/app2/conexion_backend/contratos/seleccion_registro.dart';

// INTERFAZ ESCRITURA - Insercion, actualizacion y borrado logico
abstract interface class MensajeroEscrituraInterfaz {
  // INSERTAR - Guarda un registro nuevo sin pedir respuesta
  Future<void> insertar(String tabla, Map<String, dynamic> datos);

  // INSERTAR Y RETORNAR - Guarda un registro nuevo y lo devuelve como quedo
  Future<Map<String, dynamic>> insertarYRetornar(
    String tabla,
    Map<String, dynamic> datos,
  );

  // ACTUALIZAR - Cambia el contenido de los registros que cumplen las condiciones
  Future<void> actualizar(
    String tabla,
    Map<String, dynamic> datos,
    SeleccionRegistro seleccion,
  );

  // DESACTIVAR - Borrado logico: marca activo = false
  Future<void> desactivar(String tabla, SeleccionRegistro seleccion);

  // ACTIVAR - Revierte la baja: marca activo = true
  Future<void> activar(String tabla, SeleccionRegistro seleccion);
}
