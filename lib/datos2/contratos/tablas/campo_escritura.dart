/// Responsabilidad: Distinguir un campo omitido de uno incluido en una
/// escritura, incluido el nulo explicito cuando el tipo lo admite.
///
/// Es lo que permite actualizar solo lo que cambio: un campo ausente no se
/// envia y la columna conserva su valor; un campo con valor nulo la vacia.
library;

final class CampoEscritura<T> {
  // AUSENTE - No se envia: la columna no se toca
  const CampoEscritura.ausente() : this._(false, null);

  // VALOR - Se envia, incluido nulo si el tipo lo admite
  const CampoEscritura.valor(T valor) : this._(true, valor);

  const CampoEscritura._(this.presente, this.valor);

  final bool presente;
  final T? valor;
}
