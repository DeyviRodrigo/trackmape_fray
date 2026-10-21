/// Responsabilidad: Resolver el alta o la edicion segun corresponda.
library;

import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/acciones/equipos_actualizar_accion.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/acciones/equipos_insertar_accion.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/controladores/formulario/equipos_formulario_campos.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/transformadores/a_comando/equipo_formulario_comando_transformador.dart';

class EquiposGuardarServicio {
  final _insertar = EquiposInsertarAccion();
  final _actualizar = EquiposActualizarAccion();

  Future<void> ejecutar(String? id, EquiposFormularioCampos campos) async {
    if (id == null) {
      await _insertar.ejecutar(
        EquipoFormularioComandoTransformador.insertar(campos),
      );
      return;
    }
    await _actualizar.ejecutar(
      id,
      EquipoFormularioComandoTransformador.actualizar(campos),
    );
  }
}
