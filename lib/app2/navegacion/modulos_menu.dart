/// Responsabilidad: Declarar los modulos del menu, agrupados por tipo, con su
/// icono y la ruta que abre cada uno.
///
/// Sigue la propuesta de documentacion/planificacion_pestanas.md (seccion 4).
/// Solo Equipos esta decidido; el resto es referencia y abre las pantallas
/// anteriores hasta migrarse. Fijo mientras no haya inicio de sesion; despues
/// saldra de los permisos del usuario.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/app2/rutas/rutas.dart';
import 'package:trackmape_sup/widgets2/estructuras/paneles/grupo_navegacion.dart';
import 'package:trackmape_sup/widgets2/estructuras/paneles/opcion_navegacion.dart';

abstract final class ModulosMenu {
  static const grupos = [
    GrupoNavegacion(
      titulo: 'Formularios',
      opciones: [
        OpcionNavegacion(
          id: Rutas.equipos,
          etiqueta: 'Equipos',
          icono: Icons.local_shipping_outlined,
        ),
        OpcionNavegacion(
          id: Rutas.elementosOperativos,
          etiqueta: 'Elementos Operativos',
          icono: Icons.layers_outlined,
        ),
      ],
    ),
    GrupoNavegacion(
      titulo: 'Herramientas',
      opciones: [
        OpcionNavegacion(
          id: Rutas.monitoreoEnVivo,
          etiqueta: 'Monitoreo en Vivo',
          icono: Icons.sensors,
        ),
      ],
    ),
    GrupoNavegacion(
      titulo: 'Informes',
      opciones: [
        OpcionNavegacion(
          id: Rutas.recorridos,
          etiqueta: 'Recorridos',
          icono: Icons.route_outlined,
        ),
        OpcionNavegacion(
          id: Rutas.rankingOperativo,
          etiqueta: 'Ranking Operativo',
          icono: Icons.leaderboard_outlined,
        ),
        OpcionNavegacion(
          id: Rutas.analisisEquipo,
          etiqueta: 'Análisis de Equipo',
          icono: Icons.analytics_outlined,
        ),
      ],
    ),
  ];

  static const pie = [
    OpcionNavegacion(
      id: Rutas.versionAnterior,
      etiqueta: 'Versión anterior',
      icono: Icons.history,
    ),
  ];

  /// La opcion activa para una ruta (tambien sus subrutas).
  static String? activo(String ruta) {
    for (final opcion in [
      for (final grupo in grupos) ...grupo.opciones,
      ...pie,
    ]) {
      if (ruta == opcion.id || ruta.startsWith('${opcion.id}/')) {
        return opcion.id;
      }
    }
    return null;
  }
}
