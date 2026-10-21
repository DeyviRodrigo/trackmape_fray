/// Responsabilidad: Resolver fondo, contenido y borde de cada variante de botón,
/// incluido su estado deshabilitado.
library;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

import 'package:trackmape_sup/recursos2/tokens/paleta.dart';
import 'package:trackmape_sup/recursos2/temas/colores_app.dart';

enum VarianteBoton { primario, secundario, contorno, texto, peligro }

@immutable
final class ColoresBoton {
  const ColoresBoton({
    required this.fondo,
    required this.contenido,
    required this.borde,
  });

  final Color fondo;
  final Color contenido; // texto e icono
  final Color borde;
}

extension VarianteBotonColores on VarianteBoton {
  bool get _sinFondo =>
      this == VarianteBoton.contorno || this == VarianteBoton.texto;

  ColoresBoton colores(ColoresApp c, {bool habilitado = true}) {
    if (!habilitado) {
      return ColoresBoton(
        fondo: _sinFondo ? Paleta.transparente : c.fondoDeshabilitado,
        contenido: c.textoDeshabilitado,
        borde: this == VarianteBoton.contorno
            ? c.bordeSutil
            : Paleta.transparente,
      );
    }
    return switch (this) {
      VarianteBoton.primario => ColoresBoton(
        fondo: c.primario,
        contenido: c.sobrePrimario,
        borde: Paleta.transparente,
      ),
      VarianteBoton.secundario => ColoresBoton(
        fondo: c.primarioContenedor,
        contenido: c.sobrePrimarioContenedor,
        borde: Paleta.transparente,
      ),
      VarianteBoton.contorno => ColoresBoton(
        fondo: Paleta.transparente,
        contenido: c.textoPrimario,
        borde: c.borde,
      ),
      VarianteBoton.texto => ColoresBoton(
        fondo: Paleta.transparente,
        contenido: c.primario,
        borde: Paleta.transparente,
      ),
      VarianteBoton.peligro => ColoresBoton(
        fondo: c.error.base,
        contenido: c.error.sobreBase,
        borde: Paleta.transparente,
      ),
    };
  }
}
