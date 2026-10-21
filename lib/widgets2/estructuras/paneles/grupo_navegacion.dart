/// Responsabilidad: Describir un grupo de opciones del panel de navegacion
/// (por ejemplo Formularios, Informes, Herramientas).
library;

import 'package:trackmape_sup/widgets2/estructuras/paneles/opcion_navegacion.dart';

class GrupoNavegacion {
  const GrupoNavegacion({required this.titulo, required this.opciones});

  final String titulo;
  final List<OpcionNavegacion> opciones;
}
