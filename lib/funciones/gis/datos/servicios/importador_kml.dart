import 'package:latlong2/latlong.dart' as ll;
import 'package:xml/xml.dart';

class ResultadoImportacionKml {
  const ResultadoImportacionKml({
    required this.items,
    required this.descartados,
  });

  final List<ItemImportacionKml> items;
  final int descartados;
}

class ItemImportacionKml {
  ItemImportacionKml({
    required this.nombreOriginal,
    required this.categoria,
    required this.tipoOperativo,
    required this.nombre,
    required this.color,
    required this.prioridad,
    required this.activo,
    required this.geojson,
    this.seleccionado = true,
  });

  final String nombreOriginal;
  String categoria;
  String tipoOperativo;
  String nombre;
  String color;
  int prioridad;
  bool activo;
  bool seleccionado;
  Map<String, dynamic> geojson;

  List<ll.LatLng> get puntos {
    final coordinates = geojson['coordinates'];
    if (categoria == 'area' && coordinates is List && coordinates.isNotEmpty) {
      final exterior = coordinates.first;
      if (exterior is List) return _coordinatesToLatLng(exterior);
    }

    if (categoria == 'ruta' && coordinates is List) {
      return _coordinatesToLatLng(coordinates);
    }

    if (categoria == 'punto' && coordinates is List && coordinates.length >= 2) {
      final lon = _toDouble(coordinates[0]);
      final lat = _toDouble(coordinates[1]);
      if (lat != null && lon != null) return [ll.LatLng(lat, lon)];
    }

    return const [];
  }
}

class ImportadorKml {
  const ImportadorKml();

  ResultadoImportacionKml parse(String contenido) {
    final texto = contenido.trim();
    if (texto.isEmpty) {
      throw const FormatException('El KML esta vacio.');
    }

    late XmlDocument document;
    try {
      document = XmlDocument.parse(texto);
    } catch (e) {
      throw FormatException('El XML/KML no es valido: $e');
    }

    final placemarks = document.descendants
        .whereType<XmlElement>()
        .where((elemento) => _localName(elemento) == 'Placemark')
        .toList();

    final items = <ItemImportacionKml>[];
    var descartados = 0;
    var contadorArea = 0;
    var contadorRuta = 0;
    var contadorPunto = 0;

    for (final placemark in placemarks) {
      final nombrePlacemark = _textoHijoDirecto(placemark, 'name');
      final geometrias = _geometriasDePlacemark(placemark);

      for (final geometria in geometrias) {
        final tipo = _localName(geometria);
        final item = _crearItem(
          geometria: geometria,
          tipo: tipo,
          nombrePlacemark: nombrePlacemark,
          contadorArea: contadorArea + 1,
          contadorRuta: contadorRuta + 1,
          contadorPunto: contadorPunto + 1,
        );

        if (item == null) {
          descartados++;
          continue;
        }

        switch (item.categoria) {
          case 'area':
            contadorArea++;
            break;
          case 'ruta':
            contadorRuta++;
            break;
          case 'punto':
            contadorPunto++;
            break;
        }

        items.add(item);
      }
    }

    if (items.isEmpty) {
      throw FormatException(
        'No se encontraron Point, LineString o Polygon validos. Descartados: $descartados.',
      );
    }

    return ResultadoImportacionKml(items: items, descartados: descartados);
  }

  List<XmlElement> _geometriasDePlacemark(XmlElement placemark) {
    final geometrias = <XmlElement>[];

    for (final hijo in placemark.childElements) {
      if (_esGeometriaSoportada(hijo)) {
        geometrias.add(hijo);
        continue;
      }

      if (_localName(hijo) == 'MultiGeometry') {
        for (final geometria in hijo.childElements) {
          if (_esGeometriaSoportada(geometria)) {
            geometrias.add(geometria);
          }
        }
      }
    }

    return geometrias;
  }

  bool _esGeometriaSoportada(XmlElement elemento) {
    final nombre = _localName(elemento);
    return nombre == 'Point' || nombre == 'LineString' || nombre == 'Polygon';
  }

