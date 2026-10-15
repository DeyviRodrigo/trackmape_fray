import 'dart:math' as math;

import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/core/utilidades/calculadora_geodesica.dart';

class PuntoRutaUnaj {
  final String nombre;
  final ll.LatLng coordenada;
  final ll.LatLng? coordenadaParada;
  final double velocidadKmh;
  final bool esParada;

  const PuntoRutaUnaj({
    required this.nombre,
    required this.coordenada,
    this.coordenadaParada,
    required this.velocidadKmh,
    required this.esParada,
  });
}

class TramoRutaUnaj {
  final PuntoRutaUnaj origen;
  final PuntoRutaUnaj destino;
  final double distanciaMetros;
  final Duration duracionMovimiento;
  final Duration salidaDesdeInicio;
  final Duration llegadaDesdeInicio;

  const TramoRutaUnaj({
    required this.origen,
    required this.destino,
    required this.distanciaMetros,
    required this.duracionMovimiento,
    required this.salidaDesdeInicio,
    required this.llegadaDesdeInicio,
  });

  double get distanciaKm => distanciaMetros / 1000;
}

class ParadaCalculadaRutaUnaj {
  final PuntoRutaUnaj punto;
  final int indicePunto;
  final int numero;
  final bool esDestinoFinal;
  final Duration llegadaDesdeInicio;
  final Duration esperaPromedio;

  const ParadaCalculadaRutaUnaj({
    required this.punto,
    required this.indicePunto,
    required this.numero,
    required this.esDestinoFinal,
    required this.llegadaDesdeInicio,
    required this.esperaPromedio,
  });

  ll.LatLng get coordenadaMarcador =>
      punto.coordenadaParada ?? punto.coordenada;
}

class EtaParadaRutaUnaj {
  final ParadaCalculadaRutaUnaj parada;
  final DateTime llegadaEstimada;
  final Duration restante;
  final TramoRutaUnaj? tramoAnterior;

  const EtaParadaRutaUnaj({
    required this.parada,
    required this.llegadaEstimada,
    required this.restante,
    required this.tramoAnterior,
  });
}

class ItinerarioRutaUnaj {
  final List<ParadaCalculadaRutaUnaj> paradas;
  final List<TramoRutaUnaj> tramosEntreParadas;
  final List<Duration> llegadaPorPunto;
  final List<Duration> salidaPorPunto;
  final List<Duration> duracionPorSubtramo;

  const ItinerarioRutaUnaj({
    required this.paradas,
    required this.tramosEntreParadas,
    required this.llegadaPorPunto,
    required this.salidaPorPunto,
    required this.duracionPorSubtramo,
  });

  Duration get duracionTotal =>
      paradas.isEmpty ? Duration.zero : paradas.last.llegadaDesdeInicio;
}

class RutaUnaj {
  static const Duration esperaPromedioParada = Duration(seconds: 150);

