/// Responsabilidad: Mostrar los equipos en la tabla del listado con sus
/// columnas: tipo, nombre, codigo, sede y estado.
library;

import 'package:flutter/material.dart';

import 'package:trackmape_sup/recursos2/temas/tono_estado.dart';
import 'package:trackmape_sup/widgets2/componentes/colecciones/columna_tabla.dart';
import 'package:trackmape_sup/widgets2/componentes/colecciones/tabla.dart';
import 'package:trackmape_sup/widgets2/primitivas/contenido/insignia_estado.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/equipo_item_vista.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/estado_equipo.dart';

class EquiposTabla extends StatelessWidget {
  const EquiposTabla({
    super.key,
    required this.registros,
    required this.seleccionadoId,
    required this.alSeleccionar,
  });

  final List<EquipoItemVista> registros;
  final String? seleccionadoId;
  final ValueChanged<String> alSeleccionar;

  @override
  Widget build(BuildContext context) {
    return Tabla<EquipoItemVista>(
      filas: registros,
      alSeleccionar: (fila) => alSeleccionar(fila.id),
      esSeleccionada: (fila) => fila.id == seleccionadoId,
      columnas: [
        ColumnaTabla(titulo: 'Tipo', celda: (fila) => _texto(fila.tipo)),
        ColumnaTabla(
          titulo: 'Nombre',
          proporcion: 2,
          celda: (fila) => _texto(fila.nombre),
        ),
        ColumnaTabla(titulo: 'Código', celda: (fila) => _texto(fila.codigo)),
        ColumnaTabla(titulo: 'Sede', celda: (fila) => _texto(fila.sede)),
        ColumnaTabla(
          titulo: 'Estado',
          celda: (fila) => InsigniaEstado(
            texto: fila.estado.etiqueta,
            tono: fila.estado == EstadoEquipo.vigente
                ? TonoEstado.exito
                : TonoEstado.neutro,
          ),
        ),
      ],
    );
  }

  static Widget _texto(String valor) =>
      Text(valor, maxLines: 1, overflow: TextOverflow.ellipsis);
}
