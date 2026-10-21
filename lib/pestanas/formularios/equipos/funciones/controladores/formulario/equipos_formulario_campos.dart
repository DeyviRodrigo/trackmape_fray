/// Responsabilidad: Guardar el estado editable del formulario de equipo: lo
/// que la pagina escribe y lo que despues se guarda.
library;

import 'package:flutter/widgets.dart';

import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/empresa_opcion_vista.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/equipo_formulario_vista.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/sede_opcion_vista.dart';

class EquiposFormularioCampos {
  final nombreControlador = TextEditingController();
  final codigoControlador = TextEditingController();
  final tipoControlador = TextEditingController();
  final idFabricaControlador = TextEditingController();
  final direccionMacControlador = TextEditingController();
  final observacionesControlador = TextEditingController();

  EmpresaOpcionVista? empresa;
  SedeOpcionVista? sede;
  DateTime? fechaInicio;

  void llenar(EquipoFormularioVista vista) {
    nombreControlador.text = vista.nombre;
    codigoControlador.text = vista.codigo;
    tipoControlador.text = vista.tipo;
    idFabricaControlador.text = vista.idFabrica;
    direccionMacControlador.text = vista.direccionMac;
    observacionesControlador.text = vista.observaciones;
    empresa = _buscar(vista.empresas, (e) => e.id == vista.fkEmpresa);
    sede = _buscar(vista.sedes, (s) => s.id == vista.fkSede);
    fechaInicio = vista.fechaInicio;
  }

  static T? _buscar<T>(List<T> opciones, bool Function(T) cumple) {
    for (final opcion in opciones) {
      if (cumple(opcion)) return opcion;
    }
    return null;
  }

  void dispose() {
    nombreControlador.dispose();
    codigoControlador.dispose();
    tipoControlador.dispose();
    idFabricaControlador.dispose();
    direccionMacControlador.dispose();
    observacionesControlador.dispose();
  }
}
