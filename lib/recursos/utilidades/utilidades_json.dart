/// Utilidades de conversión y parsing para datos JSON/Supabase.
/// Centralizadas aquí para evitar duplicados entre capas de datos.
library;

/// Elimina entradas con valor null de un mapa.
Map<String, dynamic> sinNulos(Map<String, dynamic> data) {
  final clean = Map<String, dynamic>.from(data);
  clean.removeWhere((_, value) => value == null);
  return clean;
}

/// Convierte [value] a String, o retorna [fallback] si es null.
String aStringSafe(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

/// Convierte [value] a String no vacío, o retorna null si es null o vacío.
String? aStringNulable(dynamic value) {
  if (value == null) return null;
  final texto = value.toString().trim();
  return texto.isEmpty ? null : texto;
}

/// Convierte [value] a int, o retorna [fallback] si no se puede parsear.
int aIntSafe(dynamic value, {required int fallback}) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

/// Convierte [value] a int, o retorna null si no se puede parsear.
int? aIntNulable(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

/// Convierte [value] a double, o retorna null si no se puede parsear.
double? aDoubleNulable(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

/// Convierte [value] a num, o retorna null si no se puede parsear.
num? aNumNulable(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse(value.toString());
}

/// Convierte String o DateTime a DateTime?, o retorna null si no se puede parsear.
DateTime? aDateTimeNulable(dynamic value) {
  if (value is DateTime) return value;
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

/// Convierte la respuesta de Supabase a List<Map<String, dynamic>>.
List<Map<String, dynamic>> aListaMapas(dynamic filas) =>
    (filas as List<dynamic>)
        .map((fila) => Map<String, dynamic>.from(fila as Map))
        .toList();

/// Convierte la respuesta de Supabase a Map<String, dynamic>.
Map<String, dynamic> aMapa(dynamic fila) =>
    Map<String, dynamic>.from(fila as Map);

/// Convierte [value] a Map<String, dynamic>?, o retorna null si no es mapa.
Map<String, dynamic>? aMapaNulable(dynamic value) {
  if (value is! Map) return null;
  return Map<String, dynamic>.from(value);
}

/// Convierte [value] a List<Map<String, dynamic>>?, o retorna null si no es lista.
List<Map<String, dynamic>>? aListaMapasNulable(dynamic value) {
  if (value is! List) return null;
  return value
      .whereType<Map>()
      .map((fila) => Map<String, dynamic>.from(fila))
      .toList();
}

/// Convierte [value] a lista de mapas, aceptando un mapa unitario o una lista.
List<Map<String, dynamic>>? aListaMapasDesdeMapaOListaNulable(dynamic value) {
  if (value is Map) {
    return <Map<String, dynamic>>[Map<String, dynamic>.from(value)];
  }
  return aListaMapasNulable(value);
}

/// Parsea representaciones comunes de booleano. Usa [fallback] si no reconoce el valor.
bool aJsonBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value == null) return fallback;
  final texto = value.toString().toLowerCase();
  if (texto == 'true' ||
      texto == 't' ||
      texto == '1' ||
      texto == 'yes' ||
      texto == 'y') {
    return true;
  }
  if (texto == 'false' ||
      texto == 'f' ||
      texto == '0' ||
      texto == 'no' ||
      texto == 'n') {
    return false;
  }
  return fallback;
}

/// Parsea representaciones comunes de booleano y retorna null si no reconoce el valor.
bool? aJsonBoolNulable(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final texto = aStringNulable(value)?.toLowerCase();
  if (texto == null || texto.isEmpty) return null;
  if (texto == 'true' ||
      texto == 't' ||
      texto == '1' ||
      texto == 'yes' ||
      texto == 'y') {
    return true;
  }
  if (texto == 'false' ||
      texto == 'f' ||
      texto == '0' ||
      texto == 'no' ||
      texto == 'n') {
    return false;
  }
  return null;
}
