/// Responsabilidad: Superficie con fondo, borde sutil y esquinas redondeadas
/// que contiene otro widget.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/tokens/bordes.dart';
import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/recursos2/tokens/radios.dart';
import 'package:trackmape_sup/widgets2/soporte/acceso_tema.dart';

class Tarjeta extends StatelessWidget {
  const Tarjeta({
    super.key,
    required this.child,
    this.relleno = const EdgeInsets.all(Espaciado.base),
  });

  final Widget child;
  final EdgeInsetsGeometry relleno;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      padding: relleno,
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: RadiosBorde.medio,
        border: Border.all(color: c.bordeSutil, width: Grosores.fino),
      ),
      child: child,
    );
  }
}
