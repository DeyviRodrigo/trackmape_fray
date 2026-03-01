import 'dart:async';
import 'package:latlong2/latlong.dart' as ll;
import 'graphhopper_servicio.dart';

/// ============================================================
/// GRAPHHOPPER MAP MATCHING - GESTOR DE BUFFER
/// ============================================================
/// Esta clase gestiona el buffer de puntos GPS y los envía
/// a GraphHopper para corrección cuando se cumple el intervalo.
///
/// USO:
/// 1. Llamar agregarPunto() cada vez que llegue un GPS
/// 2. El sistema automáticamente envía a GraphHopper cada X segundos
/// 3. Obtener la ruta corregida con obtenerRutaCorregida()
/// ============================================================

class GraphhopperMapMatching {

  // ============================================
  // 📦 BUFFER DE PUNTOS POR EQUIPO
  // ============================================
  final Map<String, List<ll.LatLng>> _bufferPorEquipo = {};
  final Map<String, List<ll.LatLng>> _rutasCorregidas = {};
  final Map<String, DateTime> _ultimoEnvio = {};

  // ============================================
  // 🔄 ESTADO DE PROCESAMIENTO
  // ============================================
  final Map<String, bool> _procesando = {};

  /// ========================================
  /// AGREGAR PUNTO AL BUFFER
  /// ========================================
  /// Agrega un punto GPS al buffer del equipo.
  /// Si ha pasado el intervalo configurado, envía a GraphHopper.
  ///
  /// [idEquipo] - ID único del equipo/vehículo
  /// [punto] - Coordenada GPS actual
  ///
  /// Retorna true si se envió a GraphHopper, false si se acumuló
  Future<bool> agregarPunto(String idEquipo, ll.LatLng punto) async {

    // Inicializar buffer si no existe
    _bufferPorEquipo.putIfAbsent(idEquipo, () => []);
    _rutasCorregidas.putIfAbsent(idEquipo, () => []);
    _ultimoEnvio.putIfAbsent(idEquipo, () => DateTime.now());
    _procesando.putIfAbsent(idEquipo, () => false);

    // Agregar punto al buffer
    _bufferPorEquipo[idEquipo]!.add(punto);

    // También agregar a ruta corregida temporalmente (para mostrar algo mientras procesa)
    _rutasCorregidas[idEquipo]!.add(punto);

    // Limitar tamaño de la ruta corregida visible (últimos 100 puntos)
    if (_rutasCorregidas[idEquipo]!.length > 100) {
      _rutasCorregidas[idEquipo]!.removeAt(0);
    }

    // Verificar si debemos enviar a GraphHopper
    final ahora = DateTime.now();
    final segundosDesdeUltimoEnvio = ahora.difference(_ultimoEnvio[idEquipo]!).inSeconds;

    // ============================================
    // ⏱️ AQUÍ SE USA EL INTERVALO DE 10 SEGUNDOS
    // Puedes cambiar este valor en GraphhopperServicio.intervaloEnvioSegundos
    // ============================================
    if (segundosDesdeUltimoEnvio >= GraphhopperServicio.intervaloEnvioSegundos &&
        _bufferPorEquipo[idEquipo]!.length >= GraphhopperServicio.minimoPuntosParaEnviar &&
        !_procesando[idEquipo]!) {

      await _enviarAGraphHopper(idEquipo);
      return true;
    }

    return false;
  }

  /// Envía los puntos acumulados a GraphHopper
  Future<void> _enviarAGraphHopper(String idEquipo) async {

    if (_procesando[idEquipo] == true) return;

    _procesando[idEquipo] = true;

    try {
      final puntos = List<ll.LatLng>.from(_bufferPorEquipo[idEquipo]!);

      if (puntos.length < 2) {
        _procesando[idEquipo] = false;
        return;
      }

      print('🚀 Enviando ${puntos.length} puntos de $idEquipo a GraphHopper...');

      // Llamar a la API de GraphHopper
      final puntosCorregidos = await GraphhopperServicio.corregirRuta(puntos);

      if (puntosCorregidos != null && puntosCorregidos.isNotEmpty) {
        // Reemplazar los últimos puntos con los corregidos
        _rutasCorregidas[idEquipo] = puntosCorregidos;
        print('✅ Ruta corregida para $idEquipo: ${puntosCorregidos.length} puntos');
      } else {
        print('⚠️ GraphHopper no retornó puntos, usando originales');
      }

      // Limpiar buffer y actualizar tiempo
      _bufferPorEquipo[idEquipo]!.clear();
      _ultimoEnvio[idEquipo] = DateTime.now();

    } catch (e) {
      print('❌ Error enviando a GraphHopper: $e');
    } finally {
      _procesando[idEquipo] = false;
    }
  }

  /// ========================================
  /// OBTENER RUTA CORREGIDA
  /// ========================================
  /// Retorna la ruta corregida para un equipo.
  /// Si no hay ruta corregida, retorna los puntos originales.
  List<ll.LatLng> obtenerRutaCorregida(String idEquipo) {
    return _rutasCorregidas[idEquipo] ?? [];
  }

  /// ========================================
  /// OBTENER TODAS LAS RUTAS CORREGIDAS
  /// ========================================
  Map<String, List<ll.LatLng>> obtenerTodasLasRutas() {
    return Map.from(_rutasCorregidas);
  }

  /// ========================================
  /// LIMPIAR BUFFER DE UN EQUIPO
  /// ========================================
  void limpiarBuffer(String idEquipo) {
    _bufferPorEquipo[idEquipo]?.clear();
    _rutasCorregidas[idEquipo]?.clear();
  }

  /// ========================================
  /// LIMPIAR TODO
  /// ========================================
  void limpiarTodo() {
    _bufferPorEquipo.clear();
    _rutasCorregidas.clear();
    _ultimoEnvio.clear();
    _procesando.clear();
  }

  /// ========================================
  /// MÉTODO LEGACY - Para compatibilidad
  /// ========================================
  /// Este método se mantiene para no romper el código existente.
  /// Ahora simplemente retorna los puntos sin modificar.
  /// La corrección real se hace de forma asíncrona.
  List<ll.LatLng> ajustarRutaSync(List<ll.LatLng> puntos) {
    // Retornar los puntos tal cual - la corrección real es asíncrona
    return puntos;
  }
}