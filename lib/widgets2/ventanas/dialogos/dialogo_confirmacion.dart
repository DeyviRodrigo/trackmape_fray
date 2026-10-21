/// Responsabilidad: Preguntar al usuario si confirma una accion. Devuelve
/// `true` solo si pulsa confirmar.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/tokens/tamanos.dart';
import 'package:trackmape_sup/widgets2/primitivas/acciones/boton.dart';
import 'package:trackmape_sup/widgets2/primitivas/acciones/variante_boton.dart';

abstract final class DialogoConfirmacion {
  static Future<bool> mostrar(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    required String textoConfirmar,
    String textoCancelar = 'Cancelar',
    bool peligro = false,
  }) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        constraints: const BoxConstraints(maxWidth: TamanosSuperficie.dialogo),
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          Boton(
            texto: textoCancelar,
            variante: VarianteBoton.texto,
            alPulsar: () => Navigator.of(context).pop(false),
          ),
          Boton(
            texto: textoConfirmar,
            variante: peligro ? VarianteBoton.peligro : VarianteBoton.primario,
            alPulsar: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return confirmado ?? false;
  }
}
