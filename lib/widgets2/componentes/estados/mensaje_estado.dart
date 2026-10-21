/// Responsabilidad: Mensaje centrado dentro de la pagina para cargando, sin
/// resultados o error, con una accion opcional (por ejemplo Reintentar).
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/temas/textos_app.dart';
import 'package:trackmape_sup/recursos2/temas/tono_estado.dart';
import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/recursos2/tokens/tamanos.dart';
import 'package:trackmape_sup/widgets2/soporte/acceso_tema.dart';

class MensajeEstado extends StatelessWidget {
  const MensajeEstado({
    super.key,
    required this.titulo,
    this.descripcion,
    this.tono = TonoEstado.neutro,
    this.accion,
  }) : cargando = false;

  const MensajeEstado.cargando({super.key, this.titulo = 'Cargando…'})
    : descripcion = null,
      tono = TonoEstado.neutro,
      accion = null,
      cargando = true;

  final String titulo;
  final String? descripcion;
  final TonoEstado tono;
  final Widget? accion;
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final descripcion = this.descripcion;
    final accion = this.accion;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.amplio),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: Espaciado.pequeno,
          children: [
            if (cargando)
              const SizedBox.square(
                dimension: TamanosIcono.grande,
                child: CircularProgressIndicator(),
              )
            else
              Icon(
                tono.icono,
                size: TamanosIcono.enorme,
                color: tono == TonoEstado.neutro
                    ? c.textoTerciario
                    : tono.colores(c).base,
              ),
            Text(
              titulo,
              style: context.textos.subtitulo,
              textAlign: TextAlign.center,
            ),
            if (descripcion != null)
              Text(
                descripcion,
                style: context.textos.cuerpo.copyWith(
                  color: c.textoSecundario,
                ),
                textAlign: TextAlign.center,
              ),
            if (accion != null) ...[
              const SizedBox(height: Espaciado.pequeno),
              accion,
            ],
          ],
        ),
      ),
    );
  }
}
