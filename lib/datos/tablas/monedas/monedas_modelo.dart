// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class MonedasModelo implements ModeloContrato {
  final String id_moneda;
  final String codigo;
  final String nombre_moneda;
  final String? simbolo;
  final int decimales;
  final bool activo;
  final String? fk_pais_emisor;

  const MonedasModelo({
    required this.id_moneda,
    required this.codigo,
    required this.nombre_moneda,
    this.simbolo,
    required this.decimales,
    required this.activo,
    this.fk_pais_emisor,
  });

  @override
  MonedasModelo copyWith({
    String? id_moneda,
    String? codigo,
    String? nombre_moneda,
    String? simbolo,
    int? decimales,
    bool? activo,
    String? fk_pais_emisor,
  }) {
    return MonedasModelo(
      id_moneda: id_moneda ?? this.id_moneda,
      codigo: codigo ?? this.codigo,
      nombre_moneda: nombre_moneda ?? this.nombre_moneda,
      simbolo: simbolo ?? this.simbolo,
      decimales: decimales ?? this.decimales,
      activo: activo ?? this.activo,
      fk_pais_emisor: fk_pais_emisor ?? this.fk_pais_emisor,
    );
  }
}
