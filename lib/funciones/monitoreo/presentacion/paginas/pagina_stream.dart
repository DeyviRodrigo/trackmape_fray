import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/core/mapas/graphhopper/graphhopper_servicio.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';

class PaginaStream extends StatefulWidget {
  const PaginaStream({super.key});

  @override
  State<PaginaStream> createState() => _PaginaStreamState();
}

class _PaginaStreamState extends State<PaginaStream> {
  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();

  // ============================================
  // 🗺️ GRAPHHOPPER ROUTING - CADA 90 SEGUNDOS
  // ============================================
  static const int _intervaloGraphHopper = 90; // segundos

  // Punto de INICIO para cada equipo (se actualiza cada 90s)
  Map<String, ll.LatLng> _puntoInicioGH = {};
  Map<String, DateTime> _ultimaLlamadaGH = {};

  // Rutas CORREGIDAS por GraphHopper (segmentos ya procesados)
  Map<String, List<ll.LatLng>> _rutasCorregidas = {};

  // Rastros CRUDOS (GPS sin corregir, últimos 90 segundos)
  Map<String, List<ll.LatLng>> _rastrosCrudos = {};

  // Información de equipos y estados de telemetría
  Map<String, Map<String, dynamic>> equiposInfo = {};
  Map<String, ll.LatLng> _posicionAnterior = {};
  Map<String, DateTime> _tiempoAnterior = {};
  Map<String, double> _velocidades = {};
  Map<String, double> _distanciasAcumuladas = {};

  // ============================================
  // 📍 ÚLTIMA POSICIÓN Y ESTADO DE CADA EQUIPO
  // ============================================
  Map<String, ll.LatLng> _ultimaPosicion = {};
  Map<String, DateTime> _ultimoTiempo = {};
  Map<String, bool> _equipoActivo = {};

  // ============================================
  // 🔄 ESTADO DE CARGA INICIAL
  // ============================================
  bool _cargandoInicial = true;
  bool _datosInicialCargados = false;

  // Contador de créditos usados (para mostrar en UI)
  int _creditosUsados = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ============================================
  // 📥 CARGAR DATOS INICIALES
  // ============================================
  Future<void> _cargarDatosIniciales() async {
    try {
      // 1. Cargar info de equipos
      final equipos = await _repositorio.obtenerEquiposRaw();

      // 2. Cargar últimas posiciones conocidas
      final ultimasPosiciones = await _repositorio.obtenerUltimasPosiciones();

      if (mounted) {
        setState(() {
          // Guardar info de equipos
          for (var e in equipos) {
            equiposInfo[e['id_equipo_control'].toString()] = e;
          }

          // Procesar últimas posiciones
          final ahora = DateTime.now();

          for (var pos in ultimasPosiciones) {
            final id = pos['fk_emisor'].toString();

            // Solo si el equipo está habilitado
            if (equiposInfo[id]?['habilitado'] != true) continue;

            final lat = (pos['lat_grados'] as num?)?.toDouble() ?? 0.0;
            final lon = (pos['lon_grados'] as num?)?.toDouble() ?? 0.0;

            // Filtrar coordenadas inválidas
            if (lat == 0.0 || lon == 0.0) continue;
            if (lat < -20 || lat > -10 || lon < -75 || lon > -65) continue;

            final tiempo = DateTime.parse(pos['tiempo']);
            final posicion = ll.LatLng(lat, lon);

            _ultimaPosicion[id] = posicion;
            _ultimoTiempo[id] = tiempo;
            _posicionAnterior[id] = posicion;
            _tiempoAnterior[id] = tiempo;

            // Inicializar punto de inicio para GraphHopper
            _puntoInicioGH[id] = posicion;
            _ultimaLlamadaGH[id] = ahora;

            // Determinar si está activo
            final segundos = ahora.difference(tiempo).inSeconds.abs();
            _equipoActivo[id] = segundos <= 60;
            _velocidades[id] = 0.0;
            _distanciasAcumuladas[id] = 0.0;
          }

          _cargandoInicial = false;
          _datosInicialCargados = true;
        });
      }

      debugPrint("✅ Stream: Datos iniciales cargados (${_ultimaPosicion.length} equipos)");

    } catch (e) {
      debugPrint("❌ Error cargando datos iniciales: $e");
      if (mounted) {
        setState(() {
          _cargandoInicial = false;
        });
      }
    }
  }

