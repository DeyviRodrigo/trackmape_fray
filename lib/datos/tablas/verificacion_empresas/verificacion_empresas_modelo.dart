// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class VerificacionEmpresasModelo implements ModeloContrato {
  final String id_verificacion_empresa;
  final String? fk_empresa;
  final bool? verificado;
  final String? fuente_verificacion;
  final DateTime? fecha_verificacion;

  const VerificacionEmpresasModelo({
    required this.id_verificacion_empresa,
    this.fk_empresa,
    this.verificado,
    this.fuente_verificacion,
    this.fecha_verificacion,
  });

  @override
  VerificacionEmpresasModelo copyWith({
    String? id_verificacion_empresa,
    String? fk_empresa,
    bool? verificado,
    String? fuente_verificacion,
    DateTime? fecha_verificacion,
  }) {
    return VerificacionEmpresasModelo(
      id_verificacion_empresa:
          id_verificacion_empresa ?? this.id_verificacion_empresa,
      fk_empresa: fk_empresa ?? this.fk_empresa,
      verificado: verificado ?? this.verificado,
      fuente_verificacion: fuente_verificacion ?? this.fuente_verificacion,
      fecha_verificacion: fecha_verificacion ?? this.fecha_verificacion,
    );
  }
}
