/// Responsabilidad: Seccion "Datos del equipo" del detalle.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/temas/tono_estado.dart';
import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/widgets2/componentes/contenido/dato_etiquetado.dart';
import 'package:trackmape_sup/widgets2/estructuras/secciones/seccion.dart';
import 'package:trackmape_sup/widgets2/primitivas/contenido/insignia_estado.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/equipo_detalle_vista.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/estado_equipo.dart';

class EquipoDatosSeccion extends StatelessWidget {
  const EquipoDatosSeccion({super.key, required this.equipo});

  final EquipoDetalleVista equipo;

  @override
  Widget build(BuildContext context) {
    final vigente = equipo.estado == EstadoEquipo.vigente;
    return Seccion(
      titulo: 'Datos del equipo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: Espaciado.pequeno),
            child: InsigniaEstado(
              texto: equipo.estado.etiqueta,
              tono: vigente ? TonoEstado.exito : TonoEstado.neutro,
            ),
          ),
          DatoEtiquetado(etiqueta: 'Código', valor: equipo.codigo),
          DatoEtiquetado(etiqueta: 'Tipo', valor: equipo.tipo),
          DatoEtiquetado(etiqueta: 'Empresa', valor: equipo.empresa),
          DatoEtiquetado(etiqueta: 'Sede', valor: equipo.sede),
          DatoEtiquetado(
            etiqueta: 'En servicio desde',
            valor: equipo.enServicioDesde,
          ),
          if (!vigente)
            DatoEtiquetado(
              etiqueta: 'Dado de baja el',
              valor: equipo.finalizadoEl,
            ),
          DatoEtiquetado(etiqueta: 'ID de fábrica', valor: equipo.idFabrica),
          DatoEtiquetado(etiqueta: 'Dirección MAC', valor: equipo.direccionMac),
          DatoEtiquetado(
            etiqueta: 'Observaciones',
            valor: equipo.observaciones,
          ),
        ],
      ),
    );
  }
}
