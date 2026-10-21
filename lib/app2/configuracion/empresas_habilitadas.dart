/// Responsabilidad: Declarar las empresas que TrackMAPE muestra. La base es
/// compartida con trazmape y tiene otras empresas que aqui no van.
///
/// Fijo por rapidez, igual que en el codigo anterior
/// (RepositorioMonitoreo.empresasDashboardIds). Cuando exista inicio de sesion
/// saldra de los permisos del usuario.
library;

abstract final class EmpresasHabilitadas {
  static const List<String> ids = [
    'c6a59aec-29ea-4e42-8ece-581df5e4459d', // Francisco 1
    '63a9ae71-8881-4333-8927-41c48b35d104', // Francisco 2 (AMS-6)
  ];
}
