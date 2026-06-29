import 'package:flutter/material.dart';
import 'package:trackmape_sup/app/tokens/tokens_sistema.dart';
import 'package:trackmape_sup/widgets/atomos/nivel1/icono_atomo.dart';
import 'package:trackmape_sup/widgets/atomos/nivel1/texto_atomo.dart';

class SeccionSuperiorMol extends StatelessWidget {
  final String titulo;
  final String subtitulo;

  const SeccionSuperiorMol({
    super.key,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ColoresApp.fondoPrimario,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Espaciado.medio,
          Espaciado.grande,
          Espaciado.medio,
          Espaciado.medio,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ColoresApp.marcaPrimaria.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(Radios.grande),
                border: Border.all(color: ColoresApp.marcaPrimaria),
              ),
              child: const IconoAtomo(
                icono: Iconos.mapa,
                contexto: ContextoIcono.activo,
              ),
            ),
            const SizedBox(width: Espaciado.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextoAtomo(texto: titulo, contexto: ContextoTexto.titulo),
                  const SizedBox(height: Espaciado.minimo),
                  TextoAtomo(
                    texto: subtitulo,
                    contexto: ContextoTexto.secundario,
                    maxLineas: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
