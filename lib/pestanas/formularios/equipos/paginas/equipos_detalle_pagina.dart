/// Responsabilidad: Pagina de detalle de un equipo con sus acciones: editar,
/// dar de baja, ver en vivo y cerrar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_stream.dart';
import 'package:trackmape_sup/recursos2/temas/tono_estado.dart';
import 'package:trackmape_sup/widgets2/componentes/estados/mensaje_estado.dart';
import 'package:trackmape_sup/widgets2/estructuras/paginas/pagina.dart';
import 'package:trackmape_sup/widgets2/estructuras/zonas/zona_contenido.dart';
import 'package:trackmape_sup/widgets2/estructuras/zonas/zona_encabezado.dart';
import 'package:trackmape_sup/widgets2/primitivas/acciones/boton.dart';
import 'package:trackmape_sup/widgets2/primitivas/acciones/boton_icono.dart';
import 'package:trackmape_sup/widgets2/ventanas/notificaciones/aviso.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/componentes/equipo_datos_seccion.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/controladores/detalle/equipos_detalle_controlador.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/proveedores/equipos_detalle_proveedor.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/equipo_detalle_vista.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/estado_equipo.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/ventanas/equipos_dar_baja_ventana.dart';

class EquiposDetallePagina extends ConsumerWidget {
  const EquiposDetallePagina({
    super.key,
    required this.id,
    required this.alCerrar,
    required this.alEditar,
    required this.alDarDeBaja,
  });

  final String id;
  final VoidCallback alCerrar;
  final VoidCallback alEditar;

  /// Avisa a la pestana para que refresque el listado.
  final VoidCallback alDarDeBaja;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detalle = ref.watch(equiposDetalleProveedor(id));
    final equipo = detalle.registro;

    return Pagina(
      encabezado: ZonaEncabezado(
        titulo: equipo == null ? 'Equipo' : equipo.nombre,
        acciones: [
          if (equipo != null) ...[
            BotonIcono(
              icono: Icons.edit_outlined,
              ayuda: 'Editar',
              alPulsar: alEditar,
            ),
            if (equipo.estado == EstadoEquipo.vigente)
              BotonIcono(
                icono: Icons.block,
                ayuda: 'Dar de baja',
                alPulsar: detalle.guardando
                    ? null
                    : () => _darDeBaja(context, detalle, equipo),
              ),
            BotonIcono(
              icono: Icons.sensors,
              ayuda: 'Ver en vivo',
              alPulsar: () => _verEnVivo(context, equipo),
            ),
          ],
          BotonIcono(icono: Icons.close, ayuda: 'Cerrar', alPulsar: alCerrar),
        ],
      ),
      contenido: ZonaContenido(
        desplazable: true,
        child: _contenido(detalle, equipo),
      ),
    );
  }

  Widget _contenido(
    EquiposDetalleControlador detalle,
    EquipoDetalleVista? equipo,
  ) {
    final error = detalle.error;
    if (detalle.cargando && equipo == null) {
      return const MensajeEstado.cargando();
    }
    if (error != null && equipo == null) {
      return MensajeEstado(
        titulo: 'No se pudo cargar el equipo',
        descripcion: error,
        tono: TonoEstado.error,
        accion: Boton(texto: 'Reintentar', alPulsar: detalle.cargar),
      );
    }
    if (equipo == null) {
      return const MensajeEstado(
        titulo: 'Equipo no encontrado',
        descripcion: 'Puede que ya no exista.',
      );
    }
    return EquipoDatosSeccion(equipo: equipo);
  }

  Future<void> _darDeBaja(
    BuildContext context,
    EquiposDetalleControlador detalle,
    EquipoDetalleVista equipo,
  ) async {
    final confirmado = await EquiposDarBajaVentana.mostrar(
      context,
      equipo.nombre,
    );
    if (!confirmado) return;
    final hecho = await detalle.darBaja();
    if (!context.mounted) return;
    if (hecho) {
      Aviso.mostrar(context, '${equipo.nombre} dado de baja');
      alDarDeBaja();
    } else {
      Aviso.mostrar(
        context,
        detalle.error ?? 'No se pudo dar de baja.',
        tono: TonoEstado.error,
      );
    }
  }

  void _verEnVivo(BuildContext context, EquipoDetalleVista equipo) {
    // Pantalla anterior del monitoreo, ya filtrable a un equipo. Se reemplaza
    // cuando se migre Monitoreo en Vivo.
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => PaginaStream(
          equipoIdFiltro: equipo.id,
          nombreEquipoFiltro: equipo.nombre,
          empresaFiltro: equipo.fkEmpresa,
        ),
      ),
    );
  }
}
