/// Responsabilidad: Contrato de roles semánticos de color que todo tema debe
/// cumplir. Se publica como `ThemeExtension`, así que se lee con
/// `context.colores` y se interpola al cambiar de tema.
library;

import 'package:flutter/material.dart';

/// Cuatro colores coordinados para un estado (éxito, error, etc.):
/// - [base]: fondo sólido (botón de peligro, badge) o icono sobre superficie.
/// - [sobreBase]: texto o icono encima de [base].
/// - [contenedor]: fondo suave (alerta, mensaje en línea).
/// - [sobreContenedor]: texto o icono encima de [contenedor].
@immutable
final class ColoresEstado {
  const ColoresEstado({
    required this.base,
    required this.sobreBase,
    required this.contenedor,
    required this.sobreContenedor,
  });

  final Color base;
  final Color sobreBase;
  final Color contenedor;
  final Color sobreContenedor;

  static ColoresEstado lerp(ColoresEstado a, ColoresEstado b, double t) {
    return ColoresEstado(
      base: Color.lerp(a.base, b.base, t)!,
      sobreBase: Color.lerp(a.sobreBase, b.sobreBase, t)!,
      contenedor: Color.lerp(a.contenedor, b.contenedor, t)!,
      sobreContenedor: Color.lerp(a.sobreContenedor, b.sobreContenedor, t)!,
    );
  }
}

@immutable
final class ColoresApp extends ThemeExtension<ColoresApp> {
  const ColoresApp({
    required this.brillo,
    required this.primario,
    required this.sobrePrimario,
    required this.primarioContenedor,
    required this.sobrePrimarioContenedor,
    required this.secundario,
    required this.sobreSecundario,
    required this.acento,
    required this.sobreAcento,
    required this.textoPrimario,
    required this.textoSecundario,
    required this.textoTerciario,
    required this.textoDeshabilitado,
    required this.textoInverso,
    required this.enlace,
    required this.fondoLienzo,
    required this.superficie,
    required this.superficieBaja,
    required this.superficieElevada,
    required this.superficieInversa,
    required this.velo,
    required this.sombra,
    required this.borde,
    required this.bordeSutil,
    required this.bordeFuerte,
    required this.foco,
    required this.hover,
    required this.presionado,
    required this.seleccionado,
    required this.fondoDeshabilitado,
    required this.neutro,
    required this.informacion,
    required this.exito,
    required this.advertencia,
    required this.error,
  });

  // BRILLO - Claro u oscuro, para ThemeData
  final Brightness brillo;

  // MARCA
  final Color primario; // acción principal, selección, enlaces fuertes
  final Color sobrePrimario; // texto/icono sobre primario
  final Color
  primarioContenedor; // fondo suave de marca (chip activo, opción seleccionada)
  final Color sobrePrimarioContenedor; // texto/icono sobre primarioContenedor
  final Color secundario; // acción de apoyo
  final Color sobreSecundario;
  final Color acento; // detalle decorativo, gráficos
  final Color sobreAcento;

  // TEXTOS
  final Color textoPrimario; // títulos y contenido principal
  final Color textoSecundario; // etiquetas, descripciones, iconos
  final Color textoTerciario; // ayudas, placeholders, metadatos
  final Color textoDeshabilitado;
  final Color textoInverso; // sobre superficieInversa (tooltips, snackbars)
  final Color enlace;

  // FONDOS Y SUPERFICIES
  final Color fondoLienzo; // fondo de la página, detrás de todo
  final Color superficie; // cards, paneles, hojas
  final Color
  superficieBaja; // zonas hundidas: cabecera de tabla, campo relleno
  final Color superficieElevada; // diálogos, menús, selectores
  final Color superficieInversa; // tooltips, snackbars
  final Color velo; // fondo detrás de diálogos y hojas superpuestas
  final Color sombra; // color base de las sombras

  // BORDES
  final Color borde; // borde estándar de campos y cards
  final Color bordeSutil; // divisores, separadores
  final Color bordeFuerte; // borde con énfasis
  final Color foco; // anillo de foco de teclado

  // INTERACCIONES - Capas translúcidas sobre el elemento
  final Color hover;
  final Color presionado;
  final Color seleccionado;
  final Color fondoDeshabilitado;

  // ESTADOS
  final ColoresEstado neutro;
  final ColoresEstado informacion;
  final ColoresEstado exito;
  final ColoresEstado advertencia;
  final ColoresEstado error;

