import 'package:trackmape_sup/app/conexion_backend/mensajero_intf.dart';
import 'package:trackmape_sup/app/conexion_backend/supabase/supabase_client.dart';

class MensajeroSupabase implements MensajeroIntf {
  @override
  Future<List<Map<String, dynamic>>> seleccionar(String tabla) async {
    final respuesta = await clienteSupabase.from(tabla).select();
    return List<Map<String, dynamic>>.from(respuesta);
  }

  @override
  Future<List<Map<String, dynamic>>> listarPor(
    String tabla,
    String campo,
    String valor,
  ) async {
    final respuesta = await clienteSupabase
        .from(tabla)
        .select()
        .eq(campo, valor);
    return List<Map<String, dynamic>>.from(respuesta);
  }

  @override
  Future<Map<String, dynamic>?> seleccionarPor(
    String tabla,
    String campo,
    String valor,
  ) async {
    return clienteSupabase.from(tabla).select().eq(campo, valor).maybeSingle();
  }

  @override
  Future<void> insertar(String tabla, Map<String, dynamic> datos) async {
    await clienteSupabase.from(tabla).insert(datos);
  }

  @override
  Future<Map<String, dynamic>> insertarYRetornar(
    String tabla,
    Map<String, dynamic> datos,
  ) async {
    final respuesta = await clienteSupabase
        .from(tabla)
        .insert(datos)
        .select()
        .single();
    return respuesta;
  }

  @override
  Future<void> actualizar(
    String tabla,
    Map<String, dynamic> datos,
    String campo,
    String valor,
  ) async {
    await clienteSupabase.from(tabla).update(datos).eq(campo, valor);
  }

  @override
  Future<void> desactivar(
    String tabla,
    Map<String, dynamic> datos,
    String campo,
    String valor,
  ) async {
    await clienteSupabase.from(tabla).update(datos).eq(campo, valor);
  }

  @override
  Future<Map<String, dynamic>> rpc(
    String funcion,
    Map<String, dynamic> params,
  ) async {
    final respuesta = await clienteSupabase.rpc(funcion, params: params);
    if (respuesta == null) {
      return {'ok': false, 'error': 'Sin respuesta del servidor'};
    }
    return Map<String, dynamic>.from(respuesta as Map);
  }
}
