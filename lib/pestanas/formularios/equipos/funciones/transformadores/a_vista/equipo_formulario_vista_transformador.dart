/// Responsabilidad: Armar lo que necesita el formulario: valores del equipo
/// (o vacios en alta) y las opciones de empresa y sede.
library;

import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_modelo.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/empresa_opcion_vista.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/equipo_formulario_vista.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/sede_opcion_vista.dart';

class EquipoFormularioVistaTransformador {
  static EquipoFormularioVista transformar(
    EquiposControlVtModelo? crudo, {
    required List<EmpresaOpcionVista> empresas,
    required List<SedeOpcionVista> sedes,
  }) {
    if (crudo == null) {
      return EquipoFormularioVista(empresas: empresas, sedes: sedes);
    }
    return EquipoFormularioVista(
      empresas: empresas,
      sedes: sedes,
      fkEmpresa: crudo.fkEmpresa,
      fkSede: crudo.fkSede,
      nombre: crudo.nombre ?? '',
      codigo: crudo.codigoEquipoControl ?? '',
      tipo: crudo.tipoEquipoControl ?? '',
      idFabrica: crudo.idEquipoFabrica ?? '',
      direccionMac: crudo.direccionMac ?? '',
      observaciones: crudo.observaciones ?? '',
      fechaInicio: crudo.fechaInicio,
    );
  }
}
