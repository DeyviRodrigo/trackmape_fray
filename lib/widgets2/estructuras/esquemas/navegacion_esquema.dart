/// Responsabilidad: Entregar el panel de navegacion a cualquier
/// [EsquemaCentral] de abajo, para que cada pestana no tenga que conocerlo.
///
/// Lo coloca la aplicacion una sola vez alrededor de las pestanas. En
/// horizontal el panel va al lado del contenido; en vertical solo aparece,
/// encima, cuando esta desplegado.
library;

import 'package:flutter/widgets.dart';

class NavegacionEsquema extends InheritedWidget {
  const NavegacionEsquema({
    super.key,
    required this.panel,
    required this.desplegada,
    required this.alDesplegar,
    required this.alPlegar,
    required super.child,
  });

  final Widget panel;

  /// Solo en vertical: el panel esta abierto encima del contenido.
  final bool desplegada;
  final VoidCallback alDesplegar;
  final VoidCallback alPlegar;

  static NavegacionEsquema? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NavegacionEsquema>();

  @override
  bool updateShouldNotify(NavegacionEsquema anterior) =>
      anterior.desplegada != desplegada || anterior.panel != panel;
}
