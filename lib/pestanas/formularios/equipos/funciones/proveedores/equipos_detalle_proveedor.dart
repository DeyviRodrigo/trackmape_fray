/// Responsabilidad: Construir el controlador de detalle, uno por equipo.
library;

import 'package:flutter_riverpod/legacy.dart';

import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/controladores/detalle/equipos_detalle_controlador.dart';

final equiposDetalleProveedor = ChangeNotifierProvider.autoDispose
    .family<EquiposDetalleControlador, String>((ref, id) {
      final controlador = EquiposDetalleControlador(id);
      Future.microtask(controlador.cargar);
      return controlador;
    });
