import 'package:flutter/material.dart';
import 'package:trackmape_sup/app/tokens/tokens_sistema.dart';
import 'package:trackmape_sup/widgets/atomos/nivel1/icono_atomo.dart';
import 'package:trackmape_sup/widgets/atomos/nivel1/texto_atomo.dart';

class SeccionUsuarioMol extends StatelessWidget {
  final String nombre;
  final String rol;
  final VoidCallback? onCerrarSesion;

  const SeccionUsuarioMol({
    super.key,
    required this.nombre,
    required this.rol,
    this.onCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ColoresApp.fondoPrimario,
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.medio),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: ColoresApp.acento.withValues(alpha: 0.18),
              child: const IconoAtomo(
                icono: Iconos.sesion,
                contexto: ContextoIcono.normal,
              ),
            ),
            const SizedBox(width: Espaciado.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextoAtomo(texto: nombre, contexto: ContextoTexto.subtitulo),
                  TextoAtomo(texto: rol, contexto: ContextoTexto.secundario),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Cerrar sesion',
              onPressed: onCerrarSesion,
              icon: const IconoAtomo(
                icono: Iconos.cerrarSesion,
                contexto: ContextoIcono.peligro,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
