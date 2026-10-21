/// Responsabilidad: Configurar la aplicacion completa (titulo, tema,
/// desplazamiento y rutas). Es el widget raiz que recibe runApp.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:trackmape_sup/app/tokens/tokens_sistema.dart';
import 'package:trackmape_sup/app2/rutas/enrutador_app.dart';

class AplicacionTrackMAPE extends StatelessWidget {
  const AplicacionTrackMAPE({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TrackMAPE',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _TrackScrollBehavior(),
      theme: TemaBase.oscuro(),
      routerConfig: enrutadorApp,
    );
  }
}

class _TrackScrollBehavior extends MaterialScrollBehavior {
  const _TrackScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}
