library;

/// Formatea un DateTime como 'YYYY-MM-DD'.
String formatearFecha(DateTime d) {
  return '${d.year.toString().padLeft(4, '0')}-${_dos(d.month)}-${_dos(d.day)}';
}

/// Formatea un DateTime como 'HH:MM'.
String formatearHora(DateTime d) {
  return '${_dos(d.hour)}:${_dos(d.minute)}';
}

String _dos(int n) => n.toString().padLeft(2, '0');
