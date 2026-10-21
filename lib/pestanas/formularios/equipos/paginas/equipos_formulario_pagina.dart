/// Responsabilidad: Pagina del formulario de equipo, para alta (id nulo) o
/// edicion.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trackmape_sup/recursos2/temas/textos_app.dart';
import 'package:trackmape_sup/recursos2/temas/tono_estado.dart';
import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/recursos2/tokens/tamanos.dart';
import 'package:trackmape_sup/widgets2/componentes/estados/mensaje_estado.dart';
import 'package:trackmape_sup/widgets2/componentes/formularios/campo_fecha.dart';
import 'package:trackmape_sup/widgets2/componentes/formularios/campo_seleccion.dart';
import 'package:trackmape_sup/widgets2/estructuras/paginas/pagina.dart';
import 'package:trackmape_sup/widgets2/estructuras/secciones/seccion.dart';
import 'package:trackmape_sup/widgets2/estructuras/zonas/zona_contenido.dart';
import 'package:trackmape_sup/widgets2/estructuras/zonas/zona_encabezado.dart';
import 'package:trackmape_sup/widgets2/estructuras/zonas/zona_pie.dart';
import 'package:trackmape_sup/widgets2/primitivas/acciones/boton.dart';
import 'package:trackmape_sup/widgets2/primitivas/acciones/boton_icono.dart';
import 'package:trackmape_sup/widgets2/primitivas/acciones/variante_boton.dart';
import 'package:trackmape_sup/widgets2/primitivas/entradas/campo_texto.dart';
import 'package:trackmape_sup/widgets2/soporte/acceso_tema.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/controladores/formulario/equipos_formulario_controlador.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/proveedores/equipos_formulario_proveedor.dart';

class EquiposFormularioPagina extends ConsumerWidget {
  const EquiposFormularioPagina({
    super.key,
    required this.id,
    required this.alCerrar,
    required this.alGuardar,
  });

  /// Nulo = alta.
  final String? id;

  /// La pestana pregunta si hay cambios sin guardar antes de cerrar.
  final VoidCallback alCerrar;
  final VoidCallback alGuardar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formulario = ref.watch(equiposFormularioProveedor(id));

    return Pagina(
      encabezado: ZonaEncabezado(
        titulo: id == null ? 'Nuevo equipo' : 'Editar equipo',
        acciones: [
          BotonIcono(icono: Icons.close, ayuda: 'Cerrar', alPulsar: alCerrar),
        ],
      ),
      contenido: ZonaContenido(
        desplazable: true,
        child: formulario.cargando && formulario.formulario == null
            ? const MensajeEstado.cargando()
            : _campos(context, formulario),
      ),
      pie: ZonaPie(
        child: Row(
          spacing: Espaciado.pequeno,
          children: [
            Expanded(
              child: Boton(
                texto: 'Cancelar',
                variante: VarianteBoton.contorno,
                alPulsar: alCerrar,
              ),
            ),
            Expanded(
              child: Boton(
                texto: formulario.guardando ? 'Guardando…' : 'Guardar',
                alPulsar: formulario.guardando || formulario.cargando
                    ? null
                    : () => _guardar(formulario),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar(EquiposFormularioControlador formulario) async {
    if (await formulario.guardar()) alGuardar();
  }

  Widget _campos(BuildContext context, EquiposFormularioControlador f) {
    final campos = f.campos;
    final problema = f.errorFormulario ?? f.error;
    final hoy = DateTime.now();

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: TamanosSuperficie.lecturaMaxima,
      ),
      child: Seccion(
        titulo: 'Datos del equipo',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Espaciado.base,
          children: [
            if (problema != null)
              Text(
                problema,
                style: context.textos.cuerpo.copyWith(
                  color: TonoEstado.error.colores(context.colores).base,
                ),
              ),
            CampoSeleccion(
              etiqueta: 'Empresa *',
              opciones: f.empresas,
              etiquetar: (empresa) => empresa.nombre,
              valor: campos.empresa,
              alCambiar: f.elegirEmpresa,
              error: f.errorDe('empresa'),
            ),
            CampoSeleccion(
              etiqueta: 'Sede',
              opciones: f.sedes,
              etiquetar: (sede) => sede.nombre,
              valor: campos.sede,
              alCambiar: f.elegirSede,
              habilitado: campos.empresa != null,
            ),
            CampoTexto(
              etiqueta: 'Nombre *',
              controlador: campos.nombreControlador,
              error: f.errorDe('nombre'),
              alCambiar: (_) => f.marcarCambiosPendientes(),
            ),
            CampoTexto(
              etiqueta: 'Código *',
              controlador: campos.codigoControlador,
              error: f.errorDe('codigo'),
              alCambiar: (_) => f.marcarCambiosPendientes(),
            ),
            CampoTexto(
              etiqueta: 'Tipo *',
              ayuda: 'Por ejemplo: SEEED WIO TRACKER L1',
              controlador: campos.tipoControlador,
              error: f.errorDe('tipo'),
              alCambiar: (_) => f.marcarCambiosPendientes(),
            ),
            CampoTexto(
              etiqueta: 'ID de fábrica',
              controlador: campos.idFabricaControlador,
              alCambiar: (_) => f.marcarCambiosPendientes(),
            ),
            CampoTexto(
              etiqueta: 'Dirección MAC',
              controlador: campos.direccionMacControlador,
              error: f.errorDe('direccionMac'),
              alCambiar: (_) => f.marcarCambiosPendientes(),
            ),
            CampoFecha(
              etiqueta: 'En servicio desde',
              valor: campos.fechaInicio,
              alCambiar: f.elegirFechaInicio,
              primera: DateTime(2015),
              ultima: DateTime(hoy.year + 1, 12, 31),
            ),
            CampoTexto(
              etiqueta: 'Observaciones',
              controlador: campos.observacionesControlador,
              lineas: 3,
              alCambiar: (_) => f.marcarCambiosPendientes(),
            ),
          ],
        ),
      ),
    );
  }
}
