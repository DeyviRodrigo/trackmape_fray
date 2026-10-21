/// Responsabilidad: Campo de texto con etiqueta, ayuda y mensaje de error.
/// No valida: el error lo decide quien lo usa.
library;

import 'package:flutter/material.dart';

class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.etiqueta,
    required this.controlador,
    this.ayuda,
    this.error,
    this.habilitado = true,
    this.lineas = 1,
    this.tipoTeclado,
    this.alCambiar,
  });

  final String etiqueta;
  final TextEditingController controlador;
  final String? ayuda;
  final String? error;
  final bool habilitado;
  final int lineas;
  final TextInputType? tipoTeclado;
  final ValueChanged<String>? alCambiar;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controlador,
      enabled: habilitado,
      minLines: lineas,
      maxLines: lineas,
      keyboardType: tipoTeclado,
      onChanged: alCambiar,
      decoration: InputDecoration(
        labelText: etiqueta,
        helperText: ayuda,
        errorText: error,
      ),
    );
  }
}
