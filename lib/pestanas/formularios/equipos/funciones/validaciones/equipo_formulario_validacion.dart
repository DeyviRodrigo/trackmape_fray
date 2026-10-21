/// Responsabilidad: Evaluar cada campo del formulario de equipo. Devuelve el
/// mensaje del problema, o nulo si esta bien.
library;

import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/empresa_opcion_vista.dart';

class EquipoFormularioValidacion {
  String? empresa(EmpresaOpcionVista? valor) =>
      valor == null ? 'Elija la empresa.' : null;

  String? nombre(String valor) =>
      valor.trim().isEmpty ? 'Escriba el nombre.' : null;

  String? codigo(String valor) =>
      valor.trim().isEmpty ? 'Escriba el código.' : null;

  String? tipo(String valor) =>
      valor.trim().isEmpty ? 'Escriba el tipo de equipo.' : null;

  // MAC - Opcional; si se escribe, seis pares hexadecimales con ":" o "-".
  static final _mac = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$');

  String? direccionMac(String valor) {
    final limpio = valor.trim();
    if (limpio.isEmpty || _mac.hasMatch(limpio)) return null;
    return 'Use el formato AA:BB:CC:DD:EE:FF.';
  }
}
