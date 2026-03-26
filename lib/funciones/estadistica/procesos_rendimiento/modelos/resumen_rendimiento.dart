class ResumenRendimiento {
  final double distanciaTotalKm;
  final double tiempoDetenidoHoras;
  final double tiempoOperativoHoras;
  final double velocidadPromedioKmh;
  final double rendimientoKmh;
  final int puntosValidos;
  final int puntosDescartados;
  final int paradasDetectadas;

  const ResumenRendimiento({
    required this.distanciaTotalKm,
    required this.tiempoDetenidoHoras,
    required this.tiempoOperativoHoras,
    required this.velocidadPromedioKmh,
    required this.rendimientoKmh,
    required this.puntosValidos,
    required this.puntosDescartados,
    required this.paradasDetectadas,
  });
}
