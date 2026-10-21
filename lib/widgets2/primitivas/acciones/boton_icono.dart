/// Responsabilidad: Boton de solo icono. La ayuda es obligatoria: es lo unico
/// que explica que hace el boton.
library;

import 'package:flutter/material.dart';

class BotonIcono extends StatelessWidget {
  const BotonIcono({
    super.key,
    required this.icono,
    required this.ayuda,
    required this.alPulsar,
  });

  final IconData icono;
  final String ayuda;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    return IconButton(tooltip: ayuda, icon: Icon(icono), onPressed: alPulsar);
  }
}