  static const List<PuntoRutaUnaj> puntos = <PuntoRutaUnaj>[
    PuntoRutaUnaj(
      nombre: 'Punto ruta 1',
      coordenada: ll.LatLng(-15.40750922523535, -70.09538818275593),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 2',
      coordenada: ll.LatLng(-15.40704253268283, -70.09433947064434),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 3',
      coordenada: ll.LatLng(-15.40697628641940, -70.09339457503708),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 4',
      coordenada: ll.LatLng(-15.40727653105781, -70.09246818516478),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 5',
      coordenada: ll.LatLng(-15.40792942745605, -70.09169734966154),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 6',
      coordenada: ll.LatLng(-15.40861658655678, -70.09131002082842),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 7',
      coordenada: ll.LatLng(-15.40942302655339, -70.09114234204017),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 8',
      coordenada: ll.LatLng(-15.41046023819667, -70.09135872257792),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 9',
      coordenada: ll.LatLng(-15.41131688764537, -70.09199053363766),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 10',
      coordenada: ll.LatLng(-15.41178064735094, -70.09284226952934),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 11',
      coordenada: ll.LatLng(-15.41193210940804, -70.09396961146484),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 12',
      coordenada: ll.LatLng(-15.41175094208519, -70.09472872092817),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 13',
      coordenada: ll.LatLng(-15.41140210640838, -70.09537759790639),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 14',
      coordenada: ll.LatLng(-15.41110695744683, -70.09573509854438),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 15',
      coordenada: ll.LatLng(-15.41088246166901, -70.09605352604196),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'UNAJ Ayabacas',
      coordenada: ll.LatLng(-15.41071497802975, -70.09637013248238),
      coordenadaParada: ll.LatLng(-15.41076135302450, -70.09639652868461),
      velocidadKmh: 20,
      esParada: true,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 16',
      coordenada: ll.LatLng(-15.41064187679594, -70.09650832103338),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 17',
      coordenada: ll.LatLng(-15.41588277829257, -70.09700455398782),
      velocidadKmh: 45,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 18',
      coordenada: ll.LatLng(-15.42525514929003, -70.09792753361060),
      velocidadKmh: 45,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 19',
      coordenada: ll.LatLng(-15.44227434247171, -70.09936879939573),
      velocidadKmh: 45,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 20',
      coordenada: ll.LatLng(-15.45544193586278, -70.10060848717747),
      velocidadKmh: 45,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Desvío Huancane',
      coordenada: ll.LatLng(-15.45553353820829, -70.10068844733553),
      coordenadaParada: ll.LatLng(-15.45560330099898, -70.10060241713124),
      velocidadKmh: 45,
      esParada: true,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 21',
      coordenada: ll.LatLng(-15.45688262991466, -70.10186607641782),
      velocidadKmh: 35,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 22',
      coordenada: ll.LatLng(-15.45931816749999, -70.10082601536743),
      velocidadKmh: 35,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 23',
      coordenada: ll.LatLng(-15.46222411614565, -70.10080978138862),
      velocidadKmh: 35,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 24',
      coordenada: ll.LatLng(-15.46502438450682, -70.10457038889353),
      velocidadKmh: 35,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 25',
      coordenada: ll.LatLng(-15.46494419518677, -70.10519834741181),
      velocidadKmh: 35,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 26',
      coordenada: ll.LatLng(-15.46386606321915, -70.10695512823428),
      velocidadKmh: 35,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Puente Independencia',
      coordenada: ll.LatLng(-15.46390107119656, -70.10711511327850),
      coordenadaParada: ll.LatLng(-15.46394139999837, -70.10710561312904),
      velocidadKmh: 30,
      esParada: true,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 27',
      coordenada: ll.LatLng(-15.46396547640925, -70.10740944250178),
      velocidadKmh: 35,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 28',
      coordenada: ll.LatLng(-15.47221688646393, -70.11199134831375),
      velocidadKmh: 35,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Av. Robles',
      coordenada: ll.LatLng(-15.47637643159406, -70.11616378400906),
      coordenadaParada: ll.LatLng(-15.47644295369209, -70.11609238241904),
      velocidadKmh: 30,
      esParada: true,
    ),
    PuntoRutaUnaj(
      nombre: 'Hospital',
      coordenada: ll.LatLng(-15.48176999151208, -70.12157405874407),
      coordenadaParada: ll.LatLng(-15.48183923551742, -70.12149973429862),
      velocidadKmh: 25,
      esParada: true,
    ),
    PuntoRutaUnaj(
      nombre: 'Pedro Vilcapaza',
      coordenada: ll.LatLng(-15.48476100286425, -70.12457433933737),
      coordenadaParada: ll.LatLng(-15.48477959814214, -70.12455437953282),
      velocidadKmh: 25,
      esParada: true,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 29',
      coordenada: ll.LatLng(-15.48477703594373, -70.12459042210388),
      velocidadKmh: 30,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 30',
      coordenada: ll.LatLng(-15.48133708010576, -70.12593799287863),
      velocidadKmh: 30,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Av. Triunfo',
      coordenada: ll.LatLng(-15.48066332531242, -70.12689001772169),
      coordenadaParada: ll.LatLng(-15.48066385737864, -70.12689042315354),
      velocidadKmh: 30,
      esParada: true,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 31',
      coordenada: ll.LatLng(-15.48059488578513, -70.12698672372049),
      velocidadKmh: 30,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 32',
      coordenada: ll.LatLng(-15.48030298539033, -70.12857643516027),
      velocidadKmh: 30,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Óvalo Sda. Cusco',
      coordenada: ll.LatLng(-15.48130338253584, -70.13546951554001),
      coordenadaParada: ll.LatLng(-15.48136128030978, -70.13546046821611),
      velocidadKmh: 30,
      esParada: true,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 33',
      coordenada: ll.LatLng(-15.48135862993784, -70.13585018913997),
      velocidadKmh: 30,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 34',
      coordenada: ll.LatLng(-15.48229987004331, -70.14063892426414),
      velocidadKmh: 30,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 35',
      coordenada: ll.LatLng(-15.48332209517384, -70.14202616020364),
      velocidadKmh: 25,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Av. Ferrocarril',
      coordenada: ll.LatLng(-15.48655139035448, -70.14295204639427),
      coordenadaParada: ll.LatLng(-15.48653812945469, -70.14300184775136),
      velocidadKmh: 25,
      esParada: true,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 36',
      coordenada: ll.LatLng(-15.48664690222897, -70.14297943104656),
      velocidadKmh: 25,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 37',
      coordenada: ll.LatLng(-15.49141462101011, -70.14420909875135),
      velocidadKmh: 25,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'Parque Cholo',
      coordenada: ll.LatLng(-15.49139755194746, -70.14423479463326),
      coordenadaParada: ll.LatLng(-15.49145794021490, -70.14427798992637),
      velocidadKmh: 25,
      esParada: true,
    ),
    PuntoRutaUnaj(
      nombre: 'Punto ruta 38',
      coordenada: ll.LatLng(-15.48767794844587, -70.14983431080245),
      velocidadKmh: 20,
      esParada: false,
    ),
    PuntoRutaUnaj(
      nombre: 'UNAJ La Capilla',
      coordenada: ll.LatLng(-15.48935514164542, -70.15126293077492),
      coordenadaParada: ll.LatLng(-15.48936106191575, -70.15120172949237),
      velocidadKmh: 0,
      esParada: true,
    ),
  ];

