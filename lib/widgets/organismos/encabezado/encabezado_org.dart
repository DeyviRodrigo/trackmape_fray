import 'package:flutter/material.dart';
import 'package:trackmape_sup/app/tokens/tokens_sistema.dart';

class EncabezadoOrg extends StatelessWidget implements PreferredSizeWidget {
  final Widget? izquierda;
  final Widget centro;
  final Widget? derecha;

  const EncabezadoOrg({
    super.key,
    this.izquierda,
    required this.centro,
    this.derecha,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: Espaciado.medio),
      decoration: const BoxDecoration(
        color: ColoresApp.fondoPrimario,
        border: Border(
          bottom: BorderSide(color: ColoresApp.divisor, width: Grosores.fino),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (izquierda != null) ...[
              izquierda!,
              const SizedBox(width: Espaciado.pequeno),
            ],
            Expanded(child: centro),
            if (derecha != null) ...[
              const SizedBox(width: Espaciado.pequeno),
              derecha!,
            ],
          ],
        ),
      ),
    );
  }
}
