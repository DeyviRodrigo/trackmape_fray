/// Responsabilidad: Mostrar un aviso temporal abajo de la pantalla
/// ("Equipo guardado"), con el icono de su [TonoEstado].
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/temas/tono_estado.dart';
import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/recursos2/tokens/tamanos.dart';
import 'package:trackmape_sup/widgets2/soporte/acceso_tema.dart';

abstract final class Aviso {
  static void mostrar(
    BuildContext context,
    String mensaje, {
    TonoEstado tono = TonoEstado.exito,
  }) {
    final c = context.colores;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            spacing: Espaciado.pequeno,
            children: [
              Icon(
                tono.icono,
                size: TamanosIcono.medio,
                color: tono == TonoEstado.neutro
                    ? c.textoInverso
                    : tono.colores(c).base,
              ),
              Expanded(child: Text(mensaje)),
            ],
          ),
        ),
      );
  }
}