  static final ItinerarioRutaUnaj itinerario = _construirItinerario();

  static List<ll.LatLng> get polilinea =>
      puntos.map((punto) => punto.coordenada).toList(growable: false);

  static List<ParadaCalculadaRutaUnaj> get paradasCalculadas =>
      itinerario.paradas;

  static List<EtaParadaRutaUnaj> calcularEtasDesdeSalida(DateTime salida) {
    return itinerario.paradas
        .map(
          (parada) => EtaParadaRutaUnaj(
            parada: parada,
            llegadaEstimada: salida.add(parada.llegadaDesdeInicio),
            restante: parada.llegadaDesdeInicio,
            tramoAnterior: _tramoParaParada(parada.indicePunto),
          ),
        )
        .toList(growable: false);
  }

  static List<EtaParadaRutaUnaj> calcularEtasDesdePosicion({
    required ll.LatLng posicion,
    required DateTime ahora,
  }) {
    final proyeccion = _proyectarEnRuta(posicion);
    final avanceEstimado = _avanceDesdeInicio(proyeccion);

    return itinerario.paradas
        .where((parada) => parada.llegadaDesdeInicio > avanceEstimado)
        .map((parada) {
          final restante = parada.llegadaDesdeInicio - avanceEstimado;
          return EtaParadaRutaUnaj(
            parada: parada,
            llegadaEstimada: ahora.add(restante),
            restante: restante,
            tramoAnterior: _tramoParaParada(parada.indicePunto),
          );
        })
        .toList(growable: false);
  }

  static ItinerarioRutaUnaj _construirItinerario() {
    final llegadaPorPunto = List<Duration>.filled(puntos.length, Duration.zero);
    final salidaPorPunto = List<Duration>.filled(puntos.length, Duration.zero);
    final duracionPorSubtramo = List<Duration>.filled(
      puntos.length - 1,
      Duration.zero,
    );

    final paradas = <ParadaCalculadaRutaUnaj>[];
    final tramos = <TramoRutaUnaj>[];

    var origenTramo = puntos.first;
    var salidaTramoDesdeInicio = Duration.zero;
    var distanciaTramoMetros = 0.0;
    var duracionTramo = Duration.zero;
    var numeroParada = 1;

    for (var i = 0; i < puntos.length - 1; i++) {
      final origen = puntos[i];
      final destino = puntos[i + 1];
      final distanciaMetros = _distanciaEntre(
        origen.coordenada,
        destino.coordenada,
      );
      final duracionSubtramo = _duracionMovimiento(
        distanciaMetros,
        origen.velocidadKmh,
      );

      duracionPorSubtramo[i] = duracionSubtramo;
      distanciaTramoMetros += distanciaMetros;
      duracionTramo += duracionSubtramo;

      final llegadaDestino = salidaPorPunto[i] + duracionSubtramo;
      llegadaPorPunto[i + 1] = llegadaDestino;

      final esDestinoFinal = i + 1 == puntos.length - 1;
      final esHito = destino.esParada || esDestinoFinal;

      if (esHito) {
        tramos.add(
          TramoRutaUnaj(
            origen: origenTramo,
            destino: destino,
            distanciaMetros: distanciaTramoMetros,
            duracionMovimiento: duracionTramo,
            salidaDesdeInicio: salidaTramoDesdeInicio,
            llegadaDesdeInicio: llegadaDestino,
          ),
        );

        paradas.add(
          ParadaCalculadaRutaUnaj(
            punto: destino,
            indicePunto: i + 1,
            numero: numeroParada,
            esDestinoFinal: esDestinoFinal,
            llegadaDesdeInicio: llegadaDestino,
            esperaPromedio: destino.esParada
                ? esperaPromedioParada
                : Duration.zero,
          ),
        );

        numeroParada++;
        origenTramo = destino;
        distanciaTramoMetros = 0;
        duracionTramo = Duration.zero;
      }

      salidaPorPunto[i + 1] =
          llegadaDestino +
          (destino.esParada ? esperaPromedioParada : Duration.zero);
      if (esHito) {
        salidaTramoDesdeInicio = salidaPorPunto[i + 1];
      }
    }

    return ItinerarioRutaUnaj(
      paradas: paradas,
      tramosEntreParadas: tramos,
      llegadaPorPunto: llegadaPorPunto,
      salidaPorPunto: salidaPorPunto,
      duracionPorSubtramo: duracionPorSubtramo,
    );
  }

