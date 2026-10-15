class RangoConsultaTemporal {
  const RangoConsultaTemporal({required this.inicio, required this.fin});

  final DateTime inicio;
  final DateTime fin;
}

abstract final class RelojAplicacion {
  static const bool modoHistorico = bool.fromEnvironment(
    'MODO_CORTE_HISTORICO',
    defaultValue: false,
  );

  static const String _fechaHoraCorteCruda = String.fromEnvironment(
    'FECHA_HORA_CORTE',
    defaultValue: '',
  );

  static DateTime get ahora {
    if (!modoHistorico) return DateTime.now();

    final fecha = DateTime.tryParse(_fechaHoraCorteCruda);
    if (fecha == null) {
      throw StateError(
        'MODO_CORTE_HISTORICO requiere FECHA_HORA_CORTE en formato '
        'yyyy-MM-ddTHH:mm:ss.',
      );
    }
    return fecha;
  }

  /// En el armado historico toda solicitud queda fijada al dia del corte.
  static DateTime fechaConsulta(DateTime fechaSolicitada) {
    return modoHistorico ? ahora : fechaSolicitada;
  }

  static RangoConsultaTemporal rangoDelDia(DateTime fechaSolicitada) {
    final fecha = fechaConsulta(fechaSolicitada);
    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = modoHistorico
        ? ahora
        : DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59, 999);
    return RangoConsultaTemporal(inicio: inicio, fin: fin);
  }

  static bool esDiaActual(DateTime fecha) {
    final referencia = ahora;
    return fecha.year == referencia.year &&
        fecha.month == referencia.month &&
        fecha.day == referencia.day;
  }
}
