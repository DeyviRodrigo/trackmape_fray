// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class IdiomasModelo implements ModeloContrato {
  final String codigo;
  final String nombre_idioma;
  final bool activo;

  const IdiomasModelo({
    required this.codigo,
    required this.nombre_idioma,
    required this.activo,
  });

  @override
  IdiomasModelo copyWith({
    String? codigo,
    String? nombre_idioma,
    bool? activo,
  }) {
    return IdiomasModelo(
      codigo: codigo ?? this.codigo,
      nombre_idioma: nombre_idioma ?? this.nombre_idioma,
      activo: activo ?? this.activo,
    );
  }
}
