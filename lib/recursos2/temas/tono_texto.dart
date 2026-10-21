/// Responsabilidad: Nombrar la jerarquía de color de textos e iconos para que
/// un widget reciba un tono en lugar de un color.
library;

import 'package:flutter/painting.dart';

import 'package:trackmape_sup/recursos2/temas/colores_app.dart';

enum TonoTexto {
  primario,
  secundario,
  terciario,
  deshabilitado,
  inverso,
  sobrePrimario,
  enlace,
}

extension TonoTextoColor on TonoTexto {
  Color color(ColoresApp c) => switch (this) {
    TonoTexto.primario => c.textoPrimario,
    TonoTexto.secundario => c.textoSecundario,
    TonoTexto.terciario => c.textoTerciario,
    TonoTexto.deshabilitado => c.textoDeshabilitado,
    TonoTexto.inverso => c.textoInverso,
    TonoTexto.sobrePrimario => c.sobrePrimario,
    TonoTexto.enlace => c.enlace,
  };
}
