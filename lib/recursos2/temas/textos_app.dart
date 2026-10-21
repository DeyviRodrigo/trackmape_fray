/// Responsabilidad: Dar nombres en español a los estilos del `TextTheme` que
/// construye el tema, para usarlos como `context.textos.titulo`.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/tokens/tipografia.dart';

extension TextosApp on TextTheme {
  TextStyle get display => displaySmall!;
  TextStyle get tituloGrande => headlineMedium!;
  TextStyle get titulo => titleLarge!;
  TextStyle get subtitulo => titleMedium!;
  TextStyle get cuerpoGrande => bodyLarge!;
  TextStyle get cuerpo => bodyMedium!;
  TextStyle get nota => bodySmall!;
  TextStyle get etiqueta => labelLarge!;
  TextStyle get etiquetaPequena => labelMedium!;
  TextStyle get micro => labelSmall!;

  /// Monoespaciado (códigos, identificadores). No es un rol de Material, así
  /// que toma el color del cuerpo.
  TextStyle get codigo =>
      EscalaTipografica.codigo.copyWith(color: bodyMedium?.color);
}
