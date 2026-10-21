/// Responsabilidad: Declarar como se puede consultar posiciones_temp_vt: un filtro por
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

// POSICIONES TEMP VT COLUMNA - Columnas de la vista con su nombre en la base
enum PosicionesTempVtColumna implements ColumnaVista {
  idPosicion('id_posicion'),
  tiempo('tiempo'),
  fkReceptor('fk_receptor'),
  fkEmisor('fk_emisor'),
  epocaRx('epoca_rx'),
  latGrados('lat_grados'),
  lonGrados('lon_grados'),
  altMsnmM('alt_msnm_m'),
  haeM('hae_m'),
  geoM('geo_m'),
  pdop('pdop'),
  hdop('hdop'),
  vdop('vdop'),
  largoPayload('largo_payload');

  const PosicionesTempVtColumna(this.nombrePostgresql);

  @override
  final String nombrePostgresql;
}

// POSICIONES TEMP VT CONSULTA - Filtros, orden y tramo de la vista
class PosicionesTempVtConsulta {
  const PosicionesTempVtConsulta({
    this.idPosicion = const CampoConsultaVista.ausente(),
    this.tiempo = const CampoConsultaVista.ausente(),
    this.fkReceptor = const CampoConsultaVista.ausente(),
    this.fkEmisor = const CampoConsultaVista.ausente(),
    this.epocaRx = const CampoConsultaVista.ausente(),
    this.latGrados = const CampoConsultaVista.ausente(),
    this.lonGrados = const CampoConsultaVista.ausente(),
    this.altMsnmM = const CampoConsultaVista.ausente(),
    this.haeM = const CampoConsultaVista.ausente(),
    this.geoM = const CampoConsultaVista.ausente(),
    this.pdop = const CampoConsultaVista.ausente(),
    this.hdop = const CampoConsultaVista.ausente(),
    this.vdop = const CampoConsultaVista.ausente(),
    this.largoPayload = const CampoConsultaVista.ausente(),
    this.ordenarPor = const [],
    this.tramo,
  });

  final CampoConsultaVista<String> idPosicion;
  final CampoConsultaVista<DateTime> tiempo;
  final CampoConsultaVista<String> fkReceptor;
  final CampoConsultaVista<String> fkEmisor;
  final CampoConsultaVista<int> epocaRx;
  final CampoConsultaVista<double> latGrados;
  final CampoConsultaVista<double> lonGrados;
  final CampoConsultaVista<int> altMsnmM;
  final CampoConsultaVista<int> haeM;
  final CampoConsultaVista<int> geoM;
  final CampoConsultaVista<double> pdop;
  final CampoConsultaVista<double> hdop;
  final CampoConsultaVista<double> vdop;
  final CampoConsultaVista<int> largoPayload;

  // ORDENAR POR - Criterios de orden, aplicados en el orden de la lista
  final List<OrdenConsultaVista<PosicionesTempVtColumna>> ordenarPor;

  // TRAMO - Un maximo o una pagina de registros, o ninguno
  final TramoConsulta? tramo;

  // A FORMULARIO LECTURA - La hoja que recibe el mensajero
  FormularioLectura aFormularioLectura() => armarFormularioLectura(
    campos: {
      PosicionesTempVtColumna.idPosicion: idPosicion,
      PosicionesTempVtColumna.tiempo: tiempo,
      PosicionesTempVtColumna.fkReceptor: fkReceptor,
      PosicionesTempVtColumna.fkEmisor: fkEmisor,
      PosicionesTempVtColumna.epocaRx: epocaRx,
      PosicionesTempVtColumna.latGrados: latGrados,
      PosicionesTempVtColumna.lonGrados: lonGrados,
      PosicionesTempVtColumna.altMsnmM: altMsnmM,
      PosicionesTempVtColumna.haeM: haeM,
      PosicionesTempVtColumna.geoM: geoM,
      PosicionesTempVtColumna.pdop: pdop,
      PosicionesTempVtColumna.hdop: hdop,
      PosicionesTempVtColumna.vdop: vdop,
      PosicionesTempVtColumna.largoPayload: largoPayload,
    },
    ordenarPor: ordenarPor,
    tramo: tramo,
  );
}
