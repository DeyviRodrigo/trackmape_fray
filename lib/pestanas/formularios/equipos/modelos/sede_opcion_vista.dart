/// Responsabilidad: Representar una sede como opcion del formulario, con la
/// empresa a la que pertenece para acotarla.
library;

class SedeOpcionVista {
  const SedeOpcionVista({
    required this.id,
    required this.fkEmpresa,
    required this.nombre,
  });

  final String id;
  final String fkEmpresa;
  final String nombre;

  // Igualdad por id: el selector compara la opcion elegida con la lista.
  @override
  bool operator ==(Object other) => other is SedeOpcionVista && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
