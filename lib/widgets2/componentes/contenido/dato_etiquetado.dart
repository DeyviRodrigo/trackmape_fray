/// Responsabilidad: Mostrar un dato con su nombre ("Codigo: ABC-123"). Sin
/// valor muestra un guion.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/temas/textos_app.dart';
import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/widgets2/soporte/acceso_tema.dart';

class DatoEtiquetado extends StatelessWidget {
  const DatoEtiquetado({super.key, required this.etiqueta, this.valor});

  final String etiqueta;
  final String? valor;

  @override
  Widget build(BuildContext context) {
    final valor = this.valor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Espaciado.minimo),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Espaciado.medio,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              etiqueta,
              style: context.textos.cuerpo.copyWith(
                color: context.colores.textoSecundario,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valor == null || valor.isEmpty ? '—' : valor,
              style: context.textos.cuerpo,
            ),
          ),
        ],
      ),
    );
  }
}
