/// Responsabilidad: Declarar las rutas de la aplicacion como constantes, para
/// no escribirlas a mano en cada lugar que navega.
library;

abstract final class Rutas {
  // FORMULARIOS
  static const equipos = '/equipos';
  static const elementosOperativos = '/elementos-operativos';

  // HERRAMIENTAS
  static const monitoreoEnVivo = '/monitoreo-en-vivo';

  // INFORMES
  static const recorridos = '/recorridos';
  static const rankingOperativo = '/ranking-operativo';
  static const analisisEquipo = '/analisis-equipo';

  // VERSION ANTERIOR - La app de antes completa
  static const versionAnterior = '/version-anterior';
}
