import 'package:flutter/material.dart';
import 'package:trackmape_sup/app/tokens/colores/colores_app.dart';
import 'package:trackmape_sup/app/tokens/dimensiones/radios.dart';

class TemaBase {
  static ThemeData oscuro() {
    final esquema =
        ColorScheme.fromSeed(
          seedColor: ColoresApp.marcaPrimaria,
          brightness: Brightness.dark,
        ).copyWith(
          primary: ColoresApp.marcaPrimaria,
          secondary: ColoresApp.marcaSecundaria,
          surface: ColoresApp.superficieElevada,
          error: ColoresApp.error,
        );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: esquema,
      scaffoldBackgroundColor: ColoresApp.fondoSecundario,
      drawerTheme: const DrawerThemeData(
        backgroundColor: ColoresApp.fondoPrimario,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ColoresApp.fondoPrimario,
        foregroundColor: ColoresApp.textoPrimario,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColoresApp.fondoPrimario,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radios.grande),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radios.grande),
          borderSide: const BorderSide(color: ColoresApp.borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radios.grande),
          borderSide: const BorderSide(color: ColoresApp.marcaPrimaria),
        ),
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: ColoresApp.textoPrimario,
        displayColor: ColoresApp.textoPrimario,
      ),
    );
  }
}
