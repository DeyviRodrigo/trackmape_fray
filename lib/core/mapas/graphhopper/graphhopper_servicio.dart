import 'dart:convert';
import 'package:http/http.dart' as http;

class GraphhopperServicio {

  final String apiKey;

  GraphhopperServicio(this.apiKey);

  Future<Map<String, dynamic>> obtenerRuta(
      double lat1,
      double lon1,
      double lat2,
      double lon2
      ) async {

    final url = Uri.parse(
        "https://graphhopper.com/api/1/route"
            "?point=$lat1,$lon1"
            "&point=$lat2,$lon2"
            "&vehicle=car"
            "&locale=es"
            "&key=$apiKey"
    );

    final response = await http.get(url);

    return jsonDecode(response.body);
  }
}