  static Duration _avanceDesdeInicio(_ProyeccionRuta proyeccion) {
    final salidaTramo = itinerario.salidaPorPunto[proyeccion.indiceTramo];
    final duracionTramo =
        itinerario.duracionPorSubtramo[proyeccion.indiceTramo];
    return salidaTramo + _multiplicar(duracionTramo, proyeccion.fraccion);
  }

  static TramoRutaUnaj? _tramoParaParada(int indicePunto) {
    for (final tramo in itinerario.tramosEntreParadas) {
      final indiceDestino = puntos.indexOf(tramo.destino);
      if (indiceDestino == indicePunto) return tramo;
    }
    return null;
  }

  static Duration _duracionMovimiento(
    double distanciaMetros,
    double velocidadKmh,
  ) {
    if (velocidadKmh <= 0) return Duration.zero;
    final metrosPorSegundo = velocidadKmh * 1000 / 3600;
    return Duration(seconds: (distanciaMetros / metrosPorSegundo).round());
  }

  static double _distanciaEntre(ll.LatLng a, ll.LatLng b) {
    return CalculadoraGeodesica.calcularDistanciaMetros(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
  }

  static Duration _multiplicar(Duration duracion, double factor) {
    return Duration(milliseconds: (duracion.inMilliseconds * factor).round());
  }

  static _ProyeccionRuta _proyectarEnRuta(ll.LatLng posicion) {
    var mejor = const _ProyeccionRuta(
      indiceTramo: 0,
      fraccion: 0,
      distanciaMetros: double.infinity,
    );

    for (var i = 0; i < puntos.length - 1; i++) {
      final proyeccion = _proyectarEnSubtramo(
        posicion,
        puntos[i].coordenada,
        puntos[i + 1].coordenada,
        i,
      );

      if (proyeccion.distanciaMetros < mejor.distanciaMetros) {
        mejor = proyeccion;
      }
    }

    return mejor;
  }

  static _ProyeccionRuta _proyectarEnSubtramo(
    ll.LatLng punto,
    ll.LatLng inicio,
    ll.LatLng fin,
    int indiceTramo,
  ) {
    final latitudReferencia =
        (punto.latitude + inicio.latitude + fin.latitude) / 3;
    final cosLat = math.cos(latitudReferencia * math.pi / 180);

    final ax = inicio.longitude * cosLat;
    final ay = inicio.latitude;
    final bx = fin.longitude * cosLat;
    final by = fin.latitude;
    final px = punto.longitude * cosLat;
    final py = punto.latitude;

    final dx = bx - ax;
    final dy = by - ay;
    final largoCuadrado = dx * dx + dy * dy;

    final fraccion =
        (largoCuadrado == 0
                ? 0.0
                : (((px - ax) * dx + (py - ay) * dy) / largoCuadrado).clamp(
                    0.0,
                    1.0,
                  ))
            .toDouble();

    final proyectado = ll.LatLng(
      inicio.latitude + (fin.latitude - inicio.latitude) * fraccion,
      inicio.longitude + (fin.longitude - inicio.longitude) * fraccion,
    );

    return _ProyeccionRuta(
      indiceTramo: indiceTramo,
      fraccion: fraccion,
      distanciaMetros: _distanciaEntre(punto, proyectado),
    );
  }
}

class _ProyeccionRuta {
  final int indiceTramo;
  final double fraccion;
  final double distanciaMetros;

  const _ProyeccionRuta({
    required this.indiceTramo,
    required this.fraccion,
    required this.distanciaMetros,
  });
}
