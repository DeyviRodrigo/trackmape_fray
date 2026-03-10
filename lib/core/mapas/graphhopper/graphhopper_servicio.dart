import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as ll;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// ============================================================
/// SERVICIO GRAPHHOPPER - ROUTING API (GRATIS)
/// ============================================================
/// Usa la Routing API para obtener rutas entre puntos.
/// Plan Gratis: 500 créditos/día
/// Cada llamada = 1 crédito
/// ============================================================

class GraphhopperServicio {

  // ============================================
  // 🔑 API KEY
  // ============================================
  static String get _apiKey => dotenv.env['GRAPHHOPPER_API_KEY'] ?? '';

  // URL base de la API
  static const String _baseUrl = 'https://graphhopper.com/api/1';

  // ============================================
  // ⏱️ CONFIGURACIÓN
  // ============================================
  static const int intervaloEnvioSegundos = 30;
  static const int minimoPuntosParaEnviar = 2;

  /// ========================================
  /// CORREGIR RUTA USANDO ROUTING API
  /// ========================================
  /// Toma el primer y último punto, y obtiene
  /// la ruta real por las calles.
  ///
  /// [puntos] - Lista de LatLng con las coordenadas GPS
  /// [profile] - Perfil: "car", "bike", "foot"
  ///
  /// Retorna la ruta corregida sobre las calles
  static Future<List<ll.LatLng>?> corregirRuta(
      List<ll.LatLng> puntos, {
        String profile = 'car',
      }) async {

    if (puntos.length < minimoPuntosParaEnviar) {
      print('⚠️ GraphHopper: Se necesitan al menos $minimoPuntosParaEnviar puntos');
      return null;
    }

    try {
      // Tomar punto inicial y final
      final puntoInicio = puntos.first;
      final puntoFin = puntos.last;

      // Construir URL con los puntos
      final url = Uri.parse(
          '$_baseUrl/route'
              '?point=${puntoInicio.latitude},${puntoInicio.longitude}'
              '&point=${puntoFin.latitude},${puntoFin.longitude}'
              '&profile=$profile'
              '&locale=es'
              '&points_encoded=false'
              '&key=$_apiKey'
      );

      print('📤 GraphHopper Routing: ${puntoInicio.latitude},${puntoInicio.longitude} → ${puntoFin.latitude},${puntoFin.longitude}');

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      print('📥 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final puntosRuta = _extraerPuntosDeRuta(data);

        if (puntosRuta.isNotEmpty) {
          print('✅ GraphHopper: Ruta con ${puntosRuta.length} puntos');
          return puntosRuta;
        }
      } else {
        print('❌ GraphHopper Error ${response.statusCode}: ${response.body}');
      }

      return null;

    } catch (e) {
      print('❌ GraphHopper Exception: $e');
      return null;
    }
  }

  /// Extrae los puntos de la respuesta de Routing API
  static List<ll.LatLng> _extraerPuntosDeRuta(Map<String, dynamic> data) {
    final List<ll.LatLng> resultado = [];

    try {
      if (data['paths'] != null && (data['paths'] as List).isNotEmpty) {
        final path = data['paths'][0];

        if (path['points'] != null && path['points']['coordinates'] != null) {
          final coordinates = path['points']['coordinates'] as List;

          for (final coord in coordinates) {
            // GeoJSON: [lon, lat] → LatLng(lat, lon)
            resultado.add(ll.LatLng(
              (coord[1] as num).toDouble(),
              (coord[0] as num).toDouble(),
            ));
          }
        }
      }
    } catch (e) {
      print('⚠️ Error extrayendo puntos: $e');
    }

    return resultado;
  }

  /// ========================================
  /// CORREGIR RUTA COMPLETA (Múltiples segmentos)
  /// ========================================
  /// Para rutas largas, divide en segmentos y
  /// obtiene la ruta de cada segmento.
  ///
  /// Usa más créditos pero es más preciso.
  static Future<List<ll.LatLng>?> corregirRutaCompleta(
      List<ll.LatLng> puntos, {
        String profile = 'car',
        int cadaPuntos = 10,  // Cada cuántos puntos hacer una llamada
      }) async {

    if (puntos.length < 2) return null;

    final List<ll.LatLng> rutaCompleta = [];

    // Dividir en segmentos
    for (int i = 0; i < puntos.length - 1; i += cadaPuntos) {
      final inicio = puntos[i];
      final finIdx = (i + cadaPuntos < puntos.length) ? i + cadaPuntos : puntos.length - 1;
      final fin = puntos[finIdx];

      // Obtener ruta del segmento
      final segmento = await corregirRuta([inicio, fin], profile: profile);

      if (segmento != null && segmento.isNotEmpty) {
        // Evitar duplicar el punto de conexión
        if (rutaCompleta.isNotEmpty) {
          rutaCompleta.addAll(segmento.skip(1));
        } else {
          rutaCompleta.addAll(segmento);
        }
      }

      // Pausa para no saturar la API
      await Future.delayed(const Duration(milliseconds: 200));
    }

    return rutaCompleta.isEmpty ? null : rutaCompleta;
  }

  /// ========================================
  /// OBTENER INFO DE RUTA
  /// ========================================
  /// Retorna distancia y tiempo además de los puntos
  static Future<Map<String, dynamic>?> obtenerInfoRuta(
      ll.LatLng inicio,
      ll.LatLng fin, {
        String profile = 'car',
      }) async {

    final url = Uri.parse(
        '$_baseUrl/route'
            '?point=${inicio.latitude},${inicio.longitude}'
            '&point=${fin.latitude},${fin.longitude}'
            '&profile=$profile'
            '&locale=es'
            '&points_encoded=false'
            '&key=$_apiKey'
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['paths'] != null && (data['paths'] as List).isNotEmpty) {
          final path = data['paths'][0];

          return {
            'distancia_metros': path['distance'],
            'tiempo_ms': path['time'],
            'puntos': _extraerPuntosDeRuta(data),
          };
        }
      }

      return null;

    } catch (e) {
      print('❌ GraphHopper Error: $e');
      return null;
    }
  }
}

