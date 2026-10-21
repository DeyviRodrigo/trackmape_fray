/// Responsabilidad: Declarar como se puede consultar equipos_control_vt: un filtro por
/// cada columna de la vista, el orden y el tramo.
///
/// Es espejo de la vista: tiene todas sus columnas, se usen o no. Cada pestana
/// marca solo lo que necesita; un filtro ausente no restringe.
library;

import 'package:trackmape_sup/app2/conexion_backend/contratos/formulario_lectura.dart';
import 'package:trackmape_sup/datos2/consulta_vista/armar_formulario_lectura.dart';
import 'package:trackmape_sup/datos2/consulta_vista/campo_consulta_vista.dart';
import 'package:trackmape_sup/datos2/consulta_vista/columna_vista.dart';
import 'package:trackmape_sup/datos2/consulta_vista/orden_consulta_vista.dart';

// EQUIPOS CONTROL VT COLUMNA - Columnas de la vista con su nombre en la base
enum EquiposControlVtColumna implements ColumnaVista {
  idEquipoControl('id_equipo_control'),
  fkEmpresa('fk_empresa'),
  empresa('empresa'),
  fkSede('fk_sede'),
  sede('sede'),
  nombre('nombre'),
  ubicacion('ubicacion'),
  idEquipoFabrica('id_equipo_fabrica'),
  tipoEquipoControl('tipo_equipo_control'),
  codigoEquipoControl('codigo_equipo_control'),
  direccionMac('direccion_mac'),
  observaciones('observaciones'),
  fkAreaAsociada('fk_area_asociada'),
  fkEquipoAsociado('fk_equipo_asociado'),
  fechaInicio('fecha_inicio'),
  fechaFinal('fecha_final');

  const EquiposControlVtColumna(this.nombrePostgresql);

  @override
  final String nombrePostgresql;
}

// EQUIPOS CONTROL VT CONSULTA - Filtros, orden y tramo de la vista
class EquiposControlVtConsulta {
  const EquiposControlVtConsulta({
    this.idEquipoControl = const CampoConsultaVista.ausente(),
    this.fkEmpresa = const CampoConsultaVista.ausente(),
    this.empresa = const CampoConsultaVista.ausente(),
    this.fkSede = const CampoConsultaVista.ausente(),
    this.sede = const CampoConsultaVista.ausente(),
    this.nombre = const CampoConsultaVista.ausente(),
    this.ubicacion = const CampoConsultaVista.ausente(),
    this.idEquipoFabrica = const CampoConsultaVista.ausente(),
    this.tipoEquipoControl = const CampoConsultaVista.ausente(),
    this.codigoEquipoControl = const CampoConsultaVista.ausente(),
    this.direccionMac = const CampoConsultaVista.ausente(),
    this.observaciones = const CampoConsultaVista.ausente(),
    this.fkAreaAsociada = const CampoConsultaVista.ausente(),
    this.fkEquipoAsociado = const CampoConsultaVista.ausente(),
    this.fechaInicio = const CampoConsultaVista.ausente(),
    this.fechaFinal = const CampoConsultaVista.ausente(),
    this.ordenarPor = const [],
    this.tramo,
  });

  final CampoConsultaVista<String> idEquipoControl;
  final CampoConsultaVista<String> fkEmpresa;
  final CampoConsultaVista<String> empresa;
  final CampoConsultaVista<String> fkSede;
  final CampoConsultaVista<String> sede;
  final CampoConsultaVista<String> nombre;
  final CampoConsultaVista<String> ubicacion;
  final CampoConsultaVista<String> idEquipoFabrica;
  final CampoConsultaVista<String> tipoEquipoControl;
  final CampoConsultaVista<String> codigoEquipoControl;
  final CampoConsultaVista<String> direccionMac;
  final CampoConsultaVista<String> observaciones;
  final CampoConsultaVista<String> fkAreaAsociada;
  final CampoConsultaVista<String> fkEquipoAsociado;
  final CampoConsultaVista<DateTime> fechaInicio;
  final CampoConsultaVista<DateTime> fechaFinal;

  // ORDENAR POR - Criterios de orden, aplicados en el orden de la lista
  final List<OrdenConsultaVista<EquiposControlVtColumna>> ordenarPor;

  // TRAMO - Un maximo o una pagina de registros, o ninguno
  final TramoConsulta? tramo;

  // A FORMULARIO LECTURA - La hoja que recibe el mensajero
  FormularioLectura aFormularioLectura() => armarFormularioLectura(
    campos: {
      EquiposControlVtColumna.idEquipoControl: idEquipoControl,
      EquiposControlVtColumna.fkEmpresa: fkEmpresa,
      EquiposControlVtColumna.empresa: empresa,
      EquiposControlVtColumna.fkSede: fkSede,
      EquiposControlVtColumna.sede: sede,
      EquiposControlVtColumna.nombre: nombre,
      EquiposControlVtColumna.ubicacion: ubicacion,
      EquiposControlVtColumna.idEquipoFabrica: idEquipoFabrica,
      EquiposControlVtColumna.tipoEquipoControl: tipoEquipoControl,
      EquiposControlVtColumna.codigoEquipoControl: codigoEquipoControl,
      EquiposControlVtColumna.direccionMac: direccionMac,
      EquiposControlVtColumna.observaciones: observaciones,
      EquiposControlVtColumna.fkAreaAsociada: fkAreaAsociada,
      EquiposControlVtColumna.fkEquipoAsociado: fkEquipoAsociado,
      EquiposControlVtColumna.fechaInicio: fechaInicio,
      EquiposControlVtColumna.fechaFinal: fechaFinal,
    },
    ordenarPor: ordenarPor,
    tramo: tramo,
  );
}
