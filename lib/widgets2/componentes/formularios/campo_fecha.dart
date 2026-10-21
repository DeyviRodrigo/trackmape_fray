/// Responsabilidad: Campo que muestra una fecha (dd/mm/aaaa) y abre el
/// selector de fecha al tocarlo.
library;

import 'package:flutter/material.dart';

class CampoFecha extends StatelessWidget {
  const CampoFecha({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.alCambiar,
    required this.primera,
    required this.ultima,
    this.error,
    this.habilitado = true,
  });

  final String etiqueta;
  final DateTime? valor;
  final ValueChanged<DateTime> alCambiar;

  /// Rango que permite el selector.
  final DateTime primera;
  final DateTime ultima;
  final String? error;
  final bool habilitado;

  Future<void> _elegir(BuildContext context) async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: valor ?? DateTime.now(),
      firstDate: primera,
      lastDate: ultima,
    );
    if (elegida != null) alCambiar(elegida);
  }

  static String _formatear(DateTime fecha) {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final valor = this.valor;
    return InkWell(
      onTap: habilitado ? () => _elegir(context) : null,
      child: InputDecorator(
        isEmpty: valor == null,
        decoration: InputDecoration(
          labelText: etiqueta,
          errorText: error,
          enabled: habilitado,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(valor == null ? '' : _formatear(valor)),
      ),
    );
  }
}
