/// Responsabilidad: Boton con texto (y opcionalmente icono) en una de las
/// variantes de [VarianteBoton]. Sin `alPulsar` queda deshabilitado.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/temas/textos_app.dart';
import 'package:trackmape_sup/recursos2/tokens/bordes.dart';
import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/recursos2/tokens/radios.dart';
import 'package:trackmape_sup/recursos2/tokens/tamanos.dart';
import 'package:trackmape_sup/widgets2/primitivas/acciones/variante_boton.dart';
import 'package:trackmape_sup/widgets2/soporte/acceso_tema.dart';

class Boton extends StatelessWidget {
  const Boton({
    super.key,
    required this.texto,
    required this.alPulsar,
    this.variante = VarianteBoton.primario,
    this.icono,
  });

  final String texto;
  final VoidCallback? alPulsar;
  final VarianteBoton variante;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final activos = variante.colores(c);
    final inactivos = variante.colores(c, habilitado: false);

    final estilo = TextButton.styleFrom(
      backgroundColor: activos.fondo,
      foregroundColor: activos.contenido,
      disabledBackgroundColor: inactivos.fondo,
      disabledForegroundColor: inactivos.contenido,
      minimumSize: const Size(0, TamanosControl.alturaBase),
      padding: const EdgeInsets.symmetric(horizontal: Espaciado.base),
      textStyle: context.textos.etiqueta,
      shape: RoundedRectangleBorder(
        borderRadius: RadiosBorde.pequeno,
        side: BorderSide(
          color: alPulsar == null ? inactivos.borde : activos.borde,
          width: Grosores.fino,
        ),
      ),
    );

    final icono = this.icono;
    if (icono == null) {
      return TextButton(onPressed: alPulsar, style: estilo, child: Text(texto));
    }
    return TextButton.icon(
      onPressed: alPulsar,
      style: estilo,
      icon: Icon(icono, size: TamanosIcono.medio),
      label: Text(texto),
    );
  }
}
