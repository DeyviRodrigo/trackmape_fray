/// Responsabilidad: Nombrar los estados que comunica la interfaz (mensajes,
/// badges, alertas) y resolver sus colores e icono desde el tema activo.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/temas/colores_app.dart';

enum TonoEstado { neutro, informacion, exito, advertencia, error }

extension TonoEstadoColores on TonoEstado {
  ColoresEstado colores(ColoresApp c) => switch (this) {
    TonoEstado.neutro => c.neutro,
    TonoEstado.informacion => c.informacion,
    TonoEstado.exito => c.exito,
    TonoEstado.advertencia => c.advertencia,
    TonoEstado.error => c.error,
  };

  IconData get icono => switch (this) {
    TonoEstado.neutro => Icons.circle_outlined,
    TonoEstado.informacion => Icons.info_outline,
    TonoEstado.exito => Icons.check_circle_outline,
    TonoEstado.advertencia => Icons.warning_amber_outlined,
    TonoEstado.error => Icons.error_outline,
  };
}
