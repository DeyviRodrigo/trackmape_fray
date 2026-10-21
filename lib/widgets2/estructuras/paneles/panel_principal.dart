/// Responsabilidad: Panel con el contenido funcional activo (normalmente el
/// listado). En vertical recibe tambien el control de apertura del menu y la
/// hoja abierta, y los pone encima en ese orden.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/widgets2/soporte/acceso_tema.dart';

class PanelPrincipal extends StatelessWidget {
  const PanelPrincipal({
    super.key,
    required this.pagina,
    this.controlApertura,
    this.hojaSuperpuesta,
  });

  final Widget pagina;

  /// Solo en vertical. Queda debajo de la hoja: al abrirla, la tapa.
  final Widget? controlApertura;

  /// Solo en vertical. La pagina sigue debajo y conserva su estado.
  final Widget? hojaSuperpuesta;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: pagina),
        if (controlApertura case final control?)
          Positioned(
            left: Espaciado.minimo,
            top: Espaciado.minimo,
            child: control,
          ),
        if (hojaSuperpuesta case final hoja?)
          Positioned.fill(
            child: ColoredBox(color: context.colores.fondoLienzo, child: hoja),
          ),
      ],
    );
  }
}
