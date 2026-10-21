/// Responsabilidad: Implementar MensajeroInterfaz enviando cada operacion al
/// cliente de Supabase.
///
/// Las reglas del contrato se cumplen en ValidacionesMensajero, los limites de
/// Realtime en LimitesEscuchaSupabase, las casillas de la consulta se aplican
/// en TraductorPeticion y los fallos se convierten en ErroresSupabase.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trackmape_sup/app2/conexion_backend/contratos/seleccion_registro.dart';
import 'package:trackmape_sup/app2/conexion_backend/contratos/formulario_lectura.dart';
import 'package:trackmape_sup/app2/conexion_backend/contratos/mensajero_interfaz.dart';
import 'package:trackmape_sup/app2/conexion_backend/contratos/validaciones_mensajero.dart';
import 'package:trackmape_sup/app2/conexion_backend/errores/error_backend.dart';
import 'package:trackmape_sup/app2/conexion_backend/supabase/arranque/cliente_supabase.dart';
import 'package:trackmape_sup/app2/conexion_backend/supabase/mensajero/traductor_peticion.dart';
import 'package:trackmape_sup/app2/conexion_backend/supabase/mensajero/errores_supabase.dart';
import 'package:trackmape_sup/app2/conexion_backend/supabase/mensajero/limites_escucha_supabase.dart';

// MENSAJERO SUPABASE - Implementacion concreta de mensajeria contra Supabase
class MensajeroSupabase implements MensajeroInterfaz {
  // Columna del borrado logico, comun a toda tabla que admite baja
  static const _columnaActivo = 'activo';

  // LECTURA - Consultas sobre tablas y vistas

  @override
  Future<List<Map<String, dynamic>>> consultar(
    String tabla, [
    FormularioLectura consulta = const FormularioLectura(),
  ]) async {
    final filtrada = TraductorPeticion.aplicarFiltros(
      clienteSupabase.from(tabla).select(),
      consulta,
    );
    final respuesta = await _enviar(
      () => TraductorPeticion.aplicarTramo(
        TraductorPeticion.aplicarOrden(filtrada, consulta),
        consulta,
      ),
    );
    return List<Map<String, dynamic>>.from(respuesta);
  }

  @override
  Future<Map<String, dynamic>?> obtenerUno(
    String tabla,
    FormularioLectura consulta,
  ) async {
    ValidacionesMensajero.validarConsultaDeUno(consulta);

    // Se piden dos para distinguir "uno" de "mas de uno" sin traer la tabla
    final filtrada = TraductorPeticion.aplicarFiltros(
      clienteSupabase.from(tabla).select(),
      consulta,
    );
    final respuesta = await _enviar(
      () => TraductorPeticion.aplicarOrden(filtrada, consulta).limit(2),
    );
    final registros = List<Map<String, dynamic>>.from(respuesta);

    ValidacionesMensajero.validarRegistroUnico(tabla, registros);
    return registros.isEmpty ? null : registros.single;
  }

  // ESCRITURA - Insercion, actualizacion y borrado logico

  @override
  Future<void> insertar(String tabla, Map<String, dynamic> datos) async {
    await _enviar(() => clienteSupabase.from(tabla).insert(datos));
  }

  @override
  Future<Map<String, dynamic>> insertarYRetornar(
    String tabla,
    Map<String, dynamic> datos,
  ) async {
    return _enviar(
      () => clienteSupabase.from(tabla).insert(datos).select().single(),
    );
  }

  @override
  Future<void> actualizar(
    String tabla,
    Map<String, dynamic> datos,
    SeleccionRegistro seleccion,
  ) async {
    await _enviar(
      () => TraductorPeticion.aplicarCondiciones(
        clienteSupabase.from(tabla).update(datos),
        seleccion.todas,
      ),
    );
  }

  @override
  Future<void> desactivar(String tabla, SeleccionRegistro seleccion) async {
    await actualizar(tabla, {_columnaActivo: false}, seleccion);
  }

  @override
  Future<void> activar(String tabla, SeleccionRegistro seleccion) async {
    await actualizar(tabla, {_columnaActivo: true}, seleccion);
  }

  // PROCEDIMIENTOS - Funciones ejecutadas en el servidor

  @override
  Future<Object?> rpc(String funcion, Map<String, dynamic> parametros) async {
    return _enviar<Object?>(
      () => clienteSupabase.rpc(funcion, params: parametros),
    );
  }

  // TIEMPO REAL - Escucha de cambios con Supabase Realtime

  @override
  Stream<List<Map<String, dynamic>>> escuchar(
    String tabla,
    List<String> clavePrimaria, [
    FormularioLectura consulta = const FormularioLectura(),
  ]) {
    LimitesEscuchaSupabase.validar(consulta);

    final base = clienteSupabase.from(tabla).stream(primaryKey: clavePrimaria);
    SupabaseStreamBuilder flujo = base;

    if (consulta.igualA.isNotEmpty) {
      final condicion = consulta.igualA.entries.single;
      flujo = base.eq(condicion.key, TraductorPeticion.valor(condicion.value));
    } else if (consulta.enLista.isNotEmpty) {
      final condicion = consulta.enLista.entries.single;
      flujo = base.inFilter(
        condicion.key,
        condicion.value.map(TraductorPeticion.valor).toList(),
      );
    }

    if (consulta.ordenarPor.isNotEmpty) {
      final orden = consulta.ordenarPor.single;
      flujo = flujo.order(orden.campo, ascending: orden.ascendente);
    }

    if (consulta.tramo case MaximoConsulta(:final cantidad)) {
      flujo = flujo.limit(cantidad);
    }

    // Un fallo de la suscripcion llega por el flujo; se convierte igual que
    // los de una operacion. Lanzar dentro de handleError lo reemite convertido.
    return flujo
        .map(List<Map<String, dynamic>>.from)
        .handleError(
          (Object error, StackTrace rastreo) =>
              throw ErroresSupabase.aErrorBackend(error, rastreo),
          test: (error) => error is Exception && error is! ErrorBackend,
        );
  }

  // ENVIAR - Ejecuta una operacion contra Supabase y convierte su fallo.
  // Solo se convierten las excepciones: un Error es un defecto de programacion
  // y debe llegar intacto, con su rastreo, para que se note al desarrollar.
  Future<T> _enviar<T>(Future<T> Function() operacion) async {
    try {
      return await operacion();
    } on Exception catch (error, rastreo) {
      throw ErroresSupabase.aErrorBackend(error, rastreo);
    }
  }
}
