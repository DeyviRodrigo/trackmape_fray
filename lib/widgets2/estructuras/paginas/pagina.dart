/// Responsabilidad: Acomodar las tres zonas de una pagina: encabezado arriba,
/// contenido en el espacio sobrante y pie abajo. Una zona que no se pasa
/// desaparece sin dejar hueco.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/widgets2/estructuras/zonas/zona_contenido.dart';
import 'package:trackmape_sup/widgets2/estructuras/zonas/zona_encabezado.dart';
import 'package:trackmape_sup/widgets2/estructuras/zonas/zona_pie.dart';

class Pagina extends StatelessWidget {
  const Pagina({
    super.key,
    this.encabezado,
    required this.contenido,
    this.pie,
  });

  final ZonaEncabezado? encabezado;
  final ZonaContenido contenido;
  final ZonaPie? pie;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ?encabezado,
        Expanded(child: contenido),
        ?pie,
      ],
    );
  }
}
