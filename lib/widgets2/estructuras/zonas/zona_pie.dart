/// Responsabilidad: Zona inferior de una pagina. Queda fija abajo; su
/// contenido lo decide quien la usa (accesos directos o acciones del
/// formulario).
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/tokens/bordes.dart';
import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/widgets2/soporte/acceso_tema.dart';

class ZonaPie extends StatelessWidget {
  const ZonaPie({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Espaciado.base,
        vertical: Espaciado.pequeno,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: context.colores.bordeSutil,
            width: Grosores.fino,
          ),
        ),
      ),
      child: child,
    );
  }
}
