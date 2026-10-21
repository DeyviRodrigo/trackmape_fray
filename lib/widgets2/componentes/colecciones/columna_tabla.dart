/// Responsabilidad: Describir una columna de [Tabla]: su titulo, cuanto ancho
/// ocupa y como se dibuja la celda de cada fila.
library;

import 'package:flutter/widgets.dart';

class ColumnaTabla<T> {
  const ColumnaTabla({
    required this.titulo,
    required this.celda,
    this.proporcion = 1,
  });

  final String titulo;
  final Widget Function(T fila) celda;

  /// Parte del ancho que ocupa frente a las demas columnas.
  final int proporcion;
}
