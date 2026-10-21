/// Responsabilidad: Acomodar los paneles de la pantalla segun el ancho.
/// Horizontal: navegacion | principal | secundario, uno al lado del otro, sin
/// taparse. Vertical: solo el principal, con el control de apertura del menu y
/// la hoja encima; el menu desplegado aparece sobre todo.
///
/// No maneja la pila de hojas: recibe la hoja que se ve ahora, o ninguna. El
/// panel de navegacion lo toma de [NavegacionEsquema], si existe.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/tokens/bordes.dart';
import 'package:trackmape_sup/recursos2/tokens/tamanos.dart';
import 'package:trackmape_sup/widgets2/estructuras/esquemas/navegacion_esquema.dart';
import 'package:trackmape_sup/widgets2/estructuras/paneles/panel_principal.dart';
import 'package:trackmape_sup/widgets2/estructuras/paneles/panel_secundario.dart';
import 'package:trackmape_sup/widgets2/primitivas/acciones/boton_icono.dart';
import 'package:trackmape_sup/widgets2/soporte/acceso_tema.dart';

class EsquemaCentral extends StatelessWidget {
  const EsquemaCentral({
    super.key,
    required this.principal,
    this.hoja,
    this.umbralHorizontal = TamanosSuperficie.umbralHorizontal,
  });

  final Widget principal;
  final Widget? hoja;

  /// Ancho desde el que se acomoda en horizontal.
  final double umbralHorizontal;

  @override
  Widget build(BuildContext context) {
    final navegacion = NavegacionEsquema.maybeOf(context);
    return LayoutBuilder(
      builder: (context, restricciones) =>
          restricciones.maxWidth >= umbralHorizontal
          ? _horizontal(navegacion)
          : _vertical(context, navegacion),
    );
  }

  // HORIZONTAL - El panel ocupa su ancho (ampliado o comprimido) y empuja el
  // contenido.
  Widget _horizontal(NavegacionEsquema? navegacion) {
    const divisor = VerticalDivider(width: Grosores.fino);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ?navegacion?.panel,
        Expanded(child: PanelPrincipal(pagina: principal)),
        if (hoja case final hojaActiva?) ...[
          divisor,
          Expanded(child: PanelSecundario(hoja: hojaActiva)),
        ],
      ],
    );
  }

  // VERTICAL - No hay espacio para empujar: el menu va encima y se pliega al
  // tocar fuera.
  Widget _vertical(BuildContext context, NavegacionEsquema? navegacion) {
    final base = PanelPrincipal(
      pagina: principal,
      controlApertura: navegacion == null
          ? null
          : BotonIcono(
              icono: Icons.menu,
              ayuda: 'Abrir menú',
              alPulsar: navegacion.alDesplegar,
            ),
      hojaSuperpuesta: hoja,
    );
    if (navegacion == null || !navegacion.desplegada) return base;
    return Stack(
      children: [
        Positioned.fill(child: base),
        Positioned.fill(
          child: GestureDetector(
            onTap: navegacion.alPlegar,
            child: ColoredBox(color: context.colores.velo),
          ),
        ),
        Positioned(left: 0, top: 0, bottom: 0, child: navegacion.panel),
      ],
    );
  }
}
