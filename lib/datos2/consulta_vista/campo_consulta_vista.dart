/// Responsabilidad: Representar el filtro de una columna dentro de la consulta
/// de una vista, con un valor del tipo de esa columna.
library;

import 'package:trackmape_sup/datos2/consulta_vista/modo_campo_consulta.dart';

// CAMPO CONSULTA VISTA - Un filtro por columna, o ninguno
final class CampoConsultaVista<T extends Object> {
  // AUSENTE - La columna no restringe la consulta
  const CampoConsultaVista.ausente() : this._(ModoCampoConsulta.ausente);

  // IGUAL A - La columna vale exactamente el valor
  const CampoConsultaVista.igualA(T valor)
    : this._(ModoCampoConsulta.igualA, valor: valor);

  // ENTRE - La columna esta dentro del rango, ambos limites incluidos
  const CampoConsultaVista.entre(T desde, T hasta)
    : this._(ModoCampoConsulta.entre, valor: desde, hasta: hasta);

  // EN LISTA - La columna vale cualquiera de los valores
  const CampoConsultaVista.enLista(List<T> valores)
    : this._(ModoCampoConsulta.enLista, valores: valores);

  // IGUAL O NULO - La columna vale el valor o no tiene valor
  const CampoConsultaVista.igualONulo(T valor)
    : this._(ModoCampoConsulta.igualONulo, valor: valor);

  const CampoConsultaVista._(
    this.modo, {
    this.valor,
    this.hasta,
    this.valores = const [],
  });

  final ModoCampoConsulta modo;

  // Valor de igualA e igualONulo, o limite inferior de entre
  final T? valor;

  // Limite superior de entre
  final T? hasta;

  // Valores de enLista
  final List<T> valores;
}
