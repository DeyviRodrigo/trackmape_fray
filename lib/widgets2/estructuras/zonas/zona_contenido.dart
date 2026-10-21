/// Responsabilidad: Zona principal de una pagina. Ocupa el espacio que dejan
/// encabezado y pie.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';

class ZonaContenido extends StatelessWidget {
  const ZonaContenido({
    super.key,
    required this.child,
    this.desplazable = false,
  });

  final Widget child;

  /// `true` en detalle y formulario: toda la zona se desplaza. `false` en el
  /// listado: se desplaza solo la visualizacion y la barra de estado queda fija.
  final bool desplazable;

  @override
  Widget build(BuildContext context) {
    const relleno = EdgeInsets.all(Espaciado.base);

    if (desplazable) {
      return SingleChildScrollView(padding: relleno, child: child);
    }
    return Padding(padding: relleno, child: child);
  }
}
