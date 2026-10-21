import 'package:flutter/material.dart';
import 'package:trackmape_sup/app/tokens/tokens_sistema.dart';
import 'package:trackmape_sup/widgets/atomos/nivel1/icono_atomo.dart';
import 'package:trackmape_sup/widgets/atomos/nivel1/texto_atomo.dart';

class ItemMenuAtomo extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final VoidCallback? onTap;
  final bool activo;
  final Color? color;

  const ItemMenuAtomo({
    super.key,
    required this.icono,
    required this.etiqueta,
    this.onTap,
    this.activo = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorBase = color ?? ColoresApp.textoSecundario;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Espaciado.pequeno),
      child: Material(
        color: activo
            ? ColoresApp.marcaPrimaria.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(Radios.grande),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radios.grande),
          child: Container(
            constraints: const BoxConstraints(minHeight: 42),
            padding: const EdgeInsets.symmetric(
              horizontal: Espaciado.base,
              vertical: Espaciado.pequeno,
            ),
            child: Row(
              children: [
                if (activo)
                  Container(
                    width: 4,
                    height: 22,
                    margin: const EdgeInsets.only(right: Espaciado.pequeno),
                    decoration: BoxDecoration(
                      color: ColoresApp.marcaPrimaria,
                      borderRadius: BorderRadius.circular(Radios.completo),
                    ),
                  ),
                IconoAtomo(
                  icono: icono,
                  contexto: activo
                      ? ContextoIcono.activo
                      : ContextoIcono.normal,
                ),
                const SizedBox(width: Espaciado.base),
                Expanded(
                  child: TextoAtomo(
                    texto: etiqueta,
                    contexto: activo
                        ? ContextoTexto.activo
                        : ContextoTexto.cuerpo,
                  ),
                ),
                if (!activo && color != null)
                  Icon(Icons.circle, size: 6, color: colorBase),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
