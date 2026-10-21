/// Responsabilidad: Traducir lo que se le pide a la base al idioma del cliente
/// de Supabase: las casillas de FormularioLectura (lectura) y la seleccion de
/// registro (escritura).
///
/// Solo traduce. Lo que no sea traducir una peticion no pertenece aqui.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trackmape_sup/app2/conexion_backend/contratos/formulario_lectura.dart';

// TRADUCTOR PETICION - Formulario y seleccion expresados en Supabase
class TraductorPeticion {
  TraductorPeticion._();

  // FILTROS - igual a, entre, en lista e igual o nulo; se cumplen todos a la vez
  static PostgrestFilterBuilder<PostgrestList> aplicarFiltros(
    PostgrestFilterBuilder<PostgrestList> peticion,
    FormularioLectura consulta,
  ) {
    var resultado = peticion;

    for (final condicion in consulta.igualA.entries) {
      resultado = resultado.eq(condicion.key, valor(condicion.value));
    }

    for (final condicion in consulta.entre.entries) {
      resultado = resultado
          .gte(condicion.key, valor(condicion.value.desde))
          .lte(condicion.key, valor(condicion.value.hasta));
    }

    for (final condicion in consulta.enLista.entries) {
      resultado = resultado.inFilter(
        condicion.key,
        condicion.value.map(valor).toList(),
      );
    }

    for (final condicion in consulta.igualONulo.entries) {
      final campo = condicion.key;
      final entreComillas = _valorEntreComillas(condicion.value);
      resultado = resultado.or('$campo.is.null,$campo.eq.$entreComillas');
    }

    return resultado;
  }

  // ORDEN - Cada criterio se suma al anterior, en el orden de la lista
  static PostgrestTransformBuilder<PostgrestList> aplicarOrden(
    PostgrestTransformBuilder<PostgrestList> peticion,
    FormularioLectura consulta,
  ) {
    var resultado = peticion;
    for (final orden in consulta.ordenarPor) {
      resultado = resultado.order(orden.campo, ascending: orden.ascendente);
    }
    return resultado;
  }

  // TRAMO - Un maximo o una pagina, o ninguno
  static PostgrestTransformBuilder<PostgrestList> aplicarTramo(
    PostgrestTransformBuilder<PostgrestList> peticion,
    FormularioLectura consulta,
  ) {
    return switch (consulta.tramo) {
      null => peticion,
      MaximoConsulta(:final cantidad) => peticion.limit(cantidad),
      PaginaConsulta(:final desde, :final hasta) => peticion.range(
        desde,
        hasta,
      ),
    };
  }

  // CONDICIONES DE ESCRITURA - Solo igualdad, para no alcanzar filas de mas
  static PostgrestFilterBuilder<T> aplicarCondiciones<T>(
    PostgrestFilterBuilder<T> peticion,
    Map<String, Object> condiciones,
  ) {
    var resultado = peticion;
    for (final condicion in condiciones.entries) {
      resultado = resultado.eq(condicion.key, valor(condicion.value));
    }
    return resultado;
  }

  // VALOR - Formato de envio a PostgREST.
  // Las fechas viajan en ISO 8601 sin convertir de zona: las columnas de
  // tiempo de la base son timestamp without time zone y guardan hora local.
  static Object valor(Object valor) =>
      valor is DateTime ? valor.toIso8601String() : valor;

  // Dentro de un filtro "or" las comas y parentesis separan condiciones, asi
  // que el valor va entre comillas dobles con sus caracteres especiales
  // escapados.
  static String _valorEntreComillas(Object valorOriginal) {
    final texto = valor(
      valorOriginal,
    ).toString().replaceAll(r'\', r'\\').replaceAll('"', r'\"');
    return '"$texto"';
  }
}
