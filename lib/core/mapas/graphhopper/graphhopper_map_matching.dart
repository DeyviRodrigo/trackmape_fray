import 'dart:math' as math;
import 'package:latlong2/latlong.dart' as ll;

class GraphhopperMapMatching {

  List<ll.LatLng> ajustarRutaSync(List<ll.LatLng> puntos) {

    if (puntos.length < 2) {
      return puntos;
    }

    List<ll.LatLng> ruta = [];

    for (int i = 0; i < puntos.length - 1; i++) {

      final p1 = puntos[i];
      final p2 = puntos[i + 1];

      ruta.add(p1);

      final distancia = _distancia(p1, p2);

      if (distancia > 15) {

        final lat = (p1.latitude + p2.latitude) / 2;
        final lon = (p1.longitude + p2.longitude) / 2;

        ruta.add(ll.LatLng(lat, lon));

      }

    }

    ruta.add(puntos.last);

    return ruta;
  }

  double _distancia(ll.LatLng a, ll.LatLng b) {

    const p = 0.017453292519943295;

    final x = 0.5 -
        math.cos((b.latitude - a.latitude) * p) / 2 +
        math.cos(a.latitude * p) *
            math.cos(b.latitude * p) *
            (1 - math.cos((b.longitude - a.longitude) * p)) / 2;

    return 12742 * math.sqrt(x) * 1000;
  }

}