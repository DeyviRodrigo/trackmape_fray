/// Responsabilidad: Boton que muestra el filtro elegido ("Tipo: Volquete") y
/// abre un menu para cambiarlo. La primera opcion, "Todos", quita el filtro.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/tokens/tamanos.dart';

class FiltroOpciones<T> extends StatelessWidget {
  const FiltroOpciones({
    super.key,
    required this.etiqueta,
    required this.opciones,
    required this.etiquetar,
    required this.seleccionada,
    required this.alElegir,
  });

  final String etiqueta;
  final List<T> opciones;
  final String Function(T opcion) etiquetar;

  /// `null` = sin filtro (Todos).
  final T? seleccionada;
  final ValueChanged<T?> alElegir;

  @override
  Widget build(BuildContext context) {
    final elegida = seleccionada;
    final texto = elegida == null
        ? etiqueta
        : '$etiqueta: ${etiquetar(elegida)}';

    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () => alElegir(null),
          child: const Text('Todos'),
        ),
        for (final opcion in opciones)
          MenuItemButton(
            onPressed: () => alElegir(opcion),
            child: Text(etiquetar(opcion)),
          ),
      ],
      builder: (context, menu, _) => OutlinedButton.icon(
        onPressed: () => menu.isOpen ? menu.close() : menu.open(),
        icon: const Icon(Icons.arrow_drop_down, size: TamanosIcono.medio),
        iconAlignment: IconAlignment.end,
        label: Text(texto),
      ),
    );
  }
}
