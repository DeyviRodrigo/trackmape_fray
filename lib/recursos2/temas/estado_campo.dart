/// Responsabilidad: Resolver borde, fondo y texto de un campo de entrada según
/// su estado, para campos propios que no usan `InputDecoration`.
library;

import 'package:flutter/painting.dart';

import 'package:trackmape_sup/recursos2/tokens/bordes.dart';
import 'package:trackmape_sup/recursos2/temas/colores_app.dart';

enum EstadoCampo { normal, foco, error, deshabilitado, soloLectura }

extension EstadoCampoColores on EstadoCampo {
  Color borde(ColoresApp c) => switch (this) {
    EstadoCampo.normal => c.borde,
    EstadoCampo.foco => c.foco,
    EstadoCampo.error => c.error.base,
    EstadoCampo.deshabilitado => c.bordeSutil,
    EstadoCampo.soloLectura => c.bordeSutil,
  };

  double get grosorBorde => switch (this) {
    EstadoCampo.foco => Grosores.grueso,
    _ => Grosores.fino,
  };

  Color fondo(ColoresApp c) => switch (this) {
    EstadoCampo.deshabilitado => c.fondoDeshabilitado,
    EstadoCampo.soloLectura => c.superficieBaja,
    _ => c.superficie,
  };

  Color texto(ColoresApp c) => switch (this) {
    EstadoCampo.deshabilitado => c.textoDeshabilitado,
    _ => c.textoPrimario,
  };
}
