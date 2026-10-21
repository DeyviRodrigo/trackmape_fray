/// Responsabilidad: Convertir los errores propios de Supabase en ErrorBackend,
/// asignando a cada uno su categoria de ErrorBackendTipo.
///
/// Es el unico lugar que conoce las excepciones y los codigos de error de
/// Supabase, PostgreSQL y PostgREST.
library;

import 'dart:async';

import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trackmape_sup/app2/conexion_backend/errores/error_backend.dart';
import 'package:trackmape_sup/app2/conexion_backend/errores/error_backend_tipo.dart';

// ERRORES SUPABASE - De cada error de Supabase a su ErrorBackend
class ErroresSupabase {
  ErroresSupabase._();

  // A ERROR BACKEND - Convierte cualquier fallo recibido de Supabase
  static ErrorBackend aErrorBackend(Object error, StackTrace rastreo) {
    if (error is ErrorBackend) return error;

    if (error is PostgrestException) {
      final codigo = _textoOpcional(error.code);
      return ErrorBackend(
        _textoOpcional(error.message) ?? 'Fallo de la base de datos',
        tipo: _tipoDeCodigo(codigo),
        codigo: codigo,
        detalles: _textoOpcional(error.details),
        sugerencia: _textoOpcional(error.hint),
        causa: error,
        rastreo: rastreo,
      );
    }

    if (error is AuthException) {
      return ErrorBackend(
        error.message,
        tipo: ErrorBackendTipo.autorizacion,
        codigo: _textoOpcional(error.code),
        causa: error,
        rastreo: rastreo,
      );
    }

    // Sin red, servidor caido, tiempo agotado o suscripcion en vivo rechazada
    if (error is ClientException ||
        error is TimeoutException ||
        error is RealtimeSubscribeException) {
      return ErrorBackend(
        'No se pudo comunicar con el servidor',
        tipo: ErrorBackendTipo.noDisponible,
        causa: error,
        rastreo: rastreo,
      );
    }

    return ErrorBackend(
      error.toString(),
      tipo: ErrorBackendTipo.desconocido,
      causa: error,
      rastreo: rastreo,
    );
  }

  // TIPO DE CODIGO - Familias de codigos de PostgreSQL y PostgREST
  static ErrorBackendTipo _tipoDeCodigo(String? codigo) {
    if (codigo == null) return ErrorBackendTipo.remoto;
    if (codigo == '42501' || codigo.startsWith('28')) {
      return ErrorBackendTipo.autorizacion;
    }
    if (codigo.startsWith('22')) return ErrorBackendTipo.validacion;
    if (codigo.startsWith('23')) return ErrorBackendTipo.integridad;
    if (codigo.startsWith('42') || codigo.startsWith('PGRST2')) {
      return ErrorBackendTipo.contrato;
    }
    if (codigo.startsWith('08') ||
        codigo.startsWith('53') ||
        codigo.startsWith('57P') ||
        codigo.startsWith('PGRST0') ||
        codigo.startsWith('PGRST1') ||
        codigo.startsWith('PGRST3')) {
      return ErrorBackendTipo.noDisponible;
    }
    return ErrorBackendTipo.remoto;
  }

  static String? _textoOpcional(Object? valor) {
    if (valor == null) return null;
    final texto = valor.toString().trim();
    return texto.isEmpty ? null : texto;
  }
}
