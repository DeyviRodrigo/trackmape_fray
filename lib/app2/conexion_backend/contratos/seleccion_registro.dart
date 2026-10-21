/// Responsabilidad: Elegir a que registro (o registros) se aplica una
/// escritura sobre datos existentes: actualizar, desactivar o activar.
///
/// Es el segundo paso de esas escrituras: el primero dice que se cambia y a
/// que valor; este dice a quien. La primera condicion es obligatoria en la
/// firma: sin ella la escritura alcanzaria todos los registros de la tabla, y
/// asi no se puede escribir. Solo admite igualdad, para no alcanzar de mas.
library;

// SELECCION REGISTRO - Una condicion obligatoria y las adicionales
final class SeleccionRegistro {
  const SeleccionRegistro(
    this.campo,
    this.valor, {
    this.adicionales = const {},
  });

  // Condicion obligatoria: campo igual a valor (normalmente, su id)
  final String campo;
  final Object valor;

  // Condiciones adicionales, todas de igualdad y todas a la vez
  final Map<String, Object> adicionales;

  // TODAS - Las condiciones juntas, la obligatoria primero
  Map<String, Object> get todas => {campo: valor, ...adicionales};
}