  @override
  ColoresApp copyWith({
    Brightness? brillo,
    Color? primario,
    Color? sobrePrimario,
    Color? primarioContenedor,
    Color? sobrePrimarioContenedor,
    Color? secundario,
    Color? sobreSecundario,
    Color? acento,
    Color? sobreAcento,
    Color? textoPrimario,
    Color? textoSecundario,
    Color? textoTerciario,
    Color? textoDeshabilitado,
    Color? textoInverso,
    Color? enlace,
    Color? fondoLienzo,
    Color? superficie,
    Color? superficieBaja,
    Color? superficieElevada,
    Color? superficieInversa,
    Color? velo,
    Color? sombra,
    Color? borde,
    Color? bordeSutil,
    Color? bordeFuerte,
    Color? foco,
    Color? hover,
    Color? presionado,
    Color? seleccionado,
    Color? fondoDeshabilitado,
    ColoresEstado? neutro,
    ColoresEstado? informacion,
    ColoresEstado? exito,
    ColoresEstado? advertencia,
    ColoresEstado? error,
  }) {
    return ColoresApp(
      brillo: brillo ?? this.brillo,
      primario: primario ?? this.primario,
      sobrePrimario: sobrePrimario ?? this.sobrePrimario,
      primarioContenedor: primarioContenedor ?? this.primarioContenedor,
      sobrePrimarioContenedor:
          sobrePrimarioContenedor ?? this.sobrePrimarioContenedor,
      secundario: secundario ?? this.secundario,
      sobreSecundario: sobreSecundario ?? this.sobreSecundario,
      acento: acento ?? this.acento,
      sobreAcento: sobreAcento ?? this.sobreAcento,
      textoPrimario: textoPrimario ?? this.textoPrimario,
      textoSecundario: textoSecundario ?? this.textoSecundario,
      textoTerciario: textoTerciario ?? this.textoTerciario,
      textoDeshabilitado: textoDeshabilitado ?? this.textoDeshabilitado,
      textoInverso: textoInverso ?? this.textoInverso,
      enlace: enlace ?? this.enlace,
      fondoLienzo: fondoLienzo ?? this.fondoLienzo,
      superficie: superficie ?? this.superficie,
      superficieBaja: superficieBaja ?? this.superficieBaja,
      superficieElevada: superficieElevada ?? this.superficieElevada,
      superficieInversa: superficieInversa ?? this.superficieInversa,
      velo: velo ?? this.velo,
      sombra: sombra ?? this.sombra,
      borde: borde ?? this.borde,
      bordeSutil: bordeSutil ?? this.bordeSutil,
      bordeFuerte: bordeFuerte ?? this.bordeFuerte,
      foco: foco ?? this.foco,
      hover: hover ?? this.hover,
      presionado: presionado ?? this.presionado,
      seleccionado: seleccionado ?? this.seleccionado,
      fondoDeshabilitado: fondoDeshabilitado ?? this.fondoDeshabilitado,
      neutro: neutro ?? this.neutro,
      informacion: informacion ?? this.informacion,
      exito: exito ?? this.exito,
      advertencia: advertencia ?? this.advertencia,
      error: error ?? this.error,
    );
  }

  @override
  ColoresApp lerp(ColoresApp? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return ColoresApp(
      brillo: t < 0.5 ? brillo : other.brillo,
      primario: c(primario, other.primario),
      sobrePrimario: c(sobrePrimario, other.sobrePrimario),
      primarioContenedor: c(primarioContenedor, other.primarioContenedor),
      sobrePrimarioContenedor: c(
        sobrePrimarioContenedor,
        other.sobrePrimarioContenedor,
      ),
      secundario: c(secundario, other.secundario),
      sobreSecundario: c(sobreSecundario, other.sobreSecundario),
      acento: c(acento, other.acento),
      sobreAcento: c(sobreAcento, other.sobreAcento),
      textoPrimario: c(textoPrimario, other.textoPrimario),
      textoSecundario: c(textoSecundario, other.textoSecundario),
      textoTerciario: c(textoTerciario, other.textoTerciario),
      textoDeshabilitado: c(textoDeshabilitado, other.textoDeshabilitado),
      textoInverso: c(textoInverso, other.textoInverso),
      enlace: c(enlace, other.enlace),
      fondoLienzo: c(fondoLienzo, other.fondoLienzo),
      superficie: c(superficie, other.superficie),
      superficieBaja: c(superficieBaja, other.superficieBaja),
      superficieElevada: c(superficieElevada, other.superficieElevada),
      superficieInversa: c(superficieInversa, other.superficieInversa),
      velo: c(velo, other.velo),
      sombra: c(sombra, other.sombra),
      borde: c(borde, other.borde),
      bordeSutil: c(bordeSutil, other.bordeSutil),
      bordeFuerte: c(bordeFuerte, other.bordeFuerte),
      foco: c(foco, other.foco),
      hover: c(hover, other.hover),
      presionado: c(presionado, other.presionado),
      seleccionado: c(seleccionado, other.seleccionado),
      fondoDeshabilitado: c(fondoDeshabilitado, other.fondoDeshabilitado),
      neutro: ColoresEstado.lerp(neutro, other.neutro, t),
      informacion: ColoresEstado.lerp(informacion, other.informacion, t),
      exito: ColoresEstado.lerp(exito, other.exito, t),
      advertencia: ColoresEstado.lerp(advertencia, other.advertencia, t),
      error: ColoresEstado.lerp(error, other.error, t),
    );
  }
}
