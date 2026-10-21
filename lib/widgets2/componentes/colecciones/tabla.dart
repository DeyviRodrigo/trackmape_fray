/// Responsabilidad: Mostrar filas en columnas con titulos fijos arriba. Tocar
/// una fila avisa cual se eligio; no hay botones por fila.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/temas/textos_app.dart';
import 'package:trackmape_sup/recursos2/tokens/bordes.dart';
import 'package:trackmape_sup/recursos2/tokens/espaciado.dart';
import 'package:trackmape_sup/recursos2/tokens/tamanos.dart';
import 'package:trackmape_sup/widgets2/componentes/colecciones/columna_tabla.dart';
import 'package:trackmape_sup/widgets2/soporte/acceso_tema.dart';

class Tabla<T> extends StatelessWidget {
  const Tabla({
    super.key,
    required this.columnas,
    required this.filas,
    this.alSeleccionar,
    this.esSeleccionada,
  });

  final List<ColumnaTabla<T>> columnas;
  final List<T> filas;
  final ValueChanged<T>? alSeleccionar;

  /// Marca la fila abierta en el detalle.
  final bool Function(T fila)? esSeleccionada;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final linea = Border(
      bottom: BorderSide(color: c.bordeSutil, width: Grosores.fino),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(border: linea),
          child: _fila([
            for (final columna in columnas)
              Text(
                columna.titulo,
                style: context.textos.etiquetaPequena.copyWith(
                  color: c.textoSecundario,
                ),
              ),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filas.length,
            itemBuilder: (context, i) {
              final fila = filas[i];
              final seleccionada = esSeleccionada?.call(fila) ?? false;
              return Material(
                color: seleccionada ? c.seleccionado : Colors.transparent,
                child: InkWell(
                  onTap: alSeleccionar == null
                      ? null
                      : () => alSeleccionar!(fila),
                  child: Container(
                    decoration: BoxDecoration(border: linea),
                    child: _fila([
                      for (final columna in columnas) columna.celda(fila),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _fila(List<Widget> celdas) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: TamanosControl.alturaBase,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Espaciado.medio,
          vertical: Espaciado.pequeno,
        ),
        child: Row(
          spacing: Espaciado.medio,
          children: [
            for (var i = 0; i < celdas.length; i++)
              Expanded(
                flex: columnas[i].proporcion,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: celdas[i],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
