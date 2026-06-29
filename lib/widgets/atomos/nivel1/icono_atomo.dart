import 'package:flutter/material.dart';
import 'package:trackmape_sup/app/tokens/tokens_sistema.dart';

enum ContextoIcono { normal, activo, tenue, peligro }

class IconoAtomo extends StatelessWidget {
  final IconData icono;
  final ContextoIcono contexto;
  final double tamano;

  const IconoAtomo({
    super.key,
    required this.icono,
    this.contexto = ContextoIcono.normal,
    this.tamano = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(icono, size: tamano, color: _color);
  }

  Color get _color {
    return switch (contexto) {
      ContextoIcono.activo => ColoresApp.marcaPrimaria,
      ContextoIcono.tenue => ColoresApp.textoTenue,
      ContextoIcono.peligro => ColoresApp.error,
      ContextoIcono.normal => ColoresApp.textoSecundario,
    };
  }
}
