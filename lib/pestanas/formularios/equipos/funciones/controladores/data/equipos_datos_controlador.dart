/// Responsabilidad: Sostener el listado de equipos, sus filtros y su
/// recalculo. Consulta una vez; buscar y filtrar operan en memoria.
library;

import 'package:trackmape_sup/datos2/vistas/equipos_control_vt/equipos_control_vt_modelo.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/filtros/equipos_buscar_filtro.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/filtros/equipos_estado_filtro.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/filtros/equipos_tipo_filtro.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/servicios/equipos_mostrar_datos_servicio.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/transformadores/a_vista/equipo_item_vista_transformador.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/equipo_item_vista.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/estado_equipo.dart';
import 'package:trackmape_sup/pestanas/general/funciones/controladores/controlador_presentacion.dart';

class EquiposDatosControlador extends ControladorPresentacion {
  EquiposDatosControlador() {
    cargando = true;
  }

  final _mostrarDatos = EquiposMostrarDatosServicio();
  final _buscar = EquiposBuscarFiltro();
  final _tipo = EquiposTipoFiltro();
  final _estado = EquiposEstadoFiltro();

  // DESCARGADO - Se consulta una vez; los criterios operan sobre esto.
  List<EquiposControlVtModelo> _descargados = [];
  List<EquipoItemVista> _todos = [];

  List<EquipoItemVista> registros = [];
  List<String> tiposDisponibles = [];

  String textoBusqueda = '';
  String? tipo;
  EstadoEquipo? estado;

  int get total => _todos.length;
  int get finalizados =>
      _todos.where((fila) => fila.estado == EstadoEquipo.finalizado).length;

  Future<void> cargar() => ejecutarCarga(() async {
    _descargados = await _mostrarDatos.ejecutar();
    _todos = EquipoItemVistaTransformador.transformarLista(_descargados);
    tiposDisponibles = _tipo.opciones(_todos);
    _recalcular();
  });

  void _recalcular() {
    final porTipo = _tipo.ejecutar(_todos, tipo);
    final porEstado = _estado.ejecutar(porTipo, estado);
    registros = _buscar.ejecutar(porEstado, textoBusqueda);
  }

  void buscar(String texto) {
    textoBusqueda = texto;
    _recalcular();
    notifyListeners();
  }

  void elegirTipo(String? valor) {
    tipo = valor;
    _recalcular();
    notifyListeners();
  }

  void elegirEstado(EstadoEquipo? valor) {
    estado = valor;
    _recalcular();
    notifyListeners();
  }
}
