/// Responsabilidad: Construir el controlador del formulario. El id nulo es un
/// alta; con id, la edicion de ese equipo.
library;

import 'package:flutter_riverpod/legacy.dart';

import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/controladores/formulario/equipos_formulario_controlador.dart';

final equiposFormularioProveedor = ChangeNotifierProvider.autoDispose
    .family<EquiposFormularioControlador, String?>((ref, id) {
      final controlador = EquiposFormularioControlador(id);
      Future.microtask(controlador.cargar);
      return controlador;
    });
