/// Responsabilidad: Convertir un equipo crudo en su fila del listado.
library;

import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_modelo.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/equipo_item_vista.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/estado_equipo.dart';

class EquipoItemVistaTransformador {
  static EquipoItemVista transformar(EquiposControlVtModelo crudo) =>
      EquipoItemVista(
        id: crudo.idEquipoControl,
        nombre: crudo.nombre ?? '—',
        codigo: crudo.codigoEquipoControl ?? '—',
        tipo: crudo.tipoEquipoControl ?? '—',
        sede: crudo.sede ?? '—',
        estado: EstadoEquipo.desde(crudo.fechaFinal),
      );

  static List<EquipoItemVista> transformarLista(
    List<EquiposControlVtModelo> crudos,
  ) => crudos.map(transformar).toList(growable: false);
}