  // ============================================
  // 🗺️ LLAMAR A GRAPHHOPPER (cada 90 segundos)
  // ============================================
  Future<void> _verificarYLlamarGraphHopper(String id, ll.LatLng posicionActual) async {
    final ahora = DateTime.now();
    final ultimaLlamada = _ultimaLlamadaGH[id];

    // Verificar si han pasado 90 segundos
    if (ultimaLlamada == null) {
      _puntoInicioGH[id] = posicionActual;
      _ultimaLlamadaGH[id] = ahora;
      return;
    }

    final segundosTranscurridos = ahora.difference(ultimaLlamada).inSeconds;

    if (segundosTranscurridos >= _intervaloGraphHopper) {
      final puntoInicio = _puntoInicioGH[id];

      if (puntoInicio != null) {
        // Calcular distancia entre inicio y actual
        final distancia = _calcularDistanciaMetros(puntoInicio, posicionActual);

        // Solo llamar si se movió más de 50 metros
        if (distancia > 50) {
          debugPrint("🗺️ GraphHopper [$id]: Corrigiendo tramo (${distancia.toStringAsFixed(0)}m)...");

          try {
            final rutaCorregida = await GraphhopperServicio.corregirRuta([
              puntoInicio,
              posicionActual,
            ]);

            if (rutaCorregida != null && rutaCorregida.isNotEmpty) {
              // Agregar a las rutas corregidas
              _rutasCorregidas.putIfAbsent(id, () => []);

              // Si ya hay puntos, evitar duplicar el punto de conexión
              if (_rutasCorregidas[id]!.isNotEmpty) {
                _rutasCorregidas[id]!.addAll(rutaCorregida.skip(1));
              } else {
                _rutasCorregidas[id]!.addAll(rutaCorregida);
              }

              // Limpiar rastro crudo (ya fue procesado)
              _rastrosCrudos[id]?.clear();

              _creditosUsados++;
              debugPrint("✅ GraphHopper [$id]: Ruta corregida (${rutaCorregida.length} puntos) - Créditos: $_creditosUsados");
            }
          } catch (e) {
            debugPrint("❌ GraphHopper Error: $e");
          }
        } else {
          debugPrint("⏭️ GraphHopper [$id]: Sin movimiento significativo (${distancia.toStringAsFixed(0)}m)");
        }

        // Actualizar punto de inicio y tiempo
        _puntoInicioGH[id] = posicionActual;
        _ultimaLlamadaGH[id] = ahora;
      }
    }
  }

  // --- FUNCIÓN PARA CALCULAR DISTANCIA (Fórmula Haversine) ---
  double _calcularDistanciaMetros(ll.LatLng p1, ll.LatLng p2) {
    const double p = 0.017453292519943295;
    final double a = 0.5 -
        math.cos((p2.latitude - p1.latitude) * p) / 2 +
        math.cos(p1.latitude * p) * math.cos(p2.latitude * p) *
            (1 - math.cos((p2.longitude - p1.longitude) * p)) / 2;

    return 12742 * math.asin(math.sqrt(a)) * 1000;
  }

