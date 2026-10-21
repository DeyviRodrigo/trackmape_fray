import 'package:flutter/material.dart';
import 'package:trackmape_sup/app/tokens/tokens_sistema.dart';

class ContenidoOrg extends StatelessWidget {
  final Widget contenidoPrincipal;
  final Widget? opcionesSuperiores;
  final Widget? barraEstado;

  const ContenidoOrg({
    super.key,
    required this.contenidoPrincipal,
    this.opcionesSuperiores,
    this.barraEstado,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ColoresApp.fondoSecundario,
      child: Column(
        children: [
          if (opcionesSuperiores != null) opcionesSuperiores!,
          Expanded(child: contenidoPrincipal),
          if (barraEstado != null) barraEstado!,
        ],
      ),
    );
  }
}
