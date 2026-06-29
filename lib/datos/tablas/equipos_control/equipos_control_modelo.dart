// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class EquiposControlModelo implements ModeloContrato {
  final String id_equipo_control;
  final String fk_empresa;
  final String? fk_sede;
  final String? nombre;
  final String? ubicacion;
  final String? id_equipo_fabrica;
  final String? tipo_equipo_control;
  final String? codigo_equipo_control;
  final String? direccion_mac;
  final String? observaciones;
  final String? fk_area_asociada;
  final String? fk_equipo_asociado;
  final DateTime? fecha_inicio;
  final DateTime? fecha_final;

  const EquiposControlModelo({
    required this.id_equipo_control,
    required this.fk_empresa,
    this.fk_sede,
    this.nombre,
    this.ubicacion,
    this.id_equipo_fabrica,
    this.tipo_equipo_control,
    this.codigo_equipo_control,
    this.direccion_mac,
    this.observaciones,
    this.fk_area_asociada,
    this.fk_equipo_asociado,
    this.fecha_inicio,
    this.fecha_final,
  });

  @override
  EquiposControlModelo copyWith({
    String? id_equipo_control,
    String? fk_empresa,
    String? fk_sede,
    String? nombre,
    String? ubicacion,
    String? id_equipo_fabrica,
    String? tipo_equipo_control,
    String? codigo_equipo_control,
    String? direccion_mac,
    String? observaciones,
    String? fk_area_asociada,
    String? fk_equipo_asociado,
    DateTime? fecha_inicio,
    DateTime? fecha_final,
  }) {
    return EquiposControlModelo(
      id_equipo_control: id_equipo_control ?? this.id_equipo_control,
      fk_empresa: fk_empresa ?? this.fk_empresa,
      fk_sede: fk_sede ?? this.fk_sede,
      nombre: nombre ?? this.nombre,
      ubicacion: ubicacion ?? this.ubicacion,
      id_equipo_fabrica: id_equipo_fabrica ?? this.id_equipo_fabrica,
      tipo_equipo_control: tipo_equipo_control ?? this.tipo_equipo_control,
      codigo_equipo_control:
          codigo_equipo_control ?? this.codigo_equipo_control,
      direccion_mac: direccion_mac ?? this.direccion_mac,
      observaciones: observaciones ?? this.observaciones,
      fk_area_asociada: fk_area_asociada ?? this.fk_area_asociada,
      fk_equipo_asociado: fk_equipo_asociado ?? this.fk_equipo_asociado,
      fecha_inicio: fecha_inicio ?? this.fecha_inicio,
      fecha_final: fecha_final ?? this.fecha_final,
    );
  }
}