  @override
  Widget build(BuildContext context) {

    // Mostrar loading mientras carga datos iniciales
    if (_cargandoInicial) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.orange),
              const SizedBox(height: 20),
              Text(
                "Cargando posiciones...",
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _repositorio.obtenerTrayectoriaStream(),
        builder: (context, snapshot) {
          final ahora = DateTime.now();

          // ============================================
          // 📊 PROCESAR NUEVOS DATOS DEL STREAM
          // ============================================
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {

            // Encontrar la última posición de cada equipo en el stream
            Map<String, Map<String, dynamic>> ultimosPuntos = {};

            for (var punto in snapshot.data!) {
              final id = punto['fk_emisor'].toString();
              final tiempo = DateTime.parse(punto['tiempo']);

              if (!ultimosPuntos.containsKey(id) ||
                  tiempo.isAfter(DateTime.parse(ultimosPuntos[id]!['tiempo']))) {
                ultimosPuntos[id] = punto;
              }
            }

            // Actualizar con datos del stream
            for (var entry in ultimosPuntos.entries) {
              final id = entry.key;
              final punto = entry.value;

              if (equiposInfo[id]?['habilitado'] != true) continue;

              final lat = (punto['lat_grados'] as num?)?.toDouble() ?? 0.0;
              final lon = (punto['lon_grados'] as num?)?.toDouble() ?? 0.0;

              // Filtrar coordenadas inválidas
              if (lat == 0.0 || lon == 0.0) continue;
              if (lat < -20 || lat > -10 || lon < -75 || lon > -65) continue;

              final posActual = ll.LatLng(lat, lon);
              final tiempoActual = DateTime.parse(punto['tiempo']);

              final segundosDesdeUltimo = ahora.difference(tiempoActual).inSeconds.abs();
              final estaActivo = segundosDesdeUltimo <= 60;

              _equipoActivo[id] = estaActivo;
              _ultimaPosicion[id] = posActual;
              _ultimoTiempo[id] = tiempoActual;

              // Calcular telemetría si activo
              if (estaActivo && _posicionAnterior.containsKey(id)) {
                double metrosTramo = _calcularDistanciaMetros(_posicionAnterior[id]!, posActual);

                if (metrosTramo > 2) {
                  _distanciasAcumuladas[id] = (_distanciasAcumuladas[id] ?? 0) + (metrosTramo / 1000);

                  double segundos = tiempoActual.difference(_tiempoAnterior[id]!).inSeconds.toDouble();
                  if (segundos > 0) {
                    _velocidades[id] = (metrosTramo / segundos) * 3.6;
                  }
                }

                // Agregar al rastro CRUDO (sin corregir)
                _rastrosCrudos.putIfAbsent(id, () => []);
                _rastrosCrudos[id]!.add(posActual);

                // Limitar rastro crudo a últimos 100 puntos
                if (_rastrosCrudos[id]!.length > 100) {
                  _rastrosCrudos[id] = _rastrosCrudos[id]!.sublist(_rastrosCrudos[id]!.length - 100);
                }

                // 🗺️ VERIFICAR SI TOCA LLAMAR A GRAPHHOPPER
                _verificarYLlamarGraphHopper(id, posActual);
              }

              _posicionAnterior[id] = posActual;
              _tiempoAnterior[id] = tiempoActual;
            }
          }

          // ============================================
          // 📍 CONSTRUIR MARCADORES
          // ============================================
          Map<String, Marker> marcadoresVisibles = {};

          for (var entry in _ultimaPosicion.entries) {
            final id = entry.key;
            final posicion = entry.value;

            // Verificar que el equipo esté habilitado
            if (equiposInfo[id]?['habilitado'] != true) continue;

            // Actualizar estado activo/inactivo
            final tiempo = _ultimoTiempo[id];
            if (tiempo != null) {
              final segundos = ahora.difference(tiempo).inSeconds.abs();
              _equipoActivo[id] = segundos <= 60;
            }

            final estaActivo = _equipoActivo[id] ?? false;
            final color = estaActivo ? Colors.greenAccent : Colors.grey;

            marcadoresVisibles[id] = Marker(
              key: ValueKey("live_$id"),
              point: posicion,
              width: 80,
              height: 80,
              child: _buildIconoOperador(id, color),
            );
          }

          // ============================================
          // 🛤️ CONSTRUIR POLILÍNEAS
          // ============================================
          List<Polyline> polylines = [];

          for (final id in _equipoActivo.keys) {
            if (_equipoActivo[id] != true) continue;

            // 1. RUTA CORREGIDA (verde, sobre las calles)
            final rutaCorregida = _rutasCorregidas[id];
            if (rutaCorregida != null && rutaCorregida.length >= 2) {
              polylines.add(
                Polyline(
                  points: rutaCorregida,
                  color: Colors.greenAccent.withOpacity(0.9),
                  strokeWidth: 5,
                ),
              );
            }

            // 2. RASTRO CRUDO (naranja semi-transparente, GPS sin corregir)
            final rastroCrudo = _rastrosCrudos[id];
            if (rastroCrudo != null && rastroCrudo.length >= 2) {
              // Conectar desde el último punto corregido al rastro crudo
              List<ll.LatLng> puntosCrudos = [];

              if (rutaCorregida != null && rutaCorregida.isNotEmpty) {
                puntosCrudos.add(rutaCorregida.last);
              }
              puntosCrudos.addAll(rastroCrudo);

              if (puntosCrudos.length >= 2) {
                polylines.add(
                  Polyline(
                    points: puntosCrudos,
                    color: Colors.orange.withOpacity(0.6),
                    strokeWidth: 3,
                  ),
                );
              }
            }
          }

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: _ultimaPosicion.isNotEmpty
                      ? _ultimaPosicion.values.first
                      : const ll.LatLng(-15.488405, -70.150497),
                  initialZoom: 15,
                ),
                children: [
                  // CAPA 1: MAPA SATELITAL
                  TileLayer(
                    urlTemplate: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                  ),

                  // CAPA 2: POLILÍNEAS
                  PolylineLayer(
                    polylines: polylines,
                  ),

                  // CAPA 3: MARCADORES
                  MarkerLayer(markers: marcadoresVisibles.values.toList()),
                ],
              ),

