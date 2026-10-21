/// Responsabilidad: Nombrar los estados de un equipo. Sale de fecha_final:
/// sin fecha final esta vigente; con fecha final fue dado de baja.
library;

enum EstadoEquipo {
  vigente('Vigente'),
  finalizado('Finalizado');

  const EstadoEquipo(this.etiqueta);

  final String etiqueta;

  static EstadoEquipo desde(DateTime? fechaFinal) =>
      fechaFinal == null ? vigente : finalizado;
}
