/// Responsabilidad: Representar una fila de la vista equipos_control_vt (equipos de control).
library;

// EQUIPOS CONTROL VT MODELO - Una fila de la vista, con sus tipos de Dart
class EquiposControlVtModelo {
  const EquiposControlVtModelo({
    required this.idEquipoControl,
    required this.fkEmpresa,
    this.empresa,
    this.fkSede,
    this.sede,
    this.nombre,
    this.ubicacion,
    this.idEquipoFabrica,
    this.tipoEquipoControl,
    this.codigoEquipoControl,
    this.direccionMac,
    this.observaciones,
    this.fkAreaAsociada,
    this.fkEquipoAsociado,
    this.fechaInicio,
    this.fechaFinal,
  });

  final String idEquipoControl;
  final String fkEmpresa;
  final String? empresa;
  final String? fkSede;
  final String? sede;
  final String? nombre;
  final String? ubicacion;
  final String? idEquipoFabrica;
  final String? tipoEquipoControl;
  final String? codigoEquipoControl;
  final String? direccionMac;
  final String? observaciones;
  final String? fkAreaAsociada;
  final String? fkEquipoAsociado;
  final DateTime? fechaInicio;
  final DateTime? fechaFinal;
}
