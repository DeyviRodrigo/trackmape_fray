/// Responsabilidad: Asignar la paleta base a los roles semánticos en modo oscuro.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/tokens/opacidad.dart';
import 'package:trackmape_sup/recursos2/tokens/paleta.dart';
import 'package:trackmape_sup/recursos2/temas/colores_app.dart';

final ColoresApp coloresOscuros = ColoresApp(
  brillo: Brightness.dark,
  // MARCA
  primario: Paleta.azul400,
  sobrePrimario: Paleta.pizarra950,
  primarioContenedor: Paleta.azul900,
  sobrePrimarioContenedor: Paleta.azul100,
  secundario: Paleta.celeste400,
  sobreSecundario: Paleta.pizarra950,
  acento: Paleta.celeste400,
  sobreAcento: Paleta.pizarra950,
  // TEXTOS
  textoPrimario: Paleta.pizarra50,
  textoSecundario: Paleta.pizarra300,
  textoTerciario: Paleta.pizarra400,
  textoDeshabilitado: Paleta.pizarra600,
  textoInverso: Paleta.pizarra900,
  enlace: Paleta.azul300,
  // FONDOS Y SUPERFICIES
  fondoLienzo: Paleta.pizarra900,
  superficie: Paleta.pizarra800,
  superficieBaja: Paleta.pizarra950,
  superficieElevada: Paleta.pizarra700,
  superficieInversa: Paleta.pizarra100,
  velo: Paleta.negro.withValues(alpha: 0.6),
  sombra: Paleta.negro.withValues(alpha: 0.4),
  // BORDES
  borde: Paleta.pizarra600,
  bordeSutil: Paleta.pizarra700,
  bordeFuerte: Paleta.pizarra500,
  foco: Paleta.azul400,
  // INTERACCIONES
  hover: Paleta.blanco.withValues(alpha: Opacidad.hover),
  presionado: Paleta.blanco.withValues(alpha: Opacidad.presionado),
  seleccionado: Paleta.azul400.withValues(alpha: Opacidad.seleccionado),
  fondoDeshabilitado: Paleta.blanco.withValues(alpha: Opacidad.foco),
  // ESTADOS
  neutro: const ColoresEstado(
    base: Paleta.pizarra400,
    sobreBase: Paleta.pizarra950,
    contenedor: Paleta.pizarra700,
    sobreContenedor: Paleta.pizarra100,
  ),
  informacion: const ColoresEstado(
    base: Paleta.celeste400,
    sobreBase: Paleta.pizarra950,
    contenedor: Paleta.celeste950,
    sobreContenedor: Paleta.celeste100,
  ),
  exito: const ColoresEstado(
    base: Paleta.verde400,
    sobreBase: Paleta.pizarra950,
    contenedor: Paleta.verde950,
    sobreContenedor: Paleta.verde100,
  ),
  advertencia: const ColoresEstado(
    base: Paleta.ambar400,
    sobreBase: Paleta.pizarra950,
    contenedor: Paleta.ambar950,
    sobreContenedor: Paleta.ambar100,
  ),
  error: const ColoresEstado(
    base: Paleta.rojo400,
    sobreBase: Paleta.pizarra950,
    contenedor: Paleta.rojo950,
    sobreContenedor: Paleta.rojo100,
  ),
);
