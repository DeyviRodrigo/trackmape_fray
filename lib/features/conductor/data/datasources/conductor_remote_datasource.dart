import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/posicion_model.dart';

abstract class IConductorRemoteDataSource {
  Future<bool> enviarPosicion(String idEquipo, PosicionModel posicion);
}

class ConductorRemoteDataSourceImpl implements IConductorRemoteDataSource {
  final SupabaseClient _supabaseClient;

  ConductorRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<bool> enviarPosicion(String idEquipo, PosicionModel posicion) async {
    try {
      final data = posicion.toJson(idEquipo);
      await _supabaseClient.from('posiciones').insert(data).timeout(const Duration(seconds: 10));
      return true;
    } catch (e) {
      print('❌ Error Remote DataSource: $e');
      return false;
    }
  }
}
