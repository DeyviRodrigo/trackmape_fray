/// Responsabilidad: Panel de navegacion. Comprimido es una cinta de iconos;
/// ampliado muestra logo, nombre, las opciones agrupadas y un pie. Solo
/// muestra y avisa: quien lo usa decide a donde ir.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/temas/textos_app.dart';
import 'package:trackmape_sup/recursos2/tokens/bordes.dart';
import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/recursos2/tokens/movimiento.dart';
import 'package:trackmape_sup/recursos2/tokens/radios.dart';
import 'package:trackmape_sup/recursos2/tokens/tamanos.dart';
import 'package:trackmape_sup/widgets2/estructuras/paneles/grupo_navegacion.dart';
import 'package:trackmape_sup/widgets2/estructuras/paneles/opcion_navegacion.dart';
import 'package:trackmape_sup/widgets2/soporte/acceso_tema.dart';

class PanelNavegacion extends StatelessWidget {
  const PanelNavegacion({
    super.key,
    required this.nombreAplicacion,
    required this.iconoAplicacion,
    required this.grupos,
    required this.idActivo,
    required this.ampliado,
    required this.alAlternar,
    required this.alElegir,
    this.pie = const [],
  });

  final String nombreAplicacion;
  final IconData iconoAplicacion;
  final List<GrupoNavegacion> grupos;
  final String? idActivo;
  final bool ampliado;

  /// Al pulsar el logo: amplia o comprime.
  final VoidCallback alAlternar;
  final ValueChanged<String> alElegir;

  /// Opciones fijas abajo (preferencias, sesion...).
  final List<OpcionNavegacion> pie;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return LayoutBuilder(
      builder: (context, restricciones) {
        // No ocupa toda la pantalla si sobra espacio.
        final ancho = ampliado
            ? TamanosSuperficie.navegacionExpandida.clamp(
                0.0,
                restricciones.maxWidth,
              )
            : TamanosSuperficie.navegacionComprimida;
        return AnimatedContainer(
          duration: Duraciones.media,
          curve: Curvas.estandar,
          width: ancho,
          decoration: BoxDecoration(
            color: c.superficie,
            border: Border(
              right: BorderSide(color: c.bordeSutil, width: Grosores.fino),
            ),
          ),
          child: ClipRect(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Logo(
                  nombre: nombreAplicacion,
                  icono: iconoAplicacion,
                  ampliado: ampliado,
                  alPulsar: alAlternar,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      vertical: Espaciado.pequeno,
                    ),
                    children: [
                      for (final grupo in grupos) ..._grupo(context, grupo),
                    ],
                  ),
                ),
                if (pie.isNotEmpty) ...[
                  Divider(color: c.bordeSutil),
                  for (final opcion in pie) _opcion(opcion),
                  const SizedBox(height: Espaciado.pequeno),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _grupo(BuildContext context, GrupoNavegacion grupo) => [
    if (ampliado)
      Padding(
        padding: const EdgeInsets.fromLTRB(
          Espaciado.base,
          Espaciado.base,
          Espaciado.base,
          Espaciado.minimo,
        ),
        child: Text(
          grupo.titulo.toUpperCase(),
          style: context.textos.micro.copyWith(
            color: context.colores.textoTerciario,
          ),
        ),
      )
    else
      const Divider(indent: Espaciado.base, endIndent: Espaciado.base),
    for (final opcion in grupo.opciones) _opcion(opcion),
  ];

  Widget _opcion(OpcionNavegacion opcion) => _ItemNavegacion(
    opcion: opcion,
    activo: opcion.id == idActivo,
    ampliado: ampliado,
    alPulsar: () => alElegir(opcion.id),
  );
}

class _Logo extends StatelessWidget {
  const _Logo({
    required this.nombre,
    required this.icono,
    required this.ampliado,
    required this.alPulsar,
  });

  final String nombre;
  final IconData icono;
  final bool ampliado;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Tooltip(
      message: ampliado ? 'Comprimir menú' : 'Ampliar menú',
      child: InkWell(
        onTap: alPulsar,
        child: SizedBox(
          height: TamanosControl.alturaBase + Espaciado.pequeno * 2,
          child: Row(
            children: [
              const SizedBox(width: Espaciado.amplio),
              Icon(icono, color: c.primario, size: TamanosIcono.grande),
              if (ampliado) ...[
                const SizedBox(width: Espaciado.medio),
                Expanded(
                  child: Text(
                    nombre,
                    style: context.textos.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemNavegacion extends StatelessWidget {
  const _ItemNavegacion({
    required this.opcion,
    required this.activo,
    required this.ampliado,
    required this.alPulsar,
  });

  final OpcionNavegacion opcion;
  final bool activo;
  final bool ampliado;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final color = activo ? c.primario : c.textoSecundario;
    final item = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Espaciado.pequeno,
        vertical: Espaciado.micro,
      ),
      child: Material(
        color: activo ? c.seleccionado : Colors.transparent,
        borderRadius: RadiosBorde.pequeno,
        child: InkWell(
          borderRadius: RadiosBorde.pequeno,
          onTap: alPulsar,
          child: SizedBox(
            height: TamanosControl.alturaBase,
            child: Row(
              children: [
                const SizedBox(width: Espaciado.base),
                Icon(opcion.icono, color: color),
                if (ampliado) ...[
                  const SizedBox(width: Espaciado.medio),
                  Expanded(
                    child: Text(
                      opcion.etiqueta,
                      style: context.textos.etiqueta.copyWith(
                        color: activo ? c.textoPrimario : c.textoSecundario,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    // Comprimido, la ayuda es lo unico que dice que es cada icono.
    return ampliado ? item : Tooltip(message: opcion.etiqueta, child: item);
  }
}
