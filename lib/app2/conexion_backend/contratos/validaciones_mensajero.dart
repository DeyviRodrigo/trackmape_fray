/// Responsabilidad: Hacer cumplir las reglas del contrato del mensajero que
/// valen para cualquier backend y que no se pueden evitar con la forma de los
/// datos.
///
/// Las que si se pueden evitar no estan aqui: pedir un maximo y una pagina a
/// la vez no se puede escribir (FormularioLectura tiene una sola casilla
/// tramo), y escribir sin condiciones tampoco (SeleccionRegistro exige una).
library;

import 'package:trackmape_sup/app2/conexion_backend/contratos/formulario_lectura.dart';

// VALIDACIONES MENSAJERO - Reglas del contrato comunes a todo backend
class ValidacionesMensajero {
  ValidacionesMensajero._();

  // CONSULTA DE UN REGISTRO - obtenerUno identifica el registro por sus
  // condiciones; un tramo no tiene sentido ahi.
  static void validarConsultaDeUno(FormularioLectura consulta) {
    if (consulta.tramo != null) {
      throw ArgumentError(
        'obtenerUno no admite la casilla tramo: '
        'el registro debe quedar identificado por sus condiciones.',
      );
    }
  }

  // REGISTRO UNICO - Si la respuesta trae mas de un registro, las condiciones
  // no identificaban uno solo: devolver cualquiera mostraria uno equivocado.
  // Solo se puede revisar al recibir la respuesta.
  static void validarRegistroUnico(
    String tabla,
    List<Map<String, dynamic>> registros,
  ) {
    if (registros.length > 1) {
      throw StateError(
        'obtenerUno encontro mas de un registro en $tabla: '
        'las condiciones no identifican un registro unico.',
      );
    }
  }
}
