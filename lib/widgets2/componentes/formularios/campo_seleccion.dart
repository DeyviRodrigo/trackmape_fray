/// Responsabilidad: Campo para elegir un valor de una lista (empresa, sede,
/// tipo), con etiqueta y mensaje de error como los demas campos.
library;

import 'package:flutter/material.dart';

class CampoSeleccion<T> extends StatelessWidget {
  const CampoSeleccion({
    super.key,
    required this.etiqueta,
    required this.opciones,
    required this.etiquetar,
    required this.valor,
    required this.alCambiar,
    this.error,
    this.habilitado = true,
  });

  final String etiqueta;
  final List<T> opciones;
  final String Function(T opcion) etiquetar;
  final T? valor;
  final ValueChanged<T?> alCambiar;
  final String? error;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      isEmpty: valor == null,
      decoration: InputDecoration(
        labelText: etiqueta,
        errorText: error,
        enabled: habilitado,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: valor,
          isDense: true,
          isExpanded: true,
          onChanged: habilitado ? alCambiar : null,
          items: [
            for (final opcion in opciones)
              DropdownMenuItem(value: opcion, child: Text(etiquetar(opcion))),
          ],
        ),
      ),
    );
  }
}
