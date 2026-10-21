/// Responsabilidad: Declarar como se puede consultar empresas_vt: un filtro por
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

// EMPRESAS VT COLUMNA - Columnas de la vista con su nombre en la base
enum EmpresasVtColumna implements ColumnaVista {
  idEmpresa('id_empresa'),
  fkPais('fk_pais'),
  fkTipoDoc('fk_tipo_doc'),
  numeroDocumento('numero_documento'),
  razonSocial('razon_social'),
  nombreComercial('nombre_comercial'),
  estado('estado'),
  condicion('condicion'),
  fkUbigeo('fk_ubigeo'),
  direccion('direccion'),
  fkResponsable('fk_responsable'),
  celular('celular'),
  email('email'),
  paginaWeb('pagina_web'),
  logoUrl('logo_url'),
  activo('activo');

  const EmpresasVtColumna(this.nombrePostgresql);

  @override
  final String nombrePostgresql;
}

// EMPRESAS VT CONSULTA - Filtros, orden y tramo de la vista
class EmpresasVtConsulta {
  const EmpresasVtConsulta({
    this.idEmpresa = const CampoConsultaVista.ausente(),
    this.fkPais = const CampoConsultaVista.ausente(),
    this.fkTipoDoc = const CampoConsultaVista.ausente(),
    this.numeroDocumento = const CampoConsultaVista.ausente(),
    this.razonSocial = const CampoConsultaVista.ausente(),
    this.nombreComercial = const CampoConsultaVista.ausente(),
    this.estado = const CampoConsultaVista.ausente(),
    this.condicion = const CampoConsultaVista.ausente(),
    this.fkUbigeo = const CampoConsultaVista.ausente(),
    this.direccion = const CampoConsultaVista.ausente(),
    this.fkResponsable = const CampoConsultaVista.ausente(),
    this.celular = const CampoConsultaVista.ausente(),
    this.email = const CampoConsultaVista.ausente(),
    this.paginaWeb = const CampoConsultaVista.ausente(),
    this.logoUrl = const CampoConsultaVista.ausente(),
    this.activo = const CampoConsultaVista.ausente(),
    this.ordenarPor = const [],
    this.tramo,
  });

  final CampoConsultaVista<String> idEmpresa;
  final CampoConsultaVista<String> fkPais;
  final CampoConsultaVista<String> fkTipoDoc;
  final CampoConsultaVista<String> numeroDocumento;
  final CampoConsultaVista<String> razonSocial;
  final CampoConsultaVista<String> nombreComercial;
  final CampoConsultaVista<String> estado;
  final CampoConsultaVista<String> condicion;
  final CampoConsultaVista<String> fkUbigeo;
  final CampoConsultaVista<String> direccion;
  final CampoConsultaVista<String> fkResponsable;
  final CampoConsultaVista<String> celular;
  final CampoConsultaVista<String> email;
  final CampoConsultaVista<String> paginaWeb;
  final CampoConsultaVista<String> logoUrl;
  final CampoConsultaVista<bool> activo;

  // ORDENAR POR - Criterios de orden, aplicados en el orden de la lista
  final List<OrdenConsultaVista<EmpresasVtColumna>> ordenarPor;

  // TRAMO - Un maximo o una pagina de registros, o ninguno
  final TramoConsulta? tramo;

  // A FORMULARIO LECTURA - La hoja que recibe el mensajero
  FormularioLectura aFormularioLectura() => armarFormularioLectura(
    campos: {
      EmpresasVtColumna.idEmpresa: idEmpresa,
      EmpresasVtColumna.fkPais: fkPais,
      EmpresasVtColumna.fkTipoDoc: fkTipoDoc,
      EmpresasVtColumna.numeroDocumento: numeroDocumento,
      EmpresasVtColumna.razonSocial: razonSocial,
      EmpresasVtColumna.nombreComercial: nombreComercial,
      EmpresasVtColumna.estado: estado,
      EmpresasVtColumna.condicion: condicion,
      EmpresasVtColumna.fkUbigeo: fkUbigeo,
      EmpresasVtColumna.direccion: direccion,
      EmpresasVtColumna.fkResponsable: fkResponsable,
      EmpresasVtColumna.celular: celular,
      EmpresasVtColumna.email: email,
      EmpresasVtColumna.paginaWeb: paginaWeb,
      EmpresasVtColumna.logoUrl: logoUrl,
      EmpresasVtColumna.activo: activo,
    },
    ordenarPor: ordenarPor,
    tramo: tramo,
  );
}