              // --- PANEL INFERIOR ---
              Positioned(
                bottom: 20, left: 0, right: 0,
                child: SizedBox(
                  height: 100,
                  child: marcadoresVisibles.isEmpty
                      ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "No hay equipos activos",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                      : ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    children: marcadoresVisibles.keys.map((id) => _buildCardKPI(id)).toList(),
                  ),
                ),
              ),

              // INDICADOR DE GRAPHHOPPER Y CRÉDITOS
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.route, color: Colors.greenAccent, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'GraphHopper',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Créditos: $_creditosUsados',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // LEYENDA DE COLORES
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _leyendaItem(Colors.greenAccent, "Ruta corregida"),
                      const SizedBox(height: 4),
                      _leyendaItem(Colors.orange.withOpacity(0.6), "GPS en vivo"),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _leyendaItem(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ],
    );
  }

  // Tarjeta de datos por cada operador
  Widget _buildCardKPI(String id) {
    final nombre = equiposInfo[id]?['codigo_equipo_control'] ?? "Unidad";
    final vel = _velocidades[id] ?? 0.0;
    final dist = _distanciasAcumuladas[id] ?? 0.0;
    final activo = _equipoActivo[id] ?? false;

    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activo
              ? (vel > 40 ? Colors.redAccent : Colors.green)
              : Colors.grey,
          width: 2,
        ),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nombre,
                  style: TextStyle(
                    color: activo ? Colors.orange : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                activo ? Icons.circle : Icons.circle_outlined,
                color: activo ? Colors.green : Colors.grey,
                size: 10,
              ),
            ],
          ),
          const SizedBox(height: 6),
          _datoFila(Icons.speed, "${vel.toStringAsFixed(1)} km/h",
              activo ? Colors.greenAccent : Colors.grey),
          _datoFila(Icons.route, "${dist.toStringAsFixed(2)} km rec.",
              activo ? Colors.cyanAccent : Colors.grey),
        ],
      ),
    );
  }

  Widget _datoFila(IconData icono, String texto, Color color) {
    return Row(
      children: [
        Icon(icono, size: 14, color: color),
        const SizedBox(width: 6),
        Text(texto, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _buildIconoOperador(String id, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color, width: 1)
          ),
          child: Text(
            equiposInfo[id]?['codigo_equipo_control'] ?? "",
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        Icon(Icons.local_shipping, color: color, size: 38),
      ],
    );
  }
}