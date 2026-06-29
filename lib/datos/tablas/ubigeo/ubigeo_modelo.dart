// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class UbigeoModelo implements ModeloContrato {
  final String id_ubigeo;
  final String? fk_pais;
  final String? fk_nivel;
  final String? fk_padre;
  final String? nombre;
  final int? codigo;
  final Map<String, dynamic>? codigos_adicionales;
  final bool? activo;

  const UbigeoModelo({
    required this.id_ubigeo,
    this.fk_pais,
    this.fk_nivel,
    this.fk_padre,
    this.nombre,
    this.codigo,
    this.codigos_adicionales,
    this.activo,
  });

  @override
  UbigeoModelo copyWith({
    String? id_ubigeo,
    String? fk_pais,
    String? fk_nivel,
    String? fk_padre,
    String? nombre,
    int? codigo,
    Map<String, dynamic>? codigos_adicionales,
    bool? activo,
  }) {
    return UbigeoModelo(
      id_ubigeo: id_ubigeo ?? this.id_ubigeo,
      fk_pais: fk_pais ?? this.fk_pais,
      fk_nivel: fk_nivel ?? this.fk_nivel,
      fk_padre: fk_padre ?? this.fk_padre,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      codigos_adicionales: codigos_adicionales ?? this.codigos_adicionales,
      activo: activo ?? this.activo,
    );
  }
}
