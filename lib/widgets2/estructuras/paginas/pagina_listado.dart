/// Responsabilidad: Pagina de listado. Ordena las cuatro subzonas dentro del
/// contenido: acciones superiores, visualizacion, acciones flotantes (encima
/// de la visualizacion) y barra de estado.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/widgets2/estructuras/paginas/pagina.dart';
import 'package:trackmape_sup/widgets2/estructuras/subzonas/subzona_acciones_flotantes.dart';
import 'package:trackmape_sup/widgets2/estructuras/subzonas/subzona_acciones_superiores.dart';
import 'package:trackmape_sup/widgets2/estructuras/subzonas/subzona_barra_estado.dart';
import 'package:trackmape_sup/widgets2/estructuras/subzonas/subzona_visualizacion.dart';
import 'package:trackmape_sup/widgets2/estructuras/zonas/zona_contenido.dart';
import 'package:trackmape_sup/widgets2/estructuras/zonas/zona_encabezado.dart';
import 'package:trackmape_sup/widgets2/estructuras/zonas/zona_pie.dart';

class PaginaListado extends StatelessWidget {
  const PaginaListado({
    super.key,
    this.encabezado,
    this.accionesSuperiores,
    required this.visualizacion,
    this.accionesFlotantes,
    this.barraEstado,
    this.pie,
  });

  final ZonaEncabezado? encabezado;
  final SubzonaAccionesSuperiores? accionesSuperiores;
  final SubzonaVisualizacion visualizacion;
  final SubzonaAccionesFlotantes? accionesFlotantes;
  final SubzonaBarraEstado? barraEstado;

  /// Solo en vertical (accesos directos).
  final ZonaPie? pie;

  @override
  Widget build(BuildContext context) {
    return Pagina(
      encabezado: encabezado,
      contenido: ZonaContenido(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Espaciado.medio,
          children: [
            ?accionesSuperiores,
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: visualizacion),
                  if (accionesFlotantes case final flotantes?)
                    Positioned(
                      right: Espaciado.base,
                      bottom: Espaciado.base,
                      child: flotantes,
                    ),
                ],
              ),
            ),
            ?barraEstado,
          ],
        ),
      ),
      pie: pie,
    );
  }
}
