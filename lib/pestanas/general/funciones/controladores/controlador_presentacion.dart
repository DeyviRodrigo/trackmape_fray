/// Responsabilidad: Coordinar los estados comunes de carga, guardado, errores y
/// cambios pendientes de los controladores de presentacion.
///
/// Tomado de trazmape (pestanas2/general). Los controladores de cada pestana
/// repetirian este mismo manejo —encender el indicador, atrapar la excepcion,
/// apagarlo, notificar— y por eso vive una sola vez. Se hereda (`extends`).
library;

import 'package:flutter/foundation.dart';

import 'package:trackmape_sup/datos2/errores/repositorio_exception.dart';

abstract class ControladorPresentacion extends ChangeNotifier {
  bool cargando = false;
  bool guardando = false;
  String? error;

  /// El fallo tipado, para distinguir por ejemplo un permiso de una unicidad.
  RepositorioException? errorRepositorio;

  bool _destruido = false;
  bool _seguirCambios = false;

  // CONTADORES - Dos cargas simultaneas no deben apagar el indicador cuando
  // termina la primera.
  int _cargasActivas = 0;
  int _guardadosActivos = 0;

  bool tieneCambiosPendientes = false;
  bool get destruido => _destruido;

  void habilitarSeguimientoCambios() => _seguirCambios = true;

  void marcarCambiosPendientes() {
    if (!_seguirCambios || tieneCambiosPendientes) return;
    tieneCambiosPendientes = true;
    _notificarSinMarcar();
  }

  void descartarCambiosPendientes() {
    if (!tieneCambiosPendientes) return;
    tieneCambiosPendientes = false;
    _notificarSinMarcar();
  }

  @override
  void notifyListeners() {
    if (_destruido) return;
    if (_seguirCambios && !cargando && !guardando) {
      tieneCambiosPendientes = true;
    }
    super.notifyListeners();
  }

  Future<void> ejecutarCarga(Future<void> Function() accion) async {
    _cargasActivas++;
    cargando = true;
    _limpiarError();
    _notificarSinMarcar();
    try {
      await accion();
    } catch (excepcion) {
      _registrarError(excepcion);
    } finally {
      _cargasActivas--;
      cargando = _cargasActivas > 0;
      _notificarSinMarcar();
    }
  }

  Future<void> ejecutarAccion(Future<void> Function() accion) async {
    _limpiarError();
    _notificarSinMarcar();
    try {
      await accion();
    } catch (excepcion) {
      _registrarError(excepcion);
    } finally {
      _notificarSinMarcar();
    }
  }

  Future<void> ejecutarGuardado(Future<void> Function() accion) async {
    _guardadosActivos++;
    guardando = true;
    _limpiarError();
    _notificarSinMarcar();
    try {
      await accion();
      tieneCambiosPendientes = false;
    } catch (excepcion) {
      _registrarError(excepcion);
    } finally {
      _guardadosActivos--;
      guardando = _guardadosActivos > 0;
      _notificarSinMarcar();
    }
  }

  // ERROR - Un fallo que datos2 ya interpreto trae su propio mensaje. Cualquier
  // otro recibe uno generico: nunca debe llegar un rastreo a la pantalla.
  void _registrarError(Object excepcion) {
    if (excepcion is RepositorioException) {
      errorRepositorio = excepcion;
      error = excepcion.mensaje;
      return;
    }
    errorRepositorio = null;
    error = 'No se pudo completar la operación.';
  }

  void _limpiarError() {
    error = null;
    errorRepositorio = null;
  }

  void _notificarSinMarcar() {
    if (!_destruido) super.notifyListeners();
  }

  @override
  void dispose() {
    _destruido = true;
    super.dispose();
  }
}
