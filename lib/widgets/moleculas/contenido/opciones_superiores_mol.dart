import 'package:flutter/material.dart';
import 'package:trackmape_sup/app/tokens/tokens_sistema.dart';
import 'package:trackmape_sup/widgets/atomos/nivel1/texto_atomo.dart';

class OpcionesSuperioresMol extends StatelessWidget {
  final String titulo;
  final Widget contenido;

  const OpcionesSuperioresMol({
    super.key,
    required this.titulo,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Espaciado.medio),
      decoration: const BoxDecoration(
        color: ColoresApp.fondoTerciario,
        border: Border(
          bottom: BorderSide(color: ColoresApp.divisor, width: Grosores.fino),
        ),
      ),
      child: Wrap(
        spacing: Espaciado.medio,
        runSpacing: Espaciado.pequeno,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 170,
            child: TextoAtomo(texto: titulo, contexto: ContextoTexto.subtitulo),
          ),
          contenido,
        ],
      ),
    );
  }
}
