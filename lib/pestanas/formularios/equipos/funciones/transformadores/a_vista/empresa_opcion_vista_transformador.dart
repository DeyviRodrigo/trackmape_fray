/// Responsabilidad: Convertir una empresa cruda en opcion del formulario.
library;

import 'package:trackmape_sup/datos2/vistas/empresas_vt/empresas_vt_modelo.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/empresa_opcion_vista.dart';

class EmpresaOpcionVistaTransformador {
  static EmpresaOpcionVista transformar(EmpresasVtModelo crudo) =>
      EmpresaOpcionVista(
        id: crudo.idEmpresa,
        nombre: crudo.nombreComercial ?? crudo.razonSocial,
      );

  static List<EmpresaOpcionVista> transformarLista(
    List<EmpresasVtModelo> crudos,
  ) => crudos.map(transformar).toList(growable: false);
}
