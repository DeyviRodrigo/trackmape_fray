// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class ContratoModelo implements ModeloContrato {
  final String id_contrato;
  final String fk_trabajador;
  final String cargo;
  final String? tipo_contrato;
  final DateTime fecha_inicio;
  final DateTime? fecha_fin;
  final double? remuneracion;
  final String? frecuencia_pago;
  final String? fk_moneda;
  final String? documento_url;
  final String? observacion;
  final Map<String, dynamic>? columnas_extras;
  final String? turno;
  final String? modalidad;
  final String? sistema;

  const ContratoModelo({
    required this.id_contrato,
    required this.fk_trabajador,
    required this.cargo,
    this.tipo_contrato,
    required this.fecha_inicio,
    this.fecha_fin,
    this.remuneracion,
    this.frecuencia_pago,
    this.fk_moneda,
    this.documento_url,
    this.observacion,
    this.columnas_extras,
    this.turno,
    this.modalidad,
    this.sistema,
  });

  @override
  ContratoModelo copyWith({
    String? id_contrato,
    String? fk_trabajador,
    String? cargo,
    String? tipo_contrato,
    DateTime? fecha_inicio,
    DateTime? fecha_fin,
    double? remuneracion,
    String? frecuencia_pago,
    String? fk_moneda,
    String? documento_url,
    String? observacion,
    Map<String, dynamic>? columnas_extras,
    String? turno,
    String? modalidad,
    String? sistema,
  }) {
    return ContratoModelo(
      id_contrato: id_contrato ?? this.id_contrato,
      fk_trabajador: fk_trabajador ?? this.fk_trabajador,
      cargo: cargo ?? this.cargo,
      tipo_contrato: tipo_contrato ?? this.tipo_contrato,
      fecha_inicio: fecha_inicio ?? this.fecha_inicio,
      fecha_fin: fecha_fin ?? this.fecha_fin,
      remuneracion: remuneracion ?? this.remuneracion,
      frecuencia_pago: frecuencia_pago ?? this.frecuencia_pago,
      fk_moneda: fk_moneda ?? this.fk_moneda,
      documento_url: documento_url ?? this.documento_url,
      observacion: observacion ?? this.observacion,
      columnas_extras: columnas_extras ?? this.columnas_extras,
      turno: turno ?? this.turno,
      modalidad: modalidad ?? this.modalidad,
      sistema: sistema ?? this.sistema,
    );
  }
}
