/// Responsabilidad: Declarar las rutas de la aplicacion.
///
/// Todas van dentro del marco de navegacion (menu) con el tema nuevo. Los
/// modulos aun no migrados muestran las pantallas anteriores.
///
/// La ruta inicial se puede cambiar al ejecutar, sin la barra inicial (Git Bash
/// convierte "/equipos" en una ruta de Windows), por ejemplo:
/// `flutter run --dart-define=RUTA_INICIAL=equipos`
/// (ver documentacion/ejecutar_app.md).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trackmape_sup/app2/configuracion/empresas_habilitadas.dart';
import 'package:trackmape_sup/app2/navegacion/contenido_anterior.dart';
import 'package:trackmape_sup/app2/navegacion/marco_navegacion.dart';
import 'package:trackmape_sup/app2/rutas/rutas.dart';
import 'package:trackmape_sup/funciones/diagnostico/presentacion/paginas/pagina_diagnostico_operativo.dart';
import 'package:trackmape_sup/funciones/estadistica/presentacion/pagina/comparativo_rutas_page.dart';
import 'package:trackmape_sup/funciones/estadistica/presentacion/pagina/rendimiento_operador.dart';
import 'package:trackmape_sup/funciones/gis/presentacion/paginas/pagina_configuracion_operativa.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_historico.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_ranking.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_simulacion.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_stream.dart';
import 'package:trackmape_sup/funciones/navegacion/presentacion/contenedor_principal.dart';
import 'package:trackmape_sup/funciones/validacion/presentacion/paginas/validacion_equipos_page.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/paginas/equipos_pestana.dart';
import 'package:trackmape_sup/recursos2/temas/tema_app.dart';

// Las pantallas anteriores piden una empresa. Mientras no se decida el filtro
// de empresa (global o por pestana), se usa la primera habilitada.
final _empresa = EmpresasHabilitadas.ids.first;

GoRoute _anterior(String ruta, String titulo, List<PantallaAnterior> lista) =>
    GoRoute(
      path: ruta,
      builder: (context, state) =>
          ContenidoAnterior(titulo: titulo, pantallas: lista),
    );

final GoRouter enrutadorApp = GoRouter(
  initialLocation: '/${const String.fromEnvironment('RUTA_INICIAL')}',
  redirect: (context, state) => state.uri.path == '/' ? Rutas.equipos : null,
  routes: [
    ShellRoute(
      builder: (context, state, child) => Theme(
        data: TemaApp.oscuro,
        child: Scaffold(
          body: MarcoNavegacion(rutaActual: state.uri.path, child: child),
        ),
      ),
      routes: [
        // FORMULARIOS
        GoRoute(
          path: Rutas.equipos,
          builder: (context, state) => const EquiposPestana(),
        ),
        _anterior(Rutas.elementosOperativos, 'Elementos Operativos', [
          PantallaAnterior(
            titulo: 'Configuración Operativa',
            pagina: PaginaConfiguracionOperativa(empresaInicial: _empresa),
          ),
        ]),

        // HERRAMIENTAS
        _anterior(Rutas.monitoreoEnVivo, 'Monitoreo en Vivo', [
          PantallaAnterior(
            titulo: 'Tracking en vivo',
            pagina: PaginaStream(empresaFiltro: _empresa),
          ),
        ]),

        // INFORMES
        _anterior(Rutas.recorridos, 'Recorridos', [
          PantallaAnterior(
            titulo: 'Consulta histórica',
            pagina: PaginaHistorico(empresaFiltro: _empresa),
          ),
          const PantallaAnterior(
            titulo: 'Transcurso simulado',
            pagina: HojaSimulacion(),
          ),
        ]),
        _anterior(Rutas.rankingOperativo, 'Ranking Operativo', [
          const PantallaAnterior(titulo: 'Ranking', pagina: PaginaRanking()),
        ]),
        _anterior(Rutas.analisisEquipo, 'Análisis de Equipo', [
          const PantallaAnterior(
            titulo: 'Rendimiento',
            pagina: RendimientoOperador(),
          ),
          const PantallaAnterior(
            titulo: 'Validación',
            pagina: ValidacionEquiposPage(),
          ),
          const PantallaAnterior(
            titulo: 'Rutas',
            pagina: ComparativoRutasPage(),
          ),
          PantallaAnterior(
            titulo: 'Diagnóstico',
            pagina: PaginaDiagnosticoOperativo(empresaInicial: _empresa),
          ),
        ]),

        // VERSION ANTERIOR - La app de antes completa, con su propio menu
        _anterior(Rutas.versionAnterior, 'Versión anterior', [
          const PantallaAnterior(
            titulo: 'Versión anterior',
            pagina: ContenedorPrincipal(),
          ),
        ]),
      ],
    ),
  ],
);
