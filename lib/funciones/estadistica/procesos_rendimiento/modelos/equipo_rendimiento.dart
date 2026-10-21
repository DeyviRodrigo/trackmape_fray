class EquipoRendimiento {
  final String idEquipoControl;
  final String codigoEquipoControl;
  final String nombre;

  const EquipoRendimiento({
    required this.idEquipoControl,
    required this.codigoEquipoControl,
    required this.nombre,
  });

  String get etiquetaVisible =>
      nombre.trim().isNotEmpty ? nombre.trim() : codigoEquipoControl;
}
