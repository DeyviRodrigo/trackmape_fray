/// Responsabilidad: Asignar la paleta base a los roles semánticos en modo claro.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/tokens/opacidad.dart';
import 'package:trackmape_sup/recursos2/tokens/paleta.dart';
import 'package:trackmape_sup/recursos2/temas/colores_app.dart';

final ColoresApp coloresClaros = ColoresApp(
  brillo: Brightness.light,
  // MARCA
  primario: Paleta.azul600,
  sobrePrimario: Paleta.blanco,
  primarioContenedor: Paleta.azul100,
  sobrePrimarioContenedor: Paleta.azul900,
  secundario: Paleta.celeste600,
  sobreSecundario: Paleta.blanco,
  acento: Paleta.violeta600,
  sobreAcento: Paleta.blanco,
  // TEXTOS
  textoPrimario: Paleta.pizarra900,
  textoSecundario: Paleta.pizarra600,
  textoTerciario: Paleta.pizarra500,
  textoDeshabilitado: Paleta.pizarra400,
  textoInverso: Paleta.pizarra50,
  enlace: Paleta.azul700,
  // FONDOS Y SUPERFICIES
  fondoLienzo: Paleta.pizarra50,
  superficie: Paleta.blanco,
  superficieBaja: Paleta.pizarra100,
  superficieElevada: Paleta.blanco,
  superficieInversa: Paleta.pizarra800,
  velo: Paleta.pizarra950.withValues(alpha: Opacidad.velo),
  sombra: Paleta.pizarra900.withValues(alpha: 0.16),
  // BORDES
  borde: Paleta.pizarra300,
  bordeSutil: Paleta.pizarra200,
  bordeFuerte: Paleta.pizarra500,
  foco: Paleta.azul600,
  // INTERACCIONES
  hover: Paleta.pizarra900.withValues(alpha: Opacidad.hover),
  presionado: Paleta.pizarra900.withValues(alpha: Opacidad.presionado),
  seleccionado: Paleta.azul600.withValues(alpha: Opacidad.seleccionado),
  fondoDeshabilitado: Paleta.pizarra900.withValues(alpha: Opacidad.foco),
  // ESTADOS
  neutro: const ColoresEstado(
    base: Paleta.pizarra600,
    sobreBase: Paleta.blanco,
    contenedor: Paleta.pizarra100,
    sobreContenedor: Paleta.pizarra800,
  ),
  informacion: const ColoresEstado(
    base: Paleta.celeste600,
    sobreBase: Paleta.blanco,
    contenedor: Paleta.celeste100,
    sobreContenedor: Paleta.celeste900,
  ),
  exito: const ColoresEstado(
    base: Paleta.verde600,
    sobreBase: Paleta.blanco,
    contenedor: Paleta.verde100,
    sobreContenedor: Paleta.verde900,
  ),
  advertencia: const ColoresEstado(
    base: Paleta.ambar700,
    sobreBase: Paleta.blanco,
    contenedor: Paleta.ambar100,
    sobreContenedor: Paleta.ambar900,
  ),
  error: const ColoresEstado(
    base: Paleta.rojo600,
    sobreBase: Paleta.blanco,
    contenedor: Paleta.rojo100,
    sobreContenedor: Paleta.rojo900,
  ),
);
