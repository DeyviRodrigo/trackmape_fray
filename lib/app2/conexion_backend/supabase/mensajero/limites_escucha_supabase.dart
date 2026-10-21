/// Responsabilidad: Rechazar las casillas de FormularioLectura que el tiempo
/// real de Supabase (Realtime) no soporta.
///
/// Realtime acepta a lo sumo un filtro simple (un igual a o un en lista), un
/// solo orden y un maximo. Sin esta comprobacion, las demas casillas se
/// ignorarian en silencio y la escucha traeria registros de mas.
library;

import 'package:trackmape_sup/app2/conexion_backend/contratos/formulario_lectura.dart';

// LIMITES ESCUCHA SUPABASE - Lo que Realtime no puede cumplir
class LimitesEscuchaSupabase {
  LimitesEscuchaSupabase._();

  // VALIDAR - Falla nombrando cada casilla no soportada
  static void validar(FormularioLectura consulta) {
    final filtros = consulta.igualA.length + consulta.enLista.length;
    final noSoportadas = [
      if (filtros > 1) 'mas de un igual a / en lista',
      if (consulta.entre.isNotEmpty) 'entre',
      if (consulta.igualONulo.isNotEmpty) 'igual o nulo',
      if (consulta.ordenarPor.length > 1) 'mas de un orden',
      if (consulta.tramo is PaginaConsulta) 'pagina',
    ];

    if (noSoportadas.isNotEmpty) {
      throw ArgumentError(
        'escuchar no admite: ${noSoportadas.join(', ')}. '
        'Realtime acepta a lo sumo un igual a o un en lista, un solo orden '
        'y un maximo.',
      );
    }
  }
}
