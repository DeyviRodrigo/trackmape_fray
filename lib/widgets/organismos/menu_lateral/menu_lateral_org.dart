import 'package:flutter/material.dart';
import 'package:trackmape_sup/app/tokens/tokens_sistema.dart';

class MenuLateralOrg extends StatelessWidget {
  final Widget encabezado;
  final Widget formularios;
  final Widget informes;
  final Widget configuraciones;
  final Widget sesion;

  const MenuLateralOrg({
    super.key,
    required this.encabezado,
    required this.formularios,
    required this.informes,
    required this.configuraciones,
    required this.sesion,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ColoresApp.fondoPrimario,
      child: SafeArea(
        child: Column(
          children: [
            encabezado,
            const Divider(height: 1, color: ColoresApp.divisor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: Espaciado.pequeno,
                ),
                child: Column(
                  children: [formularios, informes, configuraciones],
                ),
              ),
            ),
            const Divider(height: 1, color: ColoresApp.divisor),
            sesion,
          ],
        ),
      ),
    );
  }
}
