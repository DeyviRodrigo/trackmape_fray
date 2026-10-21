/// Responsabilidad: Panel con la hoja abierta (detalle o formulario). Solo
/// existe en horizontal, al lado del panel principal.
library;

import 'package:flutter/material.dart';

class PanelSecundario extends StatelessWidget {
  const PanelSecundario({super.key, required this.hoja});

  final Widget hoja;

  @override
  Widget build(BuildContext context) => hoja;
}
