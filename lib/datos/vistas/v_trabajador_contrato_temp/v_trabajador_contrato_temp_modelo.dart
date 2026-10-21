// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class VTrabajadorContratoTempModelo implements ModeloContrato {
  final String id_contrato;
  final String fk_trabajador;
  final String cargo;
  final String? tipo_contrato;
  final DateTime fecha_inicio;
  final DateTime? fecha_fin;
  final double? remuneracion;
  final String? frecuencia_pago;
  final String? turno;
  final String? modalidad;
  final String? sistema;
  final String? documento_url;
  final String? observacion;
  final String? moneda_codigo;
  final String? nombre_moneda;
  final String? moneda_simbolo;

  const VTrabajadorContratoTempModelo({
    required this.id_contrato,
    required this.fk_trabajador,
    required this.cargo,
    this.tipo_contrato,
    required this.fecha_inicio,
    this.fecha_fin,
    this.remuneracion,
    this.frecuencia_pago,
    this.turno,
    this.modalidad,
    this.sistema,
    this.documento_url,
    this.observacion,
    this.moneda_codigo,
    this.nombre_moneda,
    this.moneda_simbolo,
  });

  @override
  VTrabajadorContratoTempModelo copyWith({
    String? id_contrato,
    String? fk_trabajador,
    String? cargo,
    String? tipo_contrato,
    DateTime? fecha_inicio,
    DateTime? fecha_fin,
    double? remuneracion,
    String? frecuencia_pago,
    String? turno,
    String? modalidad,
    String? sistema,
    String? documento_url,
    String? observacion,
    String? moneda_codigo,
    String? nombre_moneda,
    String? moneda_simbolo,
  }) {
    return VTrabajadorContratoTempModelo(
      id_contrato: id_contrato ?? this.id_contrato,
      fk_trabajador: fk_trabajador ?? this.fk_trabajador,
      cargo: cargo ?? this.cargo,
      tipo_contrato: tipo_contrato ?? this.tipo_contrato,
      fecha_inicio: fecha_inicio ?? this.fecha_inicio,
      fecha_fin: fecha_fin ?? this.fecha_fin,
      remuneracion: remuneracion ?? this.remuneracion,
      frecuencia_pago: frecuencia_pago ?? this.frecuencia_pago,
      turno: turno ?? this.turno,
      modalidad: modalidad ?? this.modalidad,
      sistema: sistema ?? this.sistema,
      documento_url: documento_url ?? this.documento_url,
      observacion: observacion ?? this.observacion,
      moneda_codigo: moneda_codigo ?? this.moneda_codigo,
      nombre_moneda: nombre_moneda ?? this.nombre_moneda,
      moneda_simbolo: moneda_simbolo ?? this.moneda_simbolo,
    );
  }
}
