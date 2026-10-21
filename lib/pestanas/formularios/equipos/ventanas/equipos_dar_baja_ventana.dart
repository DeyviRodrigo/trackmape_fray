/// Responsabilidad: Confirmar que se quiere dar de baja un equipo.
library;

import 'package:flutter/widgets.dart';

import 'package:trackmape_sup/widgets2/ventanas/dialogos/dialogo_confirmacion.dart';

abstract final class EquiposDarBajaVentana {
  static Future<bool> mostrar(BuildContext context, String nombre) =>
      DialogoConfirmacion.mostrar(
        context,
        titulo: '¿Dar de baja $nombre?',
        mensaje:
            'El equipo quedará como finalizado desde hoy. Su historial se '
            'conserva.',
        textoConfirmar: 'Dar de baja',
        peligro: true,
      );
}
