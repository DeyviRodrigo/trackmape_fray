// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class PaisesModelo implements ModeloContrato {
  final String id_pais;
  final String iso2;
  final String iso3;
  final String nombre_pais;
  final String? prefijo_tel;
  final String? fk_moneda_pred;
  final bool activo;
  final String? fk_idioma_pred;

  const PaisesModelo({
    required this.id_pais,
    required this.iso2,
    required this.iso3,
    required this.nombre_pais,
    this.prefijo_tel,
    this.fk_moneda_pred,
    required this.activo,
    this.fk_idioma_pred,
  });

  @override
  PaisesModelo copyWith({
    String? id_pais,
    String? iso2,
    String? iso3,
    String? nombre_pais,
    String? prefijo_tel,
    String? fk_moneda_pred,
    bool? activo,
    String? fk_idioma_pred,
  }) {
    return PaisesModelo(
      id_pais: id_pais ?? this.id_pais,
      iso2: iso2 ?? this.iso2,
      iso3: iso3 ?? this.iso3,
      nombre_pais: nombre_pais ?? this.nombre_pais,
      prefijo_tel: prefijo_tel ?? this.prefijo_tel,
      fk_moneda_pred: fk_moneda_pred ?? this.fk_moneda_pred,
      activo: activo ?? this.activo,
      fk_idioma_pred: fk_idioma_pred ?? this.fk_idioma_pred,
    );
  }
}
