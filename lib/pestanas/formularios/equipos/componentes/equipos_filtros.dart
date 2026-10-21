/// Responsabilidad: Busqueda y filtros del listado de equipos (tipo y
/// estado). Solo muestra y avisa; el controlador filtra.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/widgets2/componentes/formularios/campo_busqueda.dart';
import 'package:trackmape_sup/widgets2/componentes/formularios/filtro_opciones.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/estado_equipo.dart';

class EquiposFiltros extends StatelessWidget {
  const EquiposFiltros({
    super.key,
    required this.tipos,
    required this.tipo,
    required this.estado,
    required this.alBuscar,
    required this.alElegirTipo,
    required this.alElegirEstado,
  });

  final List<String> tipos;
  final String? tipo;
  final EstadoEquipo? estado;
  final ValueChanged<String> alBuscar;
  final ValueChanged<String?> alElegirTipo;
  final ValueChanged<EstadoEquipo?> alElegirEstado;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: Espaciado.pequeno,
      children: [
        Expanded(
          child: CampoBusqueda(
            pista: 'Buscar por nombre o código',
            alCambiar: alBuscar,
          ),
        ),
        FiltroOpciones<String>(
          etiqueta: 'Tipo',
          opciones: tipos,
          etiquetar: (valor) => valor,
          seleccionada: tipo,
          alElegir: alElegirTipo,
        ),
        FiltroOpciones<EstadoEquipo>(
          etiqueta: 'Estado',
          opciones: EstadoEquipo.values,
          etiquetar: (valor) => valor.etiqueta,
          seleccionada: estado,
          alElegir: alElegirEstado,
        ),
      ],
    );
  }
}
