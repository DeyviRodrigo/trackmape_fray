/// Responsabilidad: Construir el `ThemeData` de Flutter a partir de un
/// [ColoresApp], para que los widgets de Material ya salgan con los tokens.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/tokens/bordes.dart';
import 'package:trackmape_sup/recursos2/tokens/elevacion.dart';
import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/recursos2/tokens/radios.dart';
import 'package:trackmape_sup/recursos2/tokens/tamanos.dart';
import 'package:trackmape_sup/recursos2/tokens/tipografia.dart';
import 'package:trackmape_sup/recursos2/temas/colores_app.dart';
import 'package:trackmape_sup/recursos2/temas/colores_claros.dart';
import 'package:trackmape_sup/recursos2/temas/colores_oscuros.dart';

abstract final class TemaApp {
  static ThemeData get claro => construir(coloresClaros);
  static ThemeData get oscuro => construir(coloresOscuros);

  static ThemeData construir(ColoresApp c) {
    final esquema = ColorScheme(
      brightness: c.brillo,
      primary: c.primario,
      onPrimary: c.sobrePrimario,
      primaryContainer: c.primarioContenedor,
      onPrimaryContainer: c.sobrePrimarioContenedor,
      secondary: c.secundario,
      onSecondary: c.sobreSecundario,
      tertiary: c.acento,
      onTertiary: c.sobreAcento,
      error: c.error.base,
      onError: c.error.sobreBase,
      errorContainer: c.error.contenedor,
      onErrorContainer: c.error.sobreContenedor,
      surface: c.superficie,
      onSurface: c.textoPrimario,
      onSurfaceVariant: c.textoSecundario,
      surfaceContainerLow: c.superficieBaja,
      surfaceContainerHigh: c.superficieElevada,
      surfaceContainerHighest: c.superficieElevada,
      outline: c.borde,
      outlineVariant: c.bordeSutil,
      inverseSurface: c.superficieInversa,
      onInverseSurface: c.textoInverso,
      inversePrimary: c.primarioContenedor,
      shadow: c.sombra,
      scrim: c.velo,
    );

    final textos = const TextTheme(
      displaySmall: EscalaTipografica.display,
      headlineMedium: EscalaTipografica.tituloGrande,
      titleLarge: EscalaTipografica.titulo,
      titleMedium: EscalaTipografica.subtitulo,
      bodyLarge: EscalaTipografica.cuerpoGrande,
      bodyMedium: EscalaTipografica.cuerpo,
      bodySmall: EscalaTipografica.nota,
      labelLarge: EscalaTipografica.etiqueta,
      labelMedium: EscalaTipografica.etiquetaPequena,
      labelSmall: EscalaTipografica.micro,
    ).apply(bodyColor: c.textoPrimario, displayColor: c.textoPrimario);

    OutlineInputBorder bordeCampo(Color color, double grosor) =>
        OutlineInputBorder(
          borderRadius: RadiosBorde.pequeno,
          borderSide: BorderSide(color: color, width: grosor),
        );

    const formaControl = RoundedRectangleBorder(
      borderRadius: RadiosBorde.pequeno,
    );
    const tamanoControl = Size(0, TamanosControl.alturaBase);
    const rellenoControl = EdgeInsets.symmetric(horizontal: Espaciado.base);

    return ThemeData(
      useMaterial3: true,
      brightness: c.brillo,
      colorScheme: esquema,
      textTheme: textos,
      fontFamily: Fuentes.base,
      extensions: [c],
      scaffoldBackgroundColor: c.fondoLienzo,
      canvasColor: c.superficie,
      dividerColor: c.bordeSutil,
      hoverColor: c.hover,
      focusColor: c.presionado,
      highlightColor: c.presionado,
      splashColor: c.presionado,
      disabledColor: c.textoDeshabilitado,
      visualDensity: VisualDensity.standard,
      iconTheme: IconThemeData(
        size: TamanosIcono.base,
        color: c.textoSecundario,
      ),
      dividerTheme: DividerThemeData(
        color: c.bordeSutil,
        thickness: Grosores.fino,
        space: Grosores.fino,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.superficie,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Espaciado.medio,
          vertical: Espaciado.medio,
        ),
        hintStyle: textos.cuerpo(c.textoTerciario),
        labelStyle: textos.cuerpo(c.textoSecundario),
        helperStyle: textos.nota(c.textoTerciario),
        errorStyle: textos.nota(c.error.base),
        border: bordeCampo(c.borde, Grosores.fino),
        enabledBorder: bordeCampo(c.borde, Grosores.fino),
        focusedBorder: bordeCampo(c.foco, Grosores.grueso),
        errorBorder: bordeCampo(c.error.base, Grosores.fino),
        focusedErrorBorder: bordeCampo(c.error.base, Grosores.grueso),
        disabledBorder: bordeCampo(c.bordeSutil, Grosores.fino),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: tamanoControl,
          padding: rellenoControl,
          shape: formaControl,
          textStyle: EscalaTipografica.etiqueta,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: tamanoControl,
          padding: rellenoControl,
          shape: formaControl,
          textStyle: EscalaTipografica.etiqueta,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: tamanoControl,
          padding: rellenoControl,
          shape: formaControl,
          side: BorderSide(color: c.borde, width: Grosores.fino),
          textStyle: EscalaTipografica.etiqueta,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: tamanoControl,
          padding: const EdgeInsets.symmetric(horizontal: Espaciado.medio),
          shape: formaControl,
          textStyle: EscalaTipografica.etiqueta,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(TamanosControl.alturaBase),
          foregroundColor: c.textoSecundario,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primario,
        foregroundColor: c.sobrePrimario,
        elevation: Elevacion.nivel3,
        shape: const RoundedRectangleBorder(borderRadius: RadiosBorde.grande),
      ),
      cardTheme: CardThemeData(
        color: c.superficie,
        elevation: Elevacion.nivel0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: RadiosBorde.medio,
          side: BorderSide(color: c.bordeSutil, width: Grosores.fino),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.superficieElevada,
        elevation: Elevacion.nivel5,
        shape: const RoundedRectangleBorder(borderRadius: RadiosBorde.grande),
        titleTextStyle: textos.titulo(c.textoPrimario),
        contentTextStyle: textos.cuerpo(c.textoSecundario),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.superficieElevada,
        elevation: Elevacion.nivel2,
        shape: const RoundedRectangleBorder(borderRadius: RadiosBorde.pequeno),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.superficieInversa,
          borderRadius: RadiosBorde.minimo,
        ),
        textStyle: textos.nota(c.textoInverso),
        padding: const EdgeInsets.symmetric(
          horizontal: Espaciado.pequeno,
          vertical: Espaciado.minimo,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.superficieInversa,
        contentTextStyle: textos.cuerpo(c.textoInverso),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: RadiosBorde.pequeno),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.superficieBaja,
        selectedColor: c.primarioContenedor,
        side: BorderSide(color: c.bordeSutil),
        shape: const RoundedRectangleBorder(borderRadius: RadiosBorde.minimo),
        labelStyle: textos.etiquetaPequena(c.textoPrimario),
      ),
    );
  }
}

/// Copia un estilo del [TextTheme] cambiando solo el color.
extension on TextTheme {
  TextStyle cuerpo(Color color) => bodyMedium!.copyWith(color: color);
  TextStyle nota(Color color) => bodySmall!.copyWith(color: color);
  TextStyle titulo(Color color) => titleLarge!.copyWith(color: color);
  TextStyle etiquetaPequena(Color color) => labelMedium!.copyWith(color: color);
}
