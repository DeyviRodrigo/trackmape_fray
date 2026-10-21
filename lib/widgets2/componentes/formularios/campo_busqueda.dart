/// Responsabilidad: Campo de busqueda con lupa y boton para borrar. Avisa
/// cada cambio de texto; no filtra nada por si mismo.
library;

import 'package:flutter/material.dart';

class CampoBusqueda extends StatefulWidget {
  const CampoBusqueda({
    super.key,
    required this.pista,
    required this.alCambiar,
  });

  final String pista;
  final ValueChanged<String> alCambiar;

  @override
  State<CampoBusqueda> createState() => _CampoBusquedaState();
}

class _CampoBusquedaState extends State<CampoBusqueda> {
  final _controlador = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _borrar() {
    _controlador.clear();
    widget.alCambiar('');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _controlador,
      builder: (context, valor, _) => TextField(
        controller: _controlador,
        onChanged: widget.alCambiar,
        decoration: InputDecoration(
          hintText: widget.pista,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: valor.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Borrar búsqueda',
                  icon: const Icon(Icons.close),
                  onPressed: _borrar,
                ),
        ),
      ),
    );
  }
}
