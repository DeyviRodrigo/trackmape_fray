import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../datos/repositorio_conductor.dart';

class GpsServicio {

  final RepositorioConductor _repo = RepositorioConductor();

  Timer? _timer;

  void iniciar(String idDispositivo) {

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {

      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      await _repo.enviarPosicion(
        idDispositivo: idDispositivo,
        lat: pos.latitude,
        lon: pos.longitude,
      );

    });

  }

  void detener() {
    _timer?.cancel();
  }

}