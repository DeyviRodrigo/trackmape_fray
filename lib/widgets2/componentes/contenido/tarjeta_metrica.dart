/// Responsabilidad: Mostrar una metrica destacada (valor grande con su
/// nombre y unidad) dentro de una [Tarjeta].
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/temas/textos_app.dart';
import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/recursos2/tokens/tamanos.dart';
import 'package:trackmape_sup/widgets2/primitivas/superficies/tarjeta.dart';
import 'package:trackmape_sup/widgets2/soporte/acceso_tema.dart';

class TarjetaMetrica extends StatelessWidget {
  const TarjetaMetrica({
    super.key,
    required this.etiqueta,
    required this.valor,
    this.unidad,
    this.icono,
  });

  final String etiqueta;

  /// Ya formateado por quien la usa ("42", "1 h 20 min"). Sin dato: "—".
  final String valor;
  final String? unidad;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final icono = this.icono;
    final unidad = this.unidad;

    return Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Espaciado.minimo,
        children: [
          Row(
            spacing: Espaciado.minimo,
            children: [
              if (icono != null)
                Icon(icono, size: TamanosIcono.pequeno, color: c.textoTerciario),
              Expanded(
                child: Text(
                  etiqueta,
                  style: context.textos.nota.copyWith(color: c.textoSecundario),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text.rich(
            TextSpan(
              text: valor,
              style: context.textos.titulo,
              children: [
                if (unidad != null)
                  TextSpan(
                    text: ' $unidad',
                    style: context.textos.nota.copyWith(
                      color: c.textoSecundario,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
