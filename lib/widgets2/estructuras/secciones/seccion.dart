/// Responsabilidad: Agrupar contenido relacionado bajo un titulo dentro del
/// contenido de una pagina ("Datos del equipo", "Rendimiento del dia").
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/temas/textos_app.dart';
import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/widgets2/soporte/acceso_tema.dart';

class Seccion extends StatelessWidget {
  const Seccion({
    super.key,
    required this.titulo,
    required this.child,
    this.acciones = const [],
  });

  final String titulo;
  final Widget child;

  /// Por ejemplo "agregar" en una seccion hija.
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Espaciado.amplio),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Espaciado.pequeno,
        children: [
          Row(
            children: [
              Expanded(child: Text(titulo, style: context.textos.subtitulo)),
              ...acciones,
            ],
          ),
          child,
        ],
      ),
    );
  }
}
