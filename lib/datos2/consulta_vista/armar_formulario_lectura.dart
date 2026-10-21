/// Responsabilidad: Convertir los filtros, el orden y el tramo de la consulta
/// de una vista en la hoja FormularioLectura.
///
/// Es la conversion comun a todas las vistas: la consulta de cada vista solo
/// enumera sus columnas y llama a esta funcion, en vez de repetir el armado.
library;

import 'package:trackmape_sup/app2/conexion_backend/contratos/formulario_lectura.dart';
import 'package:trackmape_sup/datos2/consulta_vista/campo_consulta_vista.dart';
import 'package:trackmape_sup/datos2/consulta_vista/columna_vista.dart';
import 'package:trackmape_sup/datos2/consulta_vista/modo_campo_consulta.dart';
import 'package:trackmape_sup/datos2/consulta_vista/orden_consulta_vista.dart';

// ARMAR FORMULARIO LECTURA - Cada columna va a la casilla que indica su modo
FormularioLectura armarFormularioLectura({
  required Map<ColumnaVista, CampoConsultaVista<Object>> campos,
  List<OrdenConsultaVista<ColumnaVista>> ordenarPor = const [],
  TramoConsulta? tramo,
}) {
  final igualA = <String, Object>{};
  final entre = <String, RangoConsulta>{};
  final enLista = <String, List<Object>>{};
  final igualONulo = <String, Object>{};

  for (final MapEntry(key: columna, value: campo) in campos.entries) {
    final nombre = columna.nombrePostgresql;
    switch (campo.modo) {
      case ModoCampoConsulta.ausente:
        break;
      case ModoCampoConsulta.igualA:
        igualA[nombre] = campo.valor!;
      case ModoCampoConsulta.entre:
        entre[nombre] = RangoConsulta(desde: campo.valor!, hasta: campo.hasta!);
      case ModoCampoConsulta.enLista:
        enLista[nombre] = List<Object>.of(campo.valores);
      case ModoCampoConsulta.igualONulo:
        igualONulo[nombre] = campo.valor!;
    }
  }

  return FormularioLectura(
    igualA: igualA,
    entre: entre,
    enLista: enLista,
    igualONulo: igualONulo,
    ordenarPor: [
      for (final orden in ordenarPor)
        OrdenConsulta(
          orden.columna.nombrePostgresql,
          ascendente: orden.ascendente,
        ),
    ],
    tramo: tramo,
  );
}
