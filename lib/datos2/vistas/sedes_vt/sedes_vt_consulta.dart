/// Responsabilidad: Declarar como se puede consultar sedes_vt: un filtro por
/// cada columna de la vista, el orden y el tramo.
///
/// Es espejo de la vista: tiene todas sus columnas, se usen o no. Cada pestana
/// marca solo lo que necesita; un filtro ausente no restringe.
///
/// Las columnas jsonb (columnas_extras) no se filtran ni ordenan:
/// no tienen una igualdad ni un orden con sentido.
library;

import 'package:trackmape_sup/app2/conexion_backend/contratos/formulario_lectura.dart';
import 'package:trackmape_sup/datos2/consulta_vista/armar_formulario_lectura.dart';
import 'package:trackmape_sup/datos2/consulta_vista/campo_consulta_vista.dart';
import 'package:trackmape_sup/datos2/consulta_vista/columna_vista.dart';
import 'package:trackmape_sup/datos2/consulta_vista/orden_consulta_vista.dart';

// SEDES VT COLUMNA - Columnas de la vista con su nombre en la base
enum SedesVtColumna implements ColumnaVista {
  idSede('id_sede'),
  fkEmpresa('fk_empresa'),
  empresa('empresa'),
  nombre('nombre'),
  tipoSede('tipo_sede'),
  fkResponsable('fk_responsable'),
  celular('celular'),
  email('email'),
  paginaWeb('pagina_web'),
  logoUrl('logo_url'),
  fkUbigeo('fk_ubigeo'),
  direccion('direccion'),
  activo('activo'),
  zonaHoraria('zona_horaria');

  const SedesVtColumna(this.nombrePostgresql);

  @override
  final String nombrePostgresql;
}

// SEDES VT CONSULTA - Filtros, orden y tramo de la vista
class SedesVtConsulta {
  const SedesVtConsulta({
    this.idSede = const CampoConsultaVista.ausente(),
    this.fkEmpresa = const CampoConsultaVista.ausente(),
    this.empresa = const CampoConsultaVista.ausente(),
    this.nombre = const CampoConsultaVista.ausente(),
    this.tipoSede = const CampoConsultaVista.ausente(),
    this.fkResponsable = const CampoConsultaVista.ausente(),
    this.celular = const CampoConsultaVista.ausente(),
    this.email = const CampoConsultaVista.ausente(),
    this.paginaWeb = const CampoConsultaVista.ausente(),
    this.logoUrl = const CampoConsultaVista.ausente(),
    this.fkUbigeo = const CampoConsultaVista.ausente(),
    this.direccion = const CampoConsultaVista.ausente(),
    this.activo = const CampoConsultaVista.ausente(),
    this.zonaHoraria = const CampoConsultaVista.ausente(),
    this.ordenarPor = const [],
    this.tramo,
  });

  final CampoConsultaVista<String> idSede;
  final CampoConsultaVista<String> fkEmpresa;
  final CampoConsultaVista<String> empresa;
  final CampoConsultaVista<String> nombre;
  final CampoConsultaVista<String> tipoSede;
  final CampoConsultaVista<String> fkResponsable;
  final CampoConsultaVista<String> celular;
  final CampoConsultaVista<String> email;
  final CampoConsultaVista<String> paginaWeb;
  final CampoConsultaVista<String> logoUrl;
  final CampoConsultaVista<String> fkUbigeo;
  final CampoConsultaVista<String> direccion;
  final CampoConsultaVista<bool> activo;
  final CampoConsultaVista<String> zonaHoraria;

  // ORDENAR POR - Criterios de orden, aplicados en el orden de la lista
  final List<OrdenConsultaVista<SedesVtColumna>> ordenarPor;

  // TRAMO - Un maximo o una pagina de registros, o ninguno
  final TramoConsulta? tramo;

  // A FORMULARIO LECTURA - La hoja que recibe el mensajero
  FormularioLectura aFormularioLectura() => armarFormularioLectura(
    campos: {
      SedesVtColumna.idSede: idSede,
      SedesVtColumna.fkEmpresa: fkEmpresa,
      SedesVtColumna.empresa: empresa,
      SedesVtColumna.nombre: nombre,
      SedesVtColumna.tipoSede: tipoSede,
      SedesVtColumna.fkResponsable: fkResponsable,
      SedesVtColumna.celular: celular,
      SedesVtColumna.email: email,
      SedesVtColumna.paginaWeb: paginaWeb,
      SedesVtColumna.logoUrl: logoUrl,
      SedesVtColumna.fkUbigeo: fkUbigeo,
      SedesVtColumna.direccion: direccion,
      SedesVtColumna.activo: activo,
      SedesVtColumna.zonaHoraria: zonaHoraria,
    },
    ordenarPor: ordenarPor,
    tramo: tramo,
  );
}
