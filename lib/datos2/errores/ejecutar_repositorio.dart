/// Responsabilidad: Ejecutar operaciones de repositorio y normalizar sus fallos
/// en RepositorioException.
///
/// No conoce ningun backend: los fallos del backend llegan ya clasificados por
/// el mensajero como ErrorBackend.
library;

import 'package:trackmape_sup/app2/conexion_backend/errores/error_backend.dart';
import 'package:trackmape_sup/app2/conexion_backend/errores/error_backend_tipo.dart';
import 'package:trackmape_sup/datos2/errores/error_datos_tipo.dart';
import 'package:trackmape_sup/datos2/errores/repositorio_exception.dart';

// EJECUTAR REPOSITORIO - Envuelve una operacion y traduce su fallo
Future<T> ejecutarRepositorio<T>(
  String contexto,
  Future<T> Function() accion,
) async {
  try {
    return await accion();
  } on RepositorioException {
    rethrow;
  } on ErrorBackend catch (error, rastreo) {
    throw RepositorioException(
      error.mensaje.trim().isEmpty ? contexto : error.mensaje,
      tipo: _tipoDesde(error.tipo),
      codigo: error.codigo,
      detalles: error.detalles,
      sugerencia: error.sugerencia,
      causa: error,
      rastreo: rastreo,
    );
  } on FormatException catch (error, rastreo) {
    throw _incumpleContrato(contexto, error, rastreo);
  } on TypeError catch (error, rastreo) {
    // Un deserializador que encuentra un tipo inesperado: la base devolvio
    // algo distinto de lo que el contrato declara.
    throw _incumpleContrato(contexto, error, rastreo);
  } on Exception catch (error, rastreo) {
    throw RepositorioException(
      contexto,
      tipo: ErrorDatosTipo.desconocido,
      causa: error,
      rastreo: rastreo,
    );
  }
  // Cualquier otro Error es un defecto de programacion y sale intacto.
}

RepositorioException _incumpleContrato(
  String contexto,
  Object error,
  StackTrace rastreo,
) {
  return RepositorioException(
    '$contexto: la respuesta no cumple el contrato de datos.',
    tipo: ErrorDatosTipo.contrato,
    causa: error,
    rastreo: rastreo,
  );
}

// Correspondencia uno a uno: si el mensajero suma un tipo, esto no compila
// hasta decidir como se informa.
ErrorDatosTipo _tipoDesde(ErrorBackendTipo tipo) => switch (tipo) {
  ErrorBackendTipo.autorizacion => ErrorDatosTipo.autorizacion,
  ErrorBackendTipo.validacion => ErrorDatosTipo.validacion,
  ErrorBackendTipo.integridad => ErrorDatosTipo.integridad,
  ErrorBackendTipo.contrato => ErrorDatosTipo.contrato,
  ErrorBackendTipo.noDisponible => ErrorDatosTipo.noDisponible,
  ErrorBackendTipo.remoto => ErrorDatosTipo.remoto,
  ErrorBackendTipo.desconocido => ErrorDatosTipo.desconocido,
};
