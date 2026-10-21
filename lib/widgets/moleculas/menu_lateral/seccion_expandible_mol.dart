import 'package:flutter/material.dart';
import 'package:trackmape_sup/app/tokens/tokens_sistema.dart';
import 'package:trackmape_sup/widgets/atomos/nivel1/icono_atomo.dart';
import 'package:trackmape_sup/widgets/atomos/nivel1/texto_atomo.dart';

class SeccionExpandibleMol extends StatefulWidget {
  final String titulo;
  final IconData icono;
  final List<Widget> items;
  final bool inicialmenteExpandido;

  const SeccionExpandibleMol({
    super.key,
    required this.titulo,
    required this.icono,
    required this.items,
    this.inicialmenteExpandido = true,
  });

  @override
  State<SeccionExpandibleMol> createState() => _SeccionExpandibleMolState();
}

class _SeccionExpandibleMolState extends State<SeccionExpandibleMol> {
  late bool _expandido;

  @override
  void initState() {
    super.initState();
    _expandido = widget.inicialmenteExpandido;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Espaciado.pequeno),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _expandido = !_expandido),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Espaciado.medio,
                vertical: Espaciado.pequeno,
              ),
              child: Row(
                children: [
                  IconoAtomo(
                    icono: widget.icono,
                    contexto: ContextoIcono.activo,
                    tamano: 18,
                  ),
                  const SizedBox(width: Espaciado.pequeno),
                  Expanded(
                    child: TextoAtomo(
                      texto: widget.titulo.toUpperCase(),
                      contexto: ContextoTexto.activo,
                    ),
                  ),
                  IconoAtomo(
                    icono: _expandido ? Iconos.contraer : Iconos.expandir,
                    contexto: ContextoIcono.tenue,
                  ),
                ],
              ),
            ),
          ),
          if (_expandido) ...widget.items,
        ],
      ),
    );
  }
}
