/// Responsabilidad: Acotar las sedes del formulario a la empresa elegida.
library;

import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/sede_opcion_vista.dart';

class SedesPorEmpresaFiltro {
  List<SedeOpcionVista> ejecutar(
    List<SedeOpcionVista> sedes,
    String? fkEmpresa,
  ) {
    if (fkEmpresa == null) return const [];
    return sedes
        .where((sede) => sede.fkEmpresa == fkEmpresa)
        .toList(growable: false);
  }
}
