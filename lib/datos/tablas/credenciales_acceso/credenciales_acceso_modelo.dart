// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class CredencialesAccesoModelo implements ModeloContrato {
  final String id_credencial;
  final String fk_trabajador;
  final String tecnologia;
  final String valor;
  final String? clave;
  final bool activo;

  const CredencialesAccesoModelo({
    required this.id_credencial,
    required this.fk_trabajador,
    required this.tecnologia,
    required this.valor,
    this.clave,
    required this.activo,
  });

  @override
  CredencialesAccesoModelo copyWith({
    String? id_credencial,
    String? fk_trabajador,
    String? tecnologia,
    String? valor,
    String? clave,
    bool? activo,
  }) {
    return CredencialesAccesoModelo(
      id_credencial: id_credencial ?? this.id_credencial,
      fk_trabajador: fk_trabajador ?? this.fk_trabajador,
      tecnologia: tecnologia ?? this.tecnologia,
      valor: valor ?? this.valor,
      clave: clave ?? this.clave,
      activo: activo ?? this.activo,
    );
  }
}
