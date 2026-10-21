/// Responsabilidad: Rodear las pestanas con el panel de navegacion: recuerda
/// si esta ampliado (horizontal) o desplegado (vertical) y lleva a la ruta del
/// modulo elegido.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trackmape_sup/app2/navegacion/modulos_menu.dart';
import 'package:trackmape_sup/widgets2/estructuras/esquemas/navegacion_esquema.dart';
import 'package:trackmape_sup/widgets2/estructuras/paneles/panel_navegacion.dart';

class MarcoNavegacion extends StatefulWidget {
  const MarcoNavegacion({
    super.key,
    required this.rutaActual,
    required this.child,
  });

  final String rutaActual;
  final Widget child;

  @override
  State<MarcoNavegacion> createState() => _MarcoNavegacionState();
}

class _MarcoNavegacionState extends State<MarcoNavegacion> {
  // Horizontal: arranca ampliado y empuja el contenido.
  bool _ampliada = true;

  // Vertical: abierto encima del contenido.
  bool _desplegada = false;

  void _alternar() => setState(() {
    if (_desplegada) {
      _desplegada = false;
    } else {
      _ampliada = !_ampliada;
    }
  });

  void _desplegar() => setState(() => _desplegada = true);
  void _plegar() => setState(() => _desplegada = false);

  void _elegir(String ruta) {
    setState(() => _desplegada = false);
    context.go(ruta);
  }

  @override
  Widget build(BuildContext context) {
    return NavegacionEsquema(
      desplegada: _desplegada,
      alDesplegar: _desplegar,
      alPlegar: _plegar,
      panel: PanelNavegacion(
        nombreAplicacion: 'TrackMAPE',
        iconoAplicacion: Icons.local_shipping,
        grupos: ModulosMenu.grupos,
        pie: ModulosMenu.pie,
        idActivo: ModulosMenu.activo(widget.rutaActual),
        // Desplegado en vertical siempre se muestra completo.
        ampliado: _ampliada || _desplegada,
        alAlternar: _alternar,
        alElegir: _elegir,
      ),
      child: widget.child,
    );
  }
}
