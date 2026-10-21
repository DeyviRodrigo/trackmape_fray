/// Responsabilidad: Pagina de listado de equipos: busqueda y filtros, tabla,
/// Agregar y barra de estado.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trackmape_sup/recursos2/temas/tono_estado.dart';
import 'package:trackmape_sup/widgets2/componentes/estados/mensaje_estado.dart';
import 'package:trackmape_sup/widgets2/estructuras/paginas/pagina_listado.dart';
import 'package:trackmape_sup/widgets2/estructuras/subzonas/subzona_acciones_flotantes.dart';
import 'package:trackmape_sup/widgets2/estructuras/subzonas/subzona_acciones_superiores.dart';
import 'package:trackmape_sup/widgets2/estructuras/subzonas/subzona_barra_estado.dart';
import 'package:trackmape_sup/widgets2/estructuras/subzonas/subzona_visualizacion.dart';
import 'package:trackmape_sup/widgets2/estructuras/zonas/zona_encabezado.dart';
import 'package:trackmape_sup/widgets2/primitivas/acciones/boton.dart';
import 'package:trackmape_sup/widgets2/primitivas/acciones/boton_flotante.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/componentes/equipos_filtros.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/componentes/equipos_tabla.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/controladores/data/equipos_datos_controlador.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/proveedores/equipos_datos_proveedor.dart';

class EquiposDatosPagina extends ConsumerWidget {
  const EquiposDatosPagina({
    super.key,
    required this.seleccionadoId,
    required this.alSeleccionar,
    required this.alAgregar,
  });

  final String? seleccionadoId;
  final ValueChanged<String> alSeleccionar;
  final VoidCallback alAgregar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(equiposDatosProveedor);

    return PaginaListado(
      encabezado: const ZonaEncabezado(titulo: 'Equipos'),
      accionesSuperiores: SubzonaAccionesSuperiores(
        acciones: [
          Expanded(
            child: EquiposFiltros(
              tipos: datos.tiposDisponibles,
              tipo: datos.tipo,
              estado: datos.estado,
              alBuscar: datos.buscar,
              alElegirTipo: datos.elegirTipo,
              alElegirEstado: datos.elegirEstado,
            ),
          ),
        ],
      ),
      visualizacion: SubzonaVisualizacion(child: _visualizacion(datos)),
      accionesFlotantes: SubzonaAccionesFlotantes(
        acciones: [
          BotonFlotante(
            icono: Icons.add,
            ayuda: 'Agregar equipo',
            alPulsar: alAgregar,
          ),
        ],
      ),
      barraEstado: SubzonaBarraEstado(datos: _resumen(datos)),
    );
  }

  Widget _visualizacion(EquiposDatosControlador datos) {
    final error = datos.error;
    if (datos.cargando) return const MensajeEstado.cargando();
    if (error != null) {
      return MensajeEstado(
        titulo: 'No se pudieron cargar los equipos',
        descripcion: error,
        tono: TonoEstado.error,
        accion: Boton(texto: 'Reintentar', alPulsar: datos.cargar),
      );
    }
    if (datos.registros.isEmpty) {
      return const MensajeEstado(
        titulo: 'Sin resultados',
        descripcion: 'Ningún equipo coincide con la búsqueda o los filtros.',
      );
    }
    return EquiposTabla(
      registros: datos.registros,
      seleccionadoId: seleccionadoId,
      alSeleccionar: alSeleccionar,
    );
  }

  List<String> _resumen(EquiposDatosControlador datos) {
    final mostrados = datos.registros.length;
    final tipo = datos.tipo;
    final estado = datos.estado;
    return [
      mostrados == datos.total
          ? '${datos.total} equipos'
          : '$mostrados de ${datos.total} equipos',
      '${datos.finalizados} finalizados',
      if (tipo != null) 'Tipo: $tipo',
      if (estado != null) 'Estado: ${estado.etiqueta}',
      'Por nombre ↑',
    ];
  }
}
