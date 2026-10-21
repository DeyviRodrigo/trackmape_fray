import 'package:flutter/material.dart';
import 'package:trackmape_sup/app/tokens/tokens_sistema.dart';

enum ContextoTexto { titulo, subtitulo, cuerpo, activo, secundario, peligro }

class TextoAtomo extends StatelessWidget {
  final String texto;
  final ContextoTexto contexto;
  final int? maxLineas;
  final TextOverflow overflow;
  final TextAlign? alineacion;

  const TextoAtomo({
    super.key,
    required this.texto,
    this.contexto = ContextoTexto.cuerpo,
    this.maxLineas,
    this.overflow = TextOverflow.ellipsis,
    this.alineacion,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      maxLines: maxLineas,
      overflow: overflow,
      textAlign: alineacion,
      style: _estilo,
    );
  }

  TextStyle get _estilo {
    return switch (contexto) {
      ContextoTexto.titulo => const TextStyle(
        color: ColoresApp.textoPrimario,
        fontWeight: FontWeight.w800,
        fontSize: 18,
      ),
      ContextoTexto.subtitulo => const TextStyle(
        color: ColoresApp.textoPrimario,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      ContextoTexto.activo => const TextStyle(
        color: ColoresApp.marcaPrimaria,
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
      ContextoTexto.secundario => const TextStyle(
        color: ColoresApp.textoTenue,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      ContextoTexto.peligro => const TextStyle(
        color: ColoresApp.error,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      ContextoTexto.cuerpo => const TextStyle(
        color: ColoresApp.textoSecundario,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    };
  }
}
