/// Responsabilidad: Representar un equipo como lo muestra una fila del listado.
library;

import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/estado_equipo.dart';

class EquipoItemVista {
  const EquipoItemVista({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.tipo,
    required this.sede,
    required this.estado,
  });

  final String id;
  final String nombre;
  final String codigo;
  final String tipo;
  final String sede;
  final EstadoEquipo estado;
}
