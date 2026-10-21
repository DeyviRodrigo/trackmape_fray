/// Responsabilidad: Mostrar pantallas de la version anterior dentro del
/// esquema nuevo, con su tema de siempre, mientras no se migran. Si el modulo
/// junta varias, las separa en pestanas.
///
/// Temporal: se borra cuando el ultimo modulo este migrado.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/app/tokens/tokens_sistema.dart';
import 'package:trackmape_sup/widgets2/estructuras/esquemas/esquema_central.dart';
import 'package:trackmape_sup/widgets2/estructuras/zonas/zona_encabezado.dart';

class PantallaAnterior {
  const PantallaAnterior({required this.titulo, required this.pagina});

  final String titulo;
  final Widget pagina;
}

class ContenidoAnterior extends StatelessWidget {
  const ContenidoAnterior({
    super.key,
    required this.titulo,
    required this.pantallas,
  });

  final String titulo;
  final List<PantallaAnterior> pantallas;

  @override
  Widget build(BuildContext context) {
    return EsquemaCentral(
      principal: DefaultTabController(
        length: pantallas.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ZonaEncabezado(titulo: titulo),
            if (pantallas.length > 1)
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  for (final pantalla in pantallas) Tab(text: pantalla.titulo),
                ],
              ),
            Expanded(
              child: Theme(
                data: TemaBase.oscuro(),
                child: pantallas.length == 1
                    ? pantallas.single.pagina
                    : TabBarView(
                        // Sin deslizar: chocaria con los mapas.
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (final pantalla in pantallas) pantalla.pagina,
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