  ItemImportacionKml? _crearItem({
    required XmlElement geometria,
    required String tipo,
    required String nombrePlacemark,
    required int contadorArea,
    required int contadorRuta,
    required int contadorPunto,
  }) {
    switch (tipo) {
      case 'Point':
        final puntos = _leerCoordenadas(geometria);
        if (puntos.isEmpty) return null;
        final punto = puntos.first;
        final nombre = _nombreImportado(
          nombrePlacemark,
          'Punto importado $contadorPunto',
        );
        return ItemImportacionKml(
          nombreOriginal: nombrePlacemark,
          categoria: 'punto',
          tipoOperativo: 'Punto operativo',
          nombre: nombre,
          color: '#4caf50',
          prioridad: 0,
          activo: true,
          geojson: {
            'type': 'Point',
            'coordinates': [punto.longitude, punto.latitude],
          },
        );
      case 'LineString':
        final puntos = _leerCoordenadas(geometria);
        if (puntos.length < 2) return null;
        final nombre = _nombreImportado(
          nombrePlacemark,
          'Ruta importada $contadorRuta',
        );
        return ItemImportacionKml(
          nombreOriginal: nombrePlacemark,
          categoria: 'ruta',
          tipoOperativo: 'Ruta acarreo',
          nombre: nombre,
          color: '#00bcd4',
          prioridad: 0,
          activo: true,
          geojson: {
            'type': 'LineString',
            'coordinates': puntos.map((p) => [p.longitude, p.latitude]).toList(),
          },
        );
      case 'Polygon':
        final puntos = _leerCoordenadasPoligono(geometria);
        if (puntos.length < 3) return null;
        final cerrados = _cerrarPoligono(puntos);
        final nombre = _nombreImportado(
          nombrePlacemark,
          'Area importada $contadorArea',
        );
        return ItemImportacionKml(
          nombreOriginal: nombrePlacemark,
          categoria: 'area',
          tipoOperativo: _inferirTipoArea(nombre),
          nombre: nombre,
          color: '#ff9800',
          prioridad: 0,
          activo: true,
          geojson: {
            'type': 'Polygon',
            'coordinates': [
              cerrados.map((p) => [p.longitude, p.latitude]).toList(),
            ],
          },
        );
      default:
        return null;
    }
  }

  List<ll.LatLng> _leerCoordenadasPoligono(XmlElement polygon) {
    final outerBoundary = _primerDescendiente(polygon, 'outerBoundaryIs');

    if (outerBoundary != null) {
      return _leerCoordenadas(outerBoundary);
    }

    return _leerCoordenadas(polygon);
  }

  List<ll.LatLng> _leerCoordenadas(XmlElement elemento) {
    final coordenadas = _primerDescendiente(elemento, 'coordinates');

    if (coordenadas == null) return const [];
    return _parseCoordenadas(coordenadas.innerText);
  }

  XmlElement? _primerDescendiente(XmlElement elemento, String nombre) {
    for (final hijo in elemento.descendants.whereType<XmlElement>()) {
      if (_localName(hijo) == nombre) return hijo;
    }
    return null;
  }

  List<ll.LatLng> _parseCoordenadas(String raw) {
    final puntos = <ll.LatLng>[];
    final tokens = raw.trim().split(RegExp(r'\s+'));

    for (final token in tokens) {
      final partes = token.split(',');
      if (partes.length < 2) continue;
      final lon = _toDouble(partes[0]);
      final lat = _toDouble(partes[1]);
      if (lat == null || lon == null) continue;
      if (lat < -90 || lat > 90 || lon < -180 || lon > 180) continue;
      puntos.add(ll.LatLng(lat, lon));
    }

    return puntos;
  }

  List<ll.LatLng> _cerrarPoligono(List<ll.LatLng> puntos) {
    final cerrados = List<ll.LatLng>.from(puntos);
    if (cerrados.first != cerrados.last) {
      cerrados.add(cerrados.first);
    }
    return cerrados;
  }

  String _textoHijoDirecto(XmlElement elemento, String nombre) {
    for (final hijo in elemento.childElements) {
      if (_localName(hijo) == nombre) return hijo.innerText.trim();
    }
    return '';
  }

  String _nombreImportado(String nombreKml, String fallback) {
    final limpio = nombreKml.trim();
    return limpio.isEmpty ? fallback : limpio;
  }

  String _inferirTipoArea(String nombre) {
    final normalizado = nombre.toLowerCase();
    if (normalizado.contains('descarga')) return 'Descarga';
    if (normalizado.contains('chute')) return 'Chute';
    if (normalizado.contains('corte')) return 'Corte';
    if (normalizado.contains('desmonte')) return 'Desmonte';
    if (normalizado.contains('estacion')) return 'Estacionamiento';
    if (normalizado.contains('carga')) return 'Carga';
    return 'Area operativa';
  }

  String _localName(XmlElement elemento) {
    return elemento.name.local;
  }
}

List<ll.LatLng> _coordinatesToLatLng(List<dynamic> coordinates) {
  final puntos = <ll.LatLng>[];
  for (final item in coordinates) {
    if (item is! List || item.length < 2) continue;
    final lon = _toDouble(item[0]);
    final lat = _toDouble(item[1]);
    if (lat == null || lon == null) continue;
    puntos.add(ll.LatLng(lat, lon));
  }
  return puntos;
}

double? _toDouble(dynamic valor) {
  if (valor is num) return valor.toDouble();
  return double.tryParse(valor?.toString().trim() ?? '');
}
