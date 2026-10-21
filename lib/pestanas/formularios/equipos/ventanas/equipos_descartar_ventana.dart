/// Responsabilidad: Preguntar si se descartan los cambios sin guardar del
/// formulario de equipo.
library;

import 'package:flutter/widgets.dart';

import 'package:trackmape_sup/widgets2/ventanas/dialogos/dialogo_confirmacion.dart';

abstract final class EquiposDescartarVentana {
  static Future<bool> mostrar(BuildContext context) =>
      DialogoConfirmacion.mostrar(
        context,
        titulo: '¿Descartar cambios?',
        mensaje: 'Los cambios del formulario no se han guardado.',
        textoConfirmar: 'Descartar',
        textoCancelar: 'Seguir editando',
        peligro: true,
      );
}
