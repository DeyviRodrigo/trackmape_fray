// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class NivelesUbigeoModelo implements ModeloContrato {
  final String id_nivel_ubigeo;
  final String? fk_pais;
  final String nombre_nivel;
  final int nivel;
  final bool activo;

  const NivelesUbigeoModelo({
    required this.id_nivel_ubigeo,
    this.fk_pais,
    required this.nombre_nivel,
    required this.nivel,
    required this.activo,
  });

  @override
  NivelesUbigeoModelo copyWith({
    String? id_nivel_ubigeo,
    String? fk_pais,
    String? nombre_nivel,
    int? nivel,
    bool? activo,
  }) {
    return NivelesUbigeoModelo(
      id_nivel_ubigeo: id_nivel_ubigeo ?? this.id_nivel_ubigeo,
      fk_pais: fk_pais ?? this.fk_pais,
      nombre_nivel: nombre_nivel ?? this.nombre_nivel,
      nivel: nivel ?? this.nivel,
      activo: activo ?? this.activo,
    );
  }
}
