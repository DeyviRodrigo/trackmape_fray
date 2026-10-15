import '../entities/posicion_entity.dart';
import '../repositories/i_conductor_repository.dart';

class EnviarPosicionUseCase {
  final IConductorRepository repository;

  EnviarPosicionUseCase(this.repository);

  Future<bool> call(String idEquipo, PosicionEntity posicion) async {
    // Aquí podrían haber reglas de negocio adicionales antes de guardar
    // Por ejemplo, ignorar la posición si la velocidad es absurda.
    if (posicion.velocidad > 300) { // Mayor a 300 m/s es imposible para un camión
      return false; 
    }

    return await repository.enviarPosicion(
      idEquipo: idEquipo,
      posicion: posicion,
    );
  }
}
