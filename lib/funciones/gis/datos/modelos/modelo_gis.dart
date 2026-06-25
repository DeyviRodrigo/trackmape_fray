import 'package:latlong2/latlong.dart' as ll;

class GeometriaOperativa {
  const GeometriaOperativa({
    required this.id,
    required this.tipoGeometria,
    required this.geojson,
    required this.activo,
    this.fechaCreacion,
  });

  final String id;
  final String tipoGeometria;
  final Map<String, dynamic> geojson;
  final bool activo;
  final DateTime? fechaCreacion;

  factory GeometriaOperativa.fromJson(Map<String, dynamic> json) {
    final geojson = _mapaGeojson(json['geojson']);
    return GeometriaOperativa(
      id: json['id_elemento']?.toString() ?? '',
      tipoGeometria:
          _extraerTipoGeometria(geojson) ??
          tipoGeometriaParaCategoria(json['categoria']?.toString() ?? ''),
      geojson: geojson,
      activo: json['activo'] != false,
      fechaCreacion: DateTime.tryParse(
        json['fecha_creacion']?.toString() ?? '',
      ),
    );
  }

  Map<String, dynamic> get geometriaGeojson => _extraerGeometria(geojson);

  List<ll.LatLng> get puntosPoligono => _polygonToLatLng(geometriaGeojson);

  List<ll.LatLng> get puntosLinea => _lineStringToLatLng(geometriaGeojson);

  ll.LatLng? get punto => _pointToLatLng(geometriaGeojson);
}

class ElementoOperativo {
  const ElementoOperativo({
    required this.id,
    required this.fkEmpresa,
    required this.fkSede,
    required this.categoria,
    required this.tipoOperativo,
    required this.nombre,
    required this.descripcion,
    required this.color,
    required this.prioridad,
    required this.activo,
    this.geometria,
    this.fechaCreacion,
  });

  final String id;
  final String fkEmpresa;
  final String? fkSede;
  final String categoria;
  final String tipoOperativo;
  final String nombre;
  final String descripcion;
  final String color;
  final int prioridad;
  final bool activo;
  final GeometriaOperativa? geometria;
  final DateTime? fechaCreacion;

  factory ElementoOperativo.fromJson(Map<String, dynamic> json) {
    final geometria = GeometriaOperativa.fromJson(json);
    return ElementoOperativo(
      id: json['id_elemento']?.toString() ?? '',
      fkEmpresa: json['fk_empresa']?.toString() ?? '',
      fkSede: _nullableTrim(json['fk_sede']),
      categoria: (json['categoria']?.toString() ?? '').toLowerCase().trim(),
      tipoOperativo: json['tipo_operativo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? 'Elemento',
      descripcion: json['descripcion']?.toString() ?? '',
      color: json['color']?.toString() ?? '#ff9800',
      prioridad: (json['prioridad'] as num?)?.toInt() ?? 0,
      activo: json['activo'] != false,
      geometria: geometria.geojson.isEmpty ? null : geometria,
      fechaCreacion: DateTime.tryParse(
        json['fecha_creacion']?.toString() ?? '',
      ),
    );
  }

  ElementoOperativo copyWith({GeometriaOperativa? geometria, bool? activo}) {
    return ElementoOperativo(
      id: id,
      fkEmpresa: fkEmpresa,
      fkSede: fkSede,
      categoria: categoria,
      tipoOperativo: tipoOperativo,
      nombre: nombre,
      descripcion: descripcion,
      color: color,
      prioridad: prioridad,
      activo: activo ?? this.activo,
      geometria: geometria ?? this.geometria,
      fechaCreacion: fechaCreacion,
    );
  }

  bool get esArea => categoria == 'area';

  bool get esRuta => categoria == 'ruta';

  bool get esPunto => categoria == 'punto';

  String get tipoGeometria => geometria?.tipoGeometria ?? '';

  List<ll.LatLng> get puntosPoligono => geometria?.puntosPoligono ?? const [];

  List<ll.LatLng> get puntosLinea => geometria?.puntosLinea ?? const [];

  ll.LatLng? get punto => geometria?.punto;

  ll.LatLng? get centro {
    final puntos = puntosPoligono;
    if (puntos.isEmpty) return punto;
    final lat = puntos.map((p) => p.latitude).reduce((a, b) => a + b);
    final lon = puntos.map((p) => p.longitude).reduce((a, b) => a + b);
    return ll.LatLng(lat / puntos.length, lon / puntos.length);
  }

  bool get tieneGeometriaValida {
    if (!activo || geometria?.activo == false) return false;
    if (esArea) return puntosPoligono.length >= 3;
    if (esRuta) return puntosLinea.length >= 2;
    if (esPunto) return punto != null;
    return false;
  }
}

class SedeOperativa {
  const SedeOperativa({required this.id, required this.nombre});

