import 'package:trackmape_sup/datos/vistas/v_persona_temp/v_persona_temp_fuente.dart';
import 'package:trackmape_sup/datos/vistas/v_persona_temp/v_persona_temp_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class VPersonaTempRepositorio {
  final _fuente = VPersonaTempFuente();

  Future<List<VPersonaTempModelo>> obtenerTodos() =>
      ejecutar('Error al obtener v_persona_temp', () => _fuente.obtenerTodos());

  Future<VPersonaTempModelo?> obtenerPorIdTrabajador(String idTrabajador) =>
      ejecutar(
        'Error al obtener persona',
        () => _fuente.obtenerPorId(idTrabajador),
      );

  Future<List<VPersonaTempModelo>> listarPorPersona(String idPersona) =>
      ejecutar(
        'Error al listar por persona',
        () => _fuente.listarPorPersona(idPersona),
      );
}
