/// Responsabilidad: Definir la hoja de consulta que una fuente llena y entrega
/// al mensajero para leer registros.
///
/// Cada campo es una casilla. Una casilla vacia no restringe nada, asi que una
/// consulta sin casillas marcadas trae todos los registros. Solo existen las
/// casillas que la aplicacion usa; una nueva se agrega cuando aparece su caso.
///
/// La hoja es parte del contrato del backend: no depende de Supabase. Todo
/// mensajero concreto debe saber traducir cada casilla.
library;

// FORMULARIO LECTURA - Hoja de pedido de lectura con sus casillas
class FormularioLectura {
  const FormularioLectura({
    this.igualA = const {},
    this.entre = const {},
    this.enLista = const {},
    this.igualONulo = const {},
    this.ordenarPor = const [],
    this.tramo,
  });

  // IGUAL A - Campo igual al valor. Varias casillas se cumplen todas a la vez
  final Map<String, Object> igualA;

  // ENTRE - Campo dentro del rango, ambos limites incluidos
  final Map<String, RangoConsulta> entre;

  // EN LISTA - Campo igual a cualquiera de los valores
  final Map<String, List<Object>> enLista;

  // IGUAL O NULO - Campo igual al valor o sin valor
  final Map<String, Object> igualONulo;

  // ORDENAR POR - Criterios de orden, aplicados en el orden de la lista
  final List<OrdenConsulta> ordenarPor;

  // TRAMO - Cuantos registros traer: un maximo o una pagina, nunca los dos.
  // Es una sola casilla a proposito: pedir las dos cantidades a la vez no se
  // puede escribir.
  final TramoConsulta? tramo;

  // ESTA VACIA - Ninguna casilla marcada: la consulta trae todos los registros
  bool get estaVacia =>
      igualA.isEmpty &&
      entre.isEmpty &&
      enLista.isEmpty &&
      igualONulo.isEmpty &&
      ordenarPor.isEmpty &&
      tramo == null;
}

// RANGO CONSULTA - Limites de la casilla entre, ambos incluidos
class RangoConsulta {
  const RangoConsulta({required this.desde, required this.hasta});

  final Object desde;
  final Object hasta;
}

// ORDEN CONSULTA - Un criterio de la casilla ordenar por
class OrdenConsulta {
  const OrdenConsulta(this.campo, {this.ascendente = true});

  final String campo;
  final bool ascendente;
}

// TRAMO CONSULTA - Las dos formas de limitar cuantos registros se traen.
// Es cerrada (sealed): no existe una tercera forma ni una que combine las dos.
sealed class TramoConsulta {
  const TramoConsulta();
}

// MAXIMO CONSULTA - Como mucho esa cantidad de registros
final class MaximoConsulta extends TramoConsulta {
  const MaximoConsulta(this.cantidad);

  final int cantidad;
}

// PAGINA CONSULTA - Registros por posicion, ambos extremos incluidos
//
// La primera fila es la posicion 0: desde 0 hasta 999 trae las primeras mil.
final class PaginaConsulta extends TramoConsulta {
  const PaginaConsulta({required this.desde, required this.hasta});

  final int desde;
  final int hasta;
}
