import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/core/mapas/graphhopper/graphhopper_servicio.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';
import 'package:trackmape_sup/core/utilidades/calculadora_geodesica.dart';
import 'dart:math' as math;

class PaginaHistorico extends StatefulWidget {
  const PaginaHistorico({super.key});

  @override
  State<PaginaHistorico> createState() => _PaginaHistoricoState();
}

class _PaginaHistoricoState extends State<PaginaHistorico> {

  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();

  Map<String, String> mapaCodigos = {};

  DateTime fechaSeleccionada = DateTime.now();
  Map<String, dynamic>? puntoSeleccionado;

  double velocidadCalc = 0.0;
  String tiempoReporte = "";

  // Rutas corregidas por GraphHopper
  Map<String, List<ll.LatLng>> _rutasCorregidas = {};
  bool _corrigiendoRutas = false;

  // ============================================
  // ⚙️ CONFIGURACIÓN DE FILTROS
  // ============================================
  // Distancia máxima permitida entre 2 puntos consecutivos (metros)
  // Si la distancia es mayor, se considera un salto falso
  static const double _distanciaMaximaMetros = 500.0;

  // Velocidad máxima permitida (km/h)
  // Si la velocidad calculada supera esto, es un dato falso
  static const double _velocidadMaximaKmh = 150.0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // BOTÓN DE PRUEBA GRAPHHOPPER (ROUTING API)
          FloatingActionButton(
            heroTag: "testGH",
            backgroundColor: Colors.green,
            child: const Icon(Icons.route, color: Colors.white),
            onPressed: () async {
              print("🧪 PRUEBA: GraphHopper Routing API...");

              // Puntos en Juliaca, Perú
              final puntosPrueba = [
                ll.LatLng(-15.4935, -70.1285),  // Inicio
                ll.LatLng(-15.4993, -70.1241),  // Fin
              ];

              print("📍 Ruta: ${puntosPrueba.first} → ${puntosPrueba.last}");

              try {
                final resultado = await GraphhopperServicio.corregirRuta(puntosPrueba);

                if (resultado != null && resultado.isNotEmpty) {
                  print("✅ ÉXITO: ${resultado.length} puntos en la ruta");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("✅ Ruta calculada: ${resultado.length} puntos"),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else {
                  print("⚠️ GraphHopper retornó vacío");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("⚠️ No se pudo calcular la ruta"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                print("❌ Error: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("❌ Error: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 10),
          // Botón calendario original
          FloatingActionButton(
            heroTag: "calendar",
            backgroundColor: Colors.orange,
            child: const Icon(Icons.calendar_month, color: Colors.black),
            onPressed: () async {

              DateTime? picker = await showDatePicker(
                context: context,
                initialDate: fechaSeleccionada,
                firstDate: DateTime(2025),
                lastDate: DateTime.now(),
              );

              if (picker != null) {
                setState(() {
                  fechaSeleccionada = picker;
                  puntoSeleccionado = null;
                  _rutasCorregidas.clear();
                });
              }

            },
          ),
        ],
      ),

      body: Stack(
        children: [

          FutureBuilder(
            future: Future.wait([
              _repositorio.obtenerEquiposRaw(),
              _repositorio.obtenerTrayectoriaPorFecha(fechaSeleccionada),
            ]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {

              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.orange));
              }

              final listaEquipos = snapshot.data![0] as List<Map<String, dynamic>>;

              for (var e in listaEquipos) {
                mapaCodigos[e['id_equipo_control'].toString()] =
                    e['codigo_equipo_control'] ?? "S/N";
              }

              final trayectoriaRaw =
              snapshot.data![1] as List<Map<String, dynamic>>;

              // ============================================
              // 🧹 FILTRAR DATOS INVÁLIDOS
              // ============================================
              List<Map<String, dynamic>> trayectoria = _filtrarDatosValidos(trayectoriaRaw);

              trayectoria.sort((a, b) => a['tiempo'].compareTo(b['tiempo']));

              // 🗺️ Preparar rutas y llamar a GraphHopper
              final rutasPorEquipo = _prepararRutasPorEquipo(trayectoria);
              if (_rutasCorregidas.isEmpty && rutasPorEquipo.isNotEmpty) {
                // Llamar a GraphHopper en segundo plano
                Future.microtask(() => _corregirRutasConGraphHopper(rutasPorEquipo));
              }

              return FlutterMap(
                options: MapOptions(
                  initialCenter: const ll.LatLng(-15.488405, -70.150497),
                  initialZoom: 15,
                  onTap: (_, __) => setState(() => puntoSeleccionado = null),
                ),
                children: [

                  TileLayer(
                      urlTemplate:
                      'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}'),

                  PolylineLayer(
                    polylines: _generarLineas(trayectoria),
                  ),

                  MarkerLayer(
                    markers: _construirMarcadores(trayectoria),
                  ),
                ],
              );
            },
          ),

          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange),
              ),
              child: Text(
                "Fecha: ${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          if (puntoSeleccionado != null) _buildPanelInfo(),
        ],
      ),
    );
  }

  // ============================================
  // 🧹 FILTRAR DATOS INVÁLIDOS
  // ============================================
  List<Map<String, dynamic>> _filtrarDatosValidos(List<Map<String, dynamic>> datos) {

    List<Map<String, dynamic>> datosFiltrados = [];

    for (var punto in datos) {
      final lat = (punto['lat_grados'] as num?)?.toDouble() ?? 0.0;
      final lon = (punto['lon_grados'] as num?)?.toDouble() ?? 0.0;

      // ============================================
      // ❌ FILTRO 1: Coordenadas inválidas
      // ============================================
      // Descartar si lat/lon son 0, null, o fuera de rango
      if (lat == 0.0 || lon == 0.0) continue;
      if (lat < -90 || lat > 90) continue;
      if (lon < -180 || lon > 180) continue;

      // ============================================
      // ❌ FILTRO 2: Coordenadas muy lejos de Perú
      // ============================================
      // Tu zona de trabajo está aproximadamente en:
      // Lat: -18 a -12 (sur de Perú)
      // Lon: -72 a -68 (departamento de Puno)
      // Si está muy fuera de este rango, es dato falso
      if (lat < -20 || lat > -10) continue;
      if (lon < -75 || lon > -65) continue;

      datosFiltrados.add(punto);
    }

    return datosFiltrados;
  }

  // ============================================
  // 📏 CALCULAR DISTANCIA ENTRE 2 PUNTOS
  // ============================================
  double _calcularDistanciaMetros(ll.LatLng p1, ll.LatLng p2) {
    const double p = 0.017453292519943295;
    final double a = 0.5 -
        math.cos((p2.latitude - p1.latitude) * p) / 2 +
        math.cos(p1.latitude * p) * math.cos(p2.latitude * p) *
            (1 - math.cos((p2.longitude - p1.longitude) * p)) / 2;

    return 12742 * math.asin(math.sqrt(a)) * 1000;
  }

  void _seleccionarPunto(
      Map<String, dynamic> actual, List<Map<String, dynamic>> historialCompleto) {

    setState(() {

      puntoSeleccionado = actual;

      DateTime hora = DateTime.parse(actual['tiempo']);

      Duration diff = DateTime.now().difference(hora);

      tiempoReporte = diff.inMinutes > 60
          ? "${diff.inHours}h ${diff.inMinutes % 60}m"
          : "${diff.inMinutes} min";

      final historialEmisor = historialCompleto
          .where((p) => p['fk_emisor'] == actual['fk_emisor'])
          .toList();

      historialEmisor.sort((a, b) => a['tiempo'].compareTo(b['tiempo']));

      int idx = historialEmisor.indexOf(actual);

      if (idx > 0) {

        final anterior = historialEmisor[idx - 1];

        velocidadCalc = CalculadoraGeodesica.calcularVelocidad(
          (anterior['lat_grados'] as num).toDouble(),
          (anterior['lon_grados'] as num).toDouble(),
          DateTime.parse(anterior['tiempo']),
          (actual['lat_grados'] as num).toDouble(),
          (actual['lon_grados'] as num).toDouble(),
          DateTime.parse(actual['tiempo']),
        );

      } else {

        velocidadCalc = 0.0;

      }

    });
  }

  Widget _buildPanelInfo() {

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF06329C),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.orange, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Text(
                    "UNIDAD: ${mapaCodigos[puntoSeleccionado!['fk_emisor'].toString()] ?? 'S/N'}",
                    style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),

                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () =>
                      setState(() => puntoSeleccionado = null),
                )
              ],
            ),

            const Divider(color: Colors.white24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dato("Lat (X)", puntoSeleccionado!['lat_grados'].toString()),
                _dato("Lon (Y)", puntoSeleccionado!['lon_grados'].toString()),
                _dato("Alt (Z)", "${puntoSeleccionado!['alt_msnm'] ?? 'N/A'}m"),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dato("Velocidad",
                    "${velocidadCalc.toStringAsFixed(1)} km/h",
                    color: Colors.greenAccent),
                _dato("Tiempo", tiempoReporte,
                    color: Colors.blueAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dato(String t, String v, {Color color = Colors.white}) => Column(
    children: [
      Text(t,
          style: const TextStyle(color: Colors.grey, fontSize: 10)),
      Text(v,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13)),
    ],
  );

  List<Marker> _construirMarcadores(List<Map<String, dynamic>> datos) {

    Map<String, Marker> marcadoresUltimaPosicion = {};

    for (var pos in datos) {

      String id = pos['fk_emisor'].toString();

      marcadoresUltimaPosicion[id] = Marker(
        point: ll.LatLng(
          (pos['lat_grados'] as num).toDouble(),
          (pos['lon_grados'] as num).toDouble(),
        ),
        width: 65,
        height: 65,
        child: GestureDetector(
          onTap: () => _seleccionarPunto(pos, datos),
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange, width: 0.5),
                ),
                child: Text(
                    mapaCodigos[id] ?? "...",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),

              const Icon(
                Icons.local_shipping,
                color: Color(0xFF06329C),
                size: 26,
              ),
            ],
          ),
        ),
      );
    }

    return marcadoresUltimaPosicion.values.toList();
  }

  // ============================================
  // 📊 PREPARAR RUTAS POR EQUIPO (para GraphHopper)
  // ============================================
  Map<String, List<ll.LatLng>> _prepararRutasPorEquipo(List<Map<String, dynamic>> pos) {
    Map<String, List<ll.LatLng>> rutasPorEquipo = {};
    Map<String, List<Map<String, dynamic>>> datosPorEquipo = {};

    for (var p in pos) {
      String id = p['fk_emisor'].toString();
      datosPorEquipo.putIfAbsent(id, () => []);
      datosPorEquipo[id]!.add(p);
    }

    for (var entry in datosPorEquipo.entries) {
      final id = entry.key;
      final puntos = entry.value;
      puntos.sort((a, b) => a['tiempo'].compareTo(b['tiempo']));

      List<ll.LatLng> ruta = [];
      for (var p in puntos) {
        final lat = (p['lat_grados'] as num).toDouble();
        final lon = (p['lon_grados'] as num).toDouble();
        ruta.add(ll.LatLng(lat, lon));
      }

      if (ruta.isNotEmpty) {
        rutasPorEquipo[id] = ruta;
      }
    }

    return rutasPorEquipo;
  }

  List<Polyline> _generarLineas(List<Map<String, dynamic>> pos) {

    Map<String, List<ll.LatLng>> rutasPorEquipo = {};

    // Agrupar por equipo
    Map<String, List<Map<String, dynamic>>> datosPorEquipo = {};
    for (var p in pos) {
      String id = p['fk_emisor'].toString();
      datosPorEquipo.putIfAbsent(id, () => []);
      datosPorEquipo[id]!.add(p);
    }

    // Procesar cada equipo y filtrar saltos imposibles
    for (var entry in datosPorEquipo.entries) {
      final id = entry.key;
      final puntos = entry.value;

      // Ordenar por tiempo
      puntos.sort((a, b) => a['tiempo'].compareTo(b['tiempo']));

      List<ll.LatLng> rutaFiltrada = [];
      ll.LatLng? puntoAnterior;
      DateTime? tiempoAnterior;

      for (var p in puntos) {
        final lat = (p['lat_grados'] as num).toDouble();
        final lon = (p['lon_grados'] as num).toDouble();
        final tiempo = DateTime.parse(p['tiempo']);
        final puntoActual = ll.LatLng(lat, lon);

        if (puntoAnterior != null && tiempoAnterior != null) {
          // Calcular distancia y tiempo entre puntos
          final distancia = _calcularDistanciaMetros(puntoAnterior, puntoActual);
          final segundos = tiempo.difference(tiempoAnterior).inSeconds.abs();

          // Calcular velocidad (evitar división por 0)
          final velocidad = segundos > 0 ? (distancia / segundos) * 3.6 : 0.0;

          // ============================================
          // ❌ FILTRO: Salto imposible
          // ============================================
          // Si la distancia es mayor a 500m O la velocidad > 150 km/h
          // consideramos que es un dato falso y NO lo agregamos
          if (distancia > _distanciaMaximaMetros || velocidad > _velocidadMaximaKmh) {
            // Salto detectado - no conectar con línea
            // Pero sí agregar el punto actual como inicio de nuevo segmento
            if (rutaFiltrada.isNotEmpty) {
              // Guardar ruta actual y empezar nueva
              rutasPorEquipo.putIfAbsent(id, () => []);
              rutasPorEquipo[id]!.addAll(rutaFiltrada);
            }
            rutaFiltrada = [puntoActual];
          } else {
            // Punto válido - agregar a la ruta
            rutaFiltrada.add(puntoActual);
          }
        } else {
          // Primer punto
          rutaFiltrada.add(puntoActual);
        }

        puntoAnterior = puntoActual;
        tiempoAnterior = tiempo;
      }

      // Agregar última ruta
      if (rutaFiltrada.isNotEmpty) {
        rutasPorEquipo.putIfAbsent(id, () => []);
        rutasPorEquipo[id]!.addAll(rutaFiltrada);
      }
    }

    return rutasPorEquipo.entries.map((e) {
      // Usar ruta corregida si existe, sino usar la original
      final puntos = _rutasCorregidas[e.key] ?? e.value;

      return Polyline(
        points: puntos,
        color: Colors.orange.withOpacity(0.7),
        strokeWidth: 4,
      );

    }).toList();
  }

  // ============================================
  // 🗺️ CORREGIR RUTAS CON GRAPHHOPPER
  // ============================================
  Future<void> _corregirRutasConGraphHopper(Map<String, List<ll.LatLng>> rutasPorEquipo) async {
    if (_corrigiendoRutas) return;

    _corrigiendoRutas = true;

    for (var entry in rutasPorEquipo.entries) {
      final idEquipo = entry.key;
      final puntos = entry.value;

      // Solo corregir si hay suficientes puntos
      if (puntos.length >= 2) {
        try {
          print("🗺️ GraphHopper: Corrigiendo ruta de $idEquipo (${puntos.length} puntos)...");

          final puntosCorregidos = await GraphhopperServicio.corregirRuta(puntos);

          if (puntosCorregidos != null && puntosCorregidos.isNotEmpty) {
            _rutasCorregidas[idEquipo] = puntosCorregidos;
            print("✅ GraphHopper: Ruta corregida para $idEquipo (${puntosCorregidos.length} puntos)");
          } else {
            print("⚠️ GraphHopper: Sin corrección para $idEquipo, usando original");
            _rutasCorregidas[idEquipo] = puntos;
          }
        } catch (e) {
          print("❌ GraphHopper Error: $e");
          _rutasCorregidas[idEquipo] = puntos;
        }
      }
    }

    _corrigiendoRutas = false;

    // Actualizar UI con las rutas corregidas
    if (mounted) {
      setState(() {});
    }
  }
}