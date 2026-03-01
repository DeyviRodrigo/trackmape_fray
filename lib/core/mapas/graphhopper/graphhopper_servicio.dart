import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as ll;

/// ============================================================
/// SERVICIO GRAPHHOPPER - MAP MATCHING API
/// ============================================================
/// Este servicio se conecta a la API real de GraphHopper para
/// corregir puntos GPS y ajustarlos a las vías reales.
///
/// CONFIGURACIÓN DE CRÉDITOS:
/// - Plan Gratis: 500 créditos/día
/// - Map Matching: 1 crédito por cada 50 puntos
/// - Recomendación: Acumular puntos antes de enviar
/// ============================================================

class GraphhopperServicio {

  // ============================================
  // 🔑 API KEY - Tu clave de GraphHopper
  // ============================================
  static const String apiKey = '4872623e-4fef-4d7b-80b9-9ead2c891594';

  // ============================================
  // ⏱️ INTERVALO DE ENVÍO (en segundos)
  // Cambia este valor para ajustar cada cuánto
  // se envían los puntos a GraphHopper
  // ============================================
  static const int intervaloEnvioSegundos = 10;

  // ============================================
  // 📍 MÍNIMO DE PUNTOS PARA ENVIAR
  // Debe haber al menos 2 puntos para hacer
  // map matching
  // ============================================
  static const int minimoPuntosParaEnviar = 2;

  // URL base de la API
  static const String _baseUrl = 'https://graphhopper.com/api/1';

  /// ========================================
  /// MAP MATCHING - Corregir GPS a vías
  /// ========================================
  /// Recibe una lista de coordenadas GPS y retorna
  /// las coordenadas corregidas sobre las calles reales.
  ///
  /// [puntos] - Lista de LatLng con las coordenadas GPS
  /// [profile] - Perfil de vehículo: "car", "bike", "foot"
  ///
  /// Retorna una lista de LatLng corregidos o null si falla
  static Future<List<ll.LatLng>?> corregirRuta(
      List<ll.LatLng> puntos, {
        String profile = 'car',
      }) async {

    if (puntos.length < minimoPuntosParaEnviar) {
      print('⚠️ GraphHopper: Se necesitan al menos $minimoPuntosParaEnviar puntos');
      return null;
    }

    try {
      // Construir el XML GPX con los puntos
      final gpxContent = _construirGPX(puntos);

      final url = Uri.parse(
          '$_baseUrl/match?key=$apiKey&profile=$profile&type=json'
      );

      print('📤 GraphHopper: Enviando ${puntos.length} puntos para Map Matching...');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/xml',
        },
        body: gpxContent,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extraer los puntos corregidos de la respuesta
        final puntosCorregidos = _extraerPuntosDeRespuesta(data);

        print('✅ GraphHopper: Recibidos ${puntosCorregidos.length} puntos corregidos');

        return puntosCorregidos;

      } else {
        print('❌ GraphHopper Error ${response.statusCode}: ${response.body}');
        return null;
      }

    } catch (e) {
      print('❌ GraphHopper Exception: $e');
      return null;
    }
  }

  /// Construye un archivo GPX con los puntos GPS
  static String _construirGPX(List<ll.LatLng> puntos) {
    final buffer = StringBuffer();

    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<gpx version="1.1" creator="TrackMAPE">');
    buffer.writeln('  <trk>');
    buffer.writeln('    <trkseg>');

    for (final punto in puntos) {
      buffer.writeln('      <trkpt lat="${punto.latitude}" lon="${punto.longitude}"></trkpt>');
    }

    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');
    buffer.writeln('</gpx>');

    return buffer.toString();
  }

  /// Extrae los puntos corregidos de la respuesta JSON
  static List<ll.LatLng> _extraerPuntosDeRespuesta(Map<String, dynamic> data) {
    final List<ll.LatLng> resultado = [];

    try {
      // La respuesta tiene un campo "paths" con la geometría
      if (data['paths'] != null && (data['paths'] as List).isNotEmpty) {
        final path = data['paths'][0];

        // Los puntos vienen codificados en polyline o como coordinates
        if (path['points'] != null) {

          // Si es un string, está codificado en polyline
          if (path['points'] is String) {
            resultado.addAll(_decodificarPolyline(path['points']));
          }
          // Si es un objeto con coordinates
          else if (path['points']['coordinates'] != null) {
            for (final coord in path['points']['coordinates']) {
              resultado.add(ll.LatLng(coord[1].toDouble(), coord[0].toDouble()));
            }
          }
        }
      }

      // Alternativa: buscar en "matched_points"
      if (resultado.isEmpty && data['matched_points'] != null) {
        for (final punto in data['matched_points']) {
          resultado.add(ll.LatLng(
            punto['lat'].toDouble(),
            punto['lon'].toDouble(),
          ));
        }
      }

    } catch (e) {
      print('⚠️ Error extrayendo puntos: $e');
    }

    return resultado;
  }

  /// Decodifica una polyline encoded de Google/GraphHopper
  static List<ll.LatLng> _decodificarPolyline(String encoded) {
    List<ll.LatLng> puntos = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      puntos.add(ll.LatLng(lat / 1E5, lng / 1E5));
    }

    return puntos;
  }

  /// ========================================
  /// ROUTING - Obtener ruta entre 2 puntos
  /// ========================================
  static Future<Map<String, dynamic>?> obtenerRuta(
      double lat1, double lon1,
      double lat2, double lon2, {
        String profile = 'car',
      }) async {

    final url = Uri.parse(
        '$_baseUrl/route'
            '?point=$lat1,$lon1'
            '&point=$lat2,$lon2'
            '&profile=$profile'
            '&locale=es'
            '&key=$apiKey'
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      print('❌ GraphHopper Routing Error: ${response.statusCode}');
      return null;

    } catch (e) {
      print('❌ GraphHopper Routing Exception: $e');
      return null;
    }
  }
}