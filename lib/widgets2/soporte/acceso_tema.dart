/// Responsabilidad: Acceso corto a los tokens del tema activo desde cualquier
/// widget: `context.colores` y `context.textos`.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/temas/colores_app.dart';
import 'package:trackmape_sup/recursos2/temas/colores_claros.dart';

extension TokensContexto on BuildContext {
  /// Colores semánticos del tema activo. Si el `MaterialApp` no usa `TemaApp`,
  /// cae en los colores claros para no romper.
  ColoresApp get colores =>
      Theme.of(this).extension<ColoresApp>() ?? coloresClaros;

  /// Estilos de texto ya coloreados. Con `TextosApp` se leen en español:
  /// `context.textos.titulo`, `context.textos.cuerpo`, etc.
  TextTheme get textos => Theme.of(this).textTheme;
}
