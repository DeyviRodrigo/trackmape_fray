/// Responsabilidad: Convertir un equipo crudo en lo que muestra el detalle.
library;

import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_modelo.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/equipo_detalle_vista.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/estado_equipo.dart';

class EquipoDetalleVistaTransformador {
  static EquipoDetalleVista transformar(EquiposControlVtModelo crudo) =>
      EquipoDetalleVista(
        id: crudo.idEquipoControl,
        fkEmpresa: crudo.fkEmpresa,
        nombre: crudo.nombre ?? '—',
        codigo: crudo.codigoEquipoControl ?? '—',
        tipo: crudo.tipoEquipoControl ?? '—',
        empresa: crudo.empresa ?? '—',
        sede: crudo.sede ?? '—',
        idFabrica: crudo.idEquipoFabrica,
        direccionMac: crudo.direccionMac,
        observaciones: crudo.observaciones,
        enServicioDesde: _fecha(crudo.fechaInicio),
        finalizadoEl: _fecha(crudo.fechaFinal),
        estado: EstadoEquipo.desde(crudo.fechaFinal),
      );

  static String? _fecha(DateTime? fecha) {
    if (fecha == null) return null;
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year}';
  }
}
