/// Responsabilidad: Zona superior de una pagina. Solo tiene dos subzonas:
/// titulo a la izquierda y acciones del encabezado a la derecha.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/temas/textos_app.dart';
import 'package:trackmape_sup/recursos2/tokens/bordes.dart';
import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/recursos2/tokens/tamanos.dart';
import 'package:trackmape_sup/widgets2/soporte/acceso_tema.dart';

class ZonaEncabezado extends StatelessWidget {
  const ZonaEncabezado({
    super.key,
    required this.titulo,
    this.acciones = const [],
  });

  final String titulo;

  /// Incluye el cierre de detalle y formulario. Sin acciones, la subzona no
  /// ocupa espacio.
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    return Container(
      // La altura no depende de si hay acciones: todos los encabezados quedan
      // alineados aunque uno tenga botones y el de al lado no.
      constraints: const BoxConstraints(
        minHeight: TamanosControl.alturaBase + Espaciado.pequeno * 2,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Espaciado.base,
        vertical: Espaciado.pequeno,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colores.bordeSutil,
            width: Grosores.fino,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: context.textos.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (acciones.isNotEmpty) ...[
            const SizedBox(width: Espaciado.pequeno),
            Row(mainAxisSize: MainAxisSize.min, children: acciones),
          ],
        ],
      ),
    );
  }
}
