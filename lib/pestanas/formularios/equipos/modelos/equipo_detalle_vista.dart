/// Responsabilidad: Representar un equipo como lo muestra la pagina de detalle.
library;

import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/estado_equipo.dart';

class EquipoDetalleVista {
  const EquipoDetalleVista({
    required this.id,
    required this.fkEmpresa,
    required this.nombre,
    required this.codigo,
    required this.tipo,
    required this.empresa,
    required this.sede,
    required this.idFabrica,
    required this.direccionMac,
    required this.observaciones,
    required this.enServicioDesde,
    required this.finalizadoEl,
    required this.estado,
  });

  final String id;

  /// Para abrir el monitoreo en vivo filtrado a su empresa.
  final String fkEmpresa;
  final String nombre;
  final String codigo;
  final String tipo;
  final String empresa;
  final String sede;
  final String? idFabrica;
  final String? direccionMac;
  final String? observaciones;

  /// Fechas ya formateadas (dd/mm/aaaa).
  final String? enServicioDesde;
  final String? finalizadoEl;
  final EstadoEquipo estado;
}
