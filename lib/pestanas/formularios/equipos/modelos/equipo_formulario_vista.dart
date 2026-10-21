/// Responsabilidad: Representar lo que necesita el formulario de equipo: los
/// valores iniciales (vacios en alta) y las opciones de empresa y sede.
library;

import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/empresa_opcion_vista.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/sede_opcion_vista.dart';

class EquipoFormularioVista {
  const EquipoFormularioVista({
    required this.empresas,
    required this.sedes,
    this.fkEmpresa,
    this.fkSede,
    this.nombre = '',
    this.codigo = '',
    this.tipo = '',
    this.idFabrica = '',
    this.direccionMac = '',
    this.observaciones = '',
    this.fechaInicio,
  });

  final List<EmpresaOpcionVista> empresas;
  final List<SedeOpcionVista> sedes;

  final String? fkEmpresa;
  final String? fkSede;
  final String nombre;
  final String codigo;
  final String tipo;
  final String idFabrica;
  final String direccionMac;
  final String observaciones;
  final DateTime? fechaInicio;
}
