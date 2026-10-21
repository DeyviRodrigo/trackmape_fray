/// Responsabilidad: Etiqueta corta coloreada segun un [TonoEstado]
/// (por ejemplo "Vigente" o "Sin senal").
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/temas/textos_app.dart';
import 'package:trackmape_sup/recursos2/temas/tono_estado.dart';
import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/recursos2/tokens/radios.dart';
import 'package:trackmape_sup/widgets2/soporte/acceso_tema.dart';

class InsigniaEstado extends StatelessWidget {
  const InsigniaEstado({
    super.key,
    required this.texto,
    this.tono = TonoEstado.neutro,
  });

  final String texto;
  final TonoEstado tono;

  @override
  Widget build(BuildContext context) {
    final colores = tono.colores(context.colores);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Espaciado.pequeno,
        vertical: Espaciado.micro,
      ),
      decoration: BoxDecoration(
        color: colores.contenedor,
        borderRadius: RadiosBorde.minimo,
      ),
      child: Text(
        texto,
        style: context.textos.etiquetaPequena.copyWith(
          color: colores.sobreContenedor,
        ),
      ),
    );
  }
}
