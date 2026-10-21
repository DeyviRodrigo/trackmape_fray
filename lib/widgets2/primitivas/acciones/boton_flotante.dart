/// Responsabilidad: Boton flotante de solo icono con ayuda, para las acciones
/// flotantes del listado (por ejemplo Agregar).
library;

import 'package:flutter/material.dart';

class BotonFlotante extends StatelessWidget {
  const BotonFlotante({
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
    return FloatingActionButton(
      // Sin animacion compartida: puede haber varios en la misma pantalla.
      heroTag: null,
      tooltip: ayuda,
      onPressed: alPulsar,
      child: Icon(icono),
    );
  }
}
