/// Responsabilidad: Declarar como se puede consultar pr_elementos_operativos_vt: un filtro por
/// cada columna de la vista, el orden y el tramo.
///
/// Es espejo de la vista: tiene todas sus columnas, se usen o no. Cada pestana
/// marca solo lo que necesita; un filtro ausente no restringe.
///
/// Las columnas jsonb (geojson) no se filtran ni ordenan:
/// no tienen una igualdad ni un orden con sentido.
library;

import 'package:trackmape_sup/app2/conexion_backend/contratos/formulario_lectura.dart';
import 'package:trackmape_sup/datos2/consulta_vista/armar_formulario_lectura.dart';
import 'package:trackmape_sup/datos2/consulta_vista/campo_consulta_vista.dart';
import 'package:trackmape_sup/datos2/consulta_vista/columna_vista.dart';
import 'package:trackmape_sup/datos2/consulta_vista/orden_consulta_vista.dart';

// PR ELEMENTOS OPERATIVOS VT COLUMNA - Columnas de la vista con su nombre en la base
enum PrElementosOperativosVtColumna implements ColumnaVista {
  idElemento('id_elemento'),
  fkEmpresa('fk_empresa'),
  empresa('empresa'),
  fkSede('fk_sede'),
  sede('sede'),
  categoria('categoria'),
  tipoOperativo('tipo_operativo'),
  nombre('nombre'),
  descripcion('descripcion'),
  color('color'),
  prioridad('prioridad'),
  activo('activo'),
  fechaCreacion('fecha_creacion'),
  fechaActualizacion('fecha_actualizacion');

  const PrElementosOperativosVtColumna(this.nombrePostgresql);

  @override
  final String nombrePostgresql;
}

// PR ELEMENTOS OPERATIVOS VT CONSULTA - Filtros, orden y tramo de la vista
class PrElementosOperativosVtConsulta {
  const PrElementosOperativosVtConsulta({
    this.idElemento = const CampoConsultaVista.ausente(),
    this.fkEmpresa = const CampoConsultaVista.ausente(),
    this.empresa = const CampoConsultaVista.ausente(),
    this.fkSede = const CampoConsultaVista.ausente(),
    this.sede = const CampoConsultaVista.ausente(),
    this.categoria = const CampoConsultaVista.ausente(),
    this.tipoOperativo = const CampoConsultaVista.ausente(),
    this.nombre = const CampoConsultaVista.ausente(),
    this.descripcion = const CampoConsultaVista.ausente(),
    this.color = const CampoConsultaVista.ausente(),
    this.prioridad = const CampoConsultaVista.ausente(),
    this.activo = const CampoConsultaVista.ausente(),
    this.fechaCreacion = const CampoConsultaVista.ausente(),
    this.fechaActualizacion = const CampoConsultaVista.ausente(),
    this.ordenarPor = const [],
    this.tramo,
  });

  final CampoConsultaVista<String> idElemento;
  final CampoConsultaVista<String> fkEmpresa;
  final CampoConsultaVista<String> empresa;
  final CampoConsultaVista<String> fkSede;
  final CampoConsultaVista<String> sede;
  final CampoConsultaVista<String> categoria;
  final CampoConsultaVista<String> tipoOperativo;
  final CampoConsultaVista<String> nombre;
  final CampoConsultaVista<String> descripcion;
  final CampoConsultaVista<String> color;
  final CampoConsultaVista<int> prioridad;
  final CampoConsultaVista<bool> activo;
  final CampoConsultaVista<DateTime> fechaCreacion;
  final CampoConsultaVista<DateTime> fechaActualizacion;

  // ORDENAR POR - Criterios de orden, aplicados en el orden de la lista
  final List<OrdenConsultaVista<PrElementosOperativosVtColumna>> ordenarPor;

  // TRAMO - Un maximo o una pagina de registros, o ninguno
  final TramoConsulta? tramo;

  // A FORMULARIO LECTURA - La hoja que recibe el mensajero
  FormularioLectura aFormularioLectura() => armarFormularioLectura(
    campos: {
      PrElementosOperativosVtColumna.idElemento: idElemento,
      PrElementosOperativosVtColumna.fkEmpresa: fkEmpresa,
      PrElementosOperativosVtColumna.empresa: empresa,
      PrElementosOperativosVtColumna.fkSede: fkSede,
      PrElementosOperativosVtColumna.sede: sede,
      PrElementosOperativosVtColumna.categoria: categoria,
      PrElementosOperativosVtColumna.tipoOperativo: tipoOperativo,
      PrElementosOperativosVtColumna.nombre: nombre,
      PrElementosOperativosVtColumna.descripcion: descripcion,
      PrElementosOperativosVtColumna.color: color,
      PrElementosOperativosVtColumna.prioridad: prioridad,
      PrElementosOperativosVtColumna.activo: activo,
      PrElementosOperativosVtColumna.fechaCreacion: fechaCreacion,
      PrElementosOperativosVtColumna.fechaActualizacion: fechaActualizacion,
    },
    ordenarPor: ordenarPor,
    tramo: tramo,
  );
}
