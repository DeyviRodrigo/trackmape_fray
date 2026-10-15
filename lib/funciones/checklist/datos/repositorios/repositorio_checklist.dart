import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trackmape_sup/funciones/checklist/datos/modelos/checklist_modelos.dart';

class RepositorioChecklist {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<VehiculoChecklist>> obtenerVehiculos() async {
    final response = await _supabase
        .from('vehiculos')
        .select('id_vehiculo, placa, marca, modelo')
        .eq('activo', true)
        .order('placa', ascending: true)
        .timeout(const Duration(seconds: 10));

    return List<Map<String, dynamic>>.from(
      response,
    ).map(VehiculoChecklist.fromJson).toList();
  }

  Future<ResultadoChecklist> registrarChecklist(
    Map<String, dynamic> datos,
  ) async {
    final response = await _supabase
        .from('checklist_preoperacional')
        .insert(datos)
        .select('id_checklist, fecha_hora, estado_general')
        .single()
        .timeout(const Duration(seconds: 12));

    return ResultadoChecklist.fromJson(response);
  }
}
