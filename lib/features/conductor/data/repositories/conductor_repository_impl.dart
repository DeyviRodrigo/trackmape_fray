import '../../domain/entities/posicion_entity.dart';
import '../../domain/repositories/i_conductor_repository.dart';
import '../models/posicion_model.dart';
import '../datasources/conductor_remote_datasource.dart';

class ConductorRepositoryImpl implements IConductorRepository {
  final IConductorRemoteDataSource remoteDataSource;
  // TODO: Agregar localDataSource para SQLite

  ConductorRepositoryImpl(this.remoteDataSource);

  @override
  Future<bool> enviarPosicion({
    required String idEquipo,
    required PosicionEntity posicion,
  }) async {
    // 1. Transformamos la Entidad de Negocio pura a un Modelo de Datos (JSON)
    final model = PosicionModel(
      latitud: posicion.latitud,
      longitud: posicion.longitud,
      altitud: posicion.altitud,
      velocidad: posicion.velocidad,
      rumbo: posicion.rumbo,
      tiempo: posicion.tiempo,
    );

    // 2. Intentamos enviar a la red (Supabase)
    final success = await remoteDataSource.enviarPosicion(idEquipo, model);

    // 3. Principio Offline-First (Arquitectura Escalonada)
    if (!success) {
      print("⚠️ No hay internet o falló Supabase. Guardando en SQLite localmente...");
      // Aquí el repositorio decidiría guardarlo localmente usando el LocalDataSource.
      // await localDataSource.guardarPendiente(model);
      // Retornaríamos true porque el dato NO se perdió, está a salvo en el celular.
    }

    return success;
  }

  @override
  Future<Map<String, dynamic>> registrarDispositivo({
    required String idFabrica,
    required String codigo,
    required String nombre,
    required String fkEmpresa,
    String? fkSede,
  }) async {
    // Pendiente migrar esta lógica de la versión anterior
    throw UnimplementedError();
  }
}
