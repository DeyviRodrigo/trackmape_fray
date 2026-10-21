/// Responsabilidad: Representar una empresa como opcion del formulario.
library;

class EmpresaOpcionVista {
  const EmpresaOpcionVista({required this.id, required this.nombre});

  final String id;
  final String nombre;

  // Igualdad por id: el selector compara la opcion elegida con la lista.
  @override
  bool operator ==(Object other) =>
      other is EmpresaOpcionVista && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
