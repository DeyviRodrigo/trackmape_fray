/// Responsabilidad: Sostener el formulario de equipo: cargarlo, evaluarlo y
/// guardarlo.
library;

import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/controladores/formulario/equipos_formulario_campos.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/filtros/sedes_por_empresa_filtro.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/servicios/equipos_guardar_servicio.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/servicios/equipos_mostrar_formulario_servicio.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/transformadores/a_vista/empresa_opcion_vista_transformador.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/transformadores/a_vista/equipo_formulario_vista_transformador.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/transformadores/a_vista/sede_opcion_vista_transformador.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/validaciones/equipo_formulario_validacion.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/empresa_opcion_vista.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/equipo_formulario_vista.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/modelos/sede_opcion_vista.dart';
import 'package:trackmape_sup/pestanas/general/funciones/controladores/controlador_presentacion.dart';

class EquiposFormularioControlador extends ControladorPresentacion {
  EquiposFormularioControlador(this._id) {
    // Arranca cargando: no se pintan campos vacios que luego se reemplazan.
    cargando = true;
  }

  final _mostrarFormulario = EquiposMostrarFormularioServicio();
  final _guardar = EquiposGuardarServicio();
  final _sedesPorEmpresa = SedesPorEmpresaFiltro();
  final _validar = EquipoFormularioValidacion();
  final String? _id;

  /// El estado editable. La pagina escribe aca y de aca sale lo que se guarda.
  final campos = EquiposFormularioCampos();

  EquipoFormularioVista? formulario;

  bool get esEdicion => _id != null;

  List<EmpresaOpcionVista> get empresas => formulario?.empresas ?? const [];
  List<SedeOpcionVista> get sedes => _sedesPorEmpresa.ejecutar(
    formulario?.sedes ?? const [],
    campos.empresa?.id,
  );

  // REGISTRO - Los campos evaluados: como se llaman en pantalla y como se
  // evaluan.
  late final _evaluados =
      <String, ({String etiqueta, String? Function() evaluar})>{
        'empresa': (
          etiqueta: 'Empresa',
          evaluar: () => _validar.empresa(campos.empresa),
        ),
        'nombre': (
          etiqueta: 'Nombre',
          evaluar: () => _validar.nombre(campos.nombreControlador.text),
        ),
        'codigo': (
          etiqueta: 'Código',
          evaluar: () => _validar.codigo(campos.codigoControlador.text),
        ),
        'tipo': (
          etiqueta: 'Tipo',
          evaluar: () => _validar.tipo(campos.tipoControlador.text),
        ),
        'direccionMac': (
          etiqueta: 'Dirección MAC',
          evaluar: () =>
              _validar.direccionMac(campos.direccionMacControlador.text),
        ),
      };

  final Map<String, String?> _errores = {};

  /// Lo que impide guardar, cuando no es un error del repositorio.
  String? errorFormulario;

  String? errorDe(String clave) => _errores[clave];

  /// Se llama al terminar de tocar un campo, no mientras se escribe.
  void validarCampo(String clave) {
    final evaluado = _evaluados[clave];
    if (evaluado == null) return;
    _errores[clave] = evaluado.evaluar();
    notifyListeners();
  }

  Future<void> cargar() => ejecutarCarga(() async {
    final (crudo, empresasCrudas, sedesCrudas) = await _mostrarFormulario
        .ejecutar(_id);
    final vista = EquipoFormularioVistaTransformador.transformar(
      crudo,
      empresas: EmpresaOpcionVistaTransformador.transformarLista(
        empresasCrudas,
      ),
      sedes: SedeOpcionVistaTransformador.transformarLista(sedesCrudas),
    );
    formulario = vista;
    campos.llenar(vista);
    // Desde aca cualquier cambio es del usuario: llenarlos no cuenta.
    habilitarSeguimientoCambios();
  });

  void elegirEmpresa(EmpresaOpcionVista? valor) {
    campos.empresa = valor;
    if (campos.sede?.fkEmpresa != valor?.id) campos.sede = null;
    validarCampo('empresa');
  }

  void elegirSede(SedeOpcionVista? valor) {
    campos.sede = valor;
    notifyListeners();
  }

  void elegirFechaInicio(DateTime valor) {
    campos.fechaInicio = valor;
    notifyListeners();
  }

  /// Devuelve `true` si se guardo.
  Future<bool> guardar() async {
    final revisar = <String>[];
    for (final entrada in _evaluados.entries) {
      final mensaje = entrada.value.evaluar();
      _errores[entrada.key] = mensaje;
      if (mensaje != null) revisar.add(entrada.value.etiqueta);
    }
    if (revisar.isNotEmpty) {
      errorFormulario = 'Revise estos campos: ${revisar.join(', ')}.';
      notifyListeners();
      return false;
    }
    errorFormulario = null;
    await ejecutarGuardado(() => _guardar.ejecutar(_id, campos));
    if (error != null) return false;
    descartarCambiosPendientes();
    return true;
  }

  @override
  void dispose() {
    campos.dispose();
    super.dispose();
  }
}
