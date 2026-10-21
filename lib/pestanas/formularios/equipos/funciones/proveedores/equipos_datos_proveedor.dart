/// Responsabilidad: Construir el controlador del listado de equipos.
library;

import 'package:flutter_riverpod/legacy.dart';

import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/controladores/data/equipos_datos_controlador.dart';

final equiposDatosProveedor =
    ChangeNotifierProvider.autoDispose<EquiposDatosControlador>((ref) {
      final controlador = EquiposDatosControlador();
      // La carga no va en el cuerpo: notificaria mientras el arbol se
      // construye. El microtask la corre apenas termina ese ciclo.
      Future.microtask(controlador.cargar);
      return controlador;
    });
