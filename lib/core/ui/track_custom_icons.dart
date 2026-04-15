import 'package:flutter/widgets.dart';

abstract final class TrackCustomIcons {
  static const String _volqueteFontFamily = 'IconoVolqueteOtf1';
  static const String _cargadorFontFamily = 'IconoCargadorOtf1';

  static const IconData iconoVolquete = IconData(
    0xf000,
    fontFamily: _volqueteFontFamily,
  );

  static const IconData iconoCargador = IconData(
    0xf000,
    fontFamily: _cargadorFontFamily,
  );

  static IconData iconoPorEquipo({
    String? nombre,
    String? codigo,
  }) {
    final referencia = '${nombre ?? ''} ${codigo ?? ''}'.toLowerCase();

    if (referencia.contains('cargador')) {
      return iconoCargador;
    }

    if (referencia.contains('volquete')) {
      return iconoVolquete;
    }

    return iconoVolquete;
  }
}