  final String id;
  final String nombre;

  factory SedeOperativa.fromJson(Map<String, dynamic> json) {
    final nombre =
        json['nombre']?.toString().trim() ??
        json['nombre_sede']?.toString().trim() ??
        json['descripcion']?.toString().trim() ??
        json['codigo']?.toString().trim() ??
        '';

    return SedeOperativa(
      id: json['id_sede']?.toString() ?? '',
      nombre: nombre.isEmpty ? 'Sede' : nombre,
    );
  }
}

Map<String, dynamic> construirGeojsonArea(List<ll.LatLng> puntos) {
  final cerrados = _cerrarPoligono(puntos);
  return {
    'type': 'Polygon',
    'coordinates': [
      cerrados.map((p) => [p.longitude, p.latitude]).toList(),
    ],
  };
}

Map<String, dynamic> construirGeojsonRuta(List<ll.LatLng> puntos) {
  return {
    'type': 'LineString',
    'coordinates': puntos.map((p) => [p.longitude, p.latitude]).toList(),
  };
}

Map<String, dynamic> construirGeojsonPunto(ll.LatLng punto) {
  return {
    'type': 'Point',
    'coordinates': [punto.longitude, punto.latitude],
  };
}

String tipoGeometriaParaCategoria(String categoria) {
  switch (categoria.toLowerCase().trim()) {
    case 'area':
      return 'Polygon';
    case 'ruta':
      return 'LineString';
    case 'punto':
      return 'Point';
    default:
      return '';
  }
}

Map<String, dynamic> _mapaGeojson(dynamic valor) {
  if (valor is Map<String, dynamic>) return valor;
  if (valor is Map) return Map<String, dynamic>.from(valor);
  return const {};
}

Map<String, dynamic> _extraerGeometria(Map<String, dynamic> geojson) {
  if (geojson['type'] == 'Feature') {
    return _mapaGeojson(geojson['geometry']);
  }
  return geojson;
}

String? _extraerTipoGeometria(Map<String, dynamic> geojson) {
  final geometria = _extraerGeometria(geojson);
  return geometria['type']?.toString();
}

List<ll.LatLng> _polygonToLatLng(Map<String, dynamic> geojson) {
  if (geojson['type'] != 'Polygon') return const [];
  final coordinates = geojson['coordinates'];
  if (coordinates is! List || coordinates.isEmpty) return const [];
  final exterior = coordinates.first;
  if (exterior is! List) return const [];
  final puntos = _coordinatesToLatLng(exterior);
  if (puntos.length > 1 && puntos.first == puntos.last) {
    return puntos.sublist(0, puntos.length - 1);
  }
  return puntos;
}

List<ll.LatLng> _lineStringToLatLng(Map<String, dynamic> geojson) {
  if (geojson['type'] != 'LineString') return const [];
  final coordinates = geojson['coordinates'];
  if (coordinates is! List) return const [];
  return _coordinatesToLatLng(coordinates);
}

ll.LatLng? _pointToLatLng(Map<String, dynamic> geojson) {
  if (geojson['type'] != 'Point') return null;
  final coordinates = geojson['coordinates'];
  if (coordinates is! List || coordinates.length < 2) return null;
  final lon = _toDouble(coordinates[0]);
  final lat = _toDouble(coordinates[1]);
  if (lat == null || lon == null) return null;
  if (lat < -90 || lat > 90 || lon < -180 || lon > 180) return null;
  return ll.LatLng(lat, lon);
}

List<ll.LatLng> _coordinatesToLatLng(List<dynamic> coordinates) {
  final puntos = <ll.LatLng>[];
  for (final item in coordinates) {
    if (item is! List || item.length < 2) continue;
    final lon = _toDouble(item[0]);
    final lat = _toDouble(item[1]);
    if (lat == null || lon == null) continue;
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) continue;
    puntos.add(ll.LatLng(lat, lon));
  }
  return puntos;
}

List<ll.LatLng> _cerrarPoligono(List<ll.LatLng> puntos) {
  if (puntos.isEmpty) return const [];
  final cerrados = List<ll.LatLng>.from(puntos);
  if (cerrados.first != cerrados.last) {
    cerrados.add(cerrados.first);
  }
  return cerrados;
}

double? _toDouble(dynamic valor) {
  if (valor is num) return valor.toDouble();
  return double.tryParse(valor?.toString() ?? '');
}

String? _nullableTrim(dynamic valor) {
  final texto = valor?.toString().trim();
  if (texto == null || texto.isEmpty) return null;
  return texto;
}
