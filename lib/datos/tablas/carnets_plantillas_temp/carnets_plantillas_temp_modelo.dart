// ignore_for_file: non_constant_identifier_names
import 'package:trackmape_sup/datos/interfaces/modelo_contrato.dart';

class CarnetsPlantillasTempModelo implements ModeloContrato {
  final String id_plantilla;
  final String? fk_empresa;
  final String? fk_sede;
  final String nombre;
  final String orientacion;
  final String? fondo_url;
  final String? logo_url;
  final List<Map<String, dynamic>> campos;
  final DateTime fecha_creacion;
  final DateTime? fecha_eliminacion;

  const CarnetsPlantillasTempModelo({
    required this.id_plantilla,
    this.fk_empresa,
    this.fk_sede,
    required this.nombre,
    this.orientacion = 'horizontal',
    this.fondo_url,
    this.logo_url,
    required this.campos,
    required this.fecha_creacion,
    this.fecha_eliminacion,
  });

  @override
  CarnetsPlantillasTempModelo copyWith({
    String? fk_empresa,
    String? fk_sede,
    String? nombre,
    String? orientacion,
    String? fondo_url,
    String? logo_url,
    List<Map<String, dynamic>>? campos,
    DateTime? fecha_eliminacion,
  }) {
    return CarnetsPlantillasTempModelo(
      id_plantilla: id_plantilla,
      fk_empresa: fk_empresa ?? this.fk_empresa,
      fk_sede: fk_sede ?? this.fk_sede,
      nombre: nombre ?? this.nombre,
      orientacion: orientacion ?? this.orientacion,
      fondo_url: fondo_url ?? this.fondo_url,
      logo_url: logo_url ?? this.logo_url,
      campos: campos ?? this.campos,
      fecha_creacion: fecha_creacion,
      fecha_eliminacion: fecha_eliminacion ?? this.fecha_eliminacion,
    );
  }
}
