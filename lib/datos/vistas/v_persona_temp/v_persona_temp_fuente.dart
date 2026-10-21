import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_vista_contrato.dart';
import 'package:trackmape_sup/datos/vistas/v_persona_temp/v_persona_temp_deserializador.dart';
import 'package:trackmape_sup/datos/vistas/v_persona_temp/v_persona_temp_modelo.dart';

class VPersonaTempFuente implements FuenteVistaContrato<VPersonaTempModelo> {
  final _deserializador = VPersonaTempDeserializador();
  static const _vista = 'v_persona_temp';

  @override
  Future<List<VPersonaTempModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_vista);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<VPersonaTempModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(
      _vista,
      'id_trabajador',
      id,
    );
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  Future<List<VPersonaTempModelo>> listarPorPersona(String idPersona) async {
    final respuesta = await mensajero.listarPor(
      _vista,
      'id_persona',
      idPersona,
    );
    return respuesta.map(_deserializador.desdeJson).toList();
  }
}
