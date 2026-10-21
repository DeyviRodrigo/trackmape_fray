/// Responsabilidad: Linea fija al final del contenido de un listado que
/// resume lo que se ve: mostrados, total, filtros activos y orden.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/temas/textos_app.dart';
import 'package:trackmape_sup/widgets2/soporte/acceso_tema.dart';

class SubzonaBarraEstado extends StatelessWidget {
  const SubzonaBarraEstado({super.key, required this.datos});

  /// Se muestran en orden, separados por " · ". Ejemplo:
  /// `['12 de 40 equipos', 'Empresa: Minera Sur', 'Por placa ↑']`.
  final List<String> datos;

  @override
  Widget build(BuildContext context) {
    return Text(
      datos.join(' · '),
      style: context.textos.nota.copyWith(
        color: context.colores.textoSecundario,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
