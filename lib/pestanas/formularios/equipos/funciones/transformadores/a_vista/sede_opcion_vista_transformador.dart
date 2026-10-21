/// Responsabilidad: Convertir una sede cruda en opcion del formulario.
library;

import 'package:trackmape_sup/datos2/vistas/sedes_vt/sedes_vt_modelo.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/sede_opcion_vista.dart';

class SedeOpcionVistaTransformador {
  static SedeOpcionVista transformar(SedesVtModelo crudo) => SedeOpcionVista(
    id: crudo.idSede,
    fkEmpresa: crudo.fkEmpresa,
    nombre: crudo.nombre,
  );

  static List<SedeOpcionVista> transformarLista(List<SedesVtModelo> crudos) =>
      crudos.map(transformar).toList(growable: false);
}
