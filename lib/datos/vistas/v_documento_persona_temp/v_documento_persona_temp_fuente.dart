import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_vista_contrato.dart';
import 'package:trackmape_sup/datos/vistas/v_documento_persona_temp/v_documento_persona_temp_deserializador.dart';
import 'package:trackmape_sup/datos/vistas/v_documento_persona_temp/v_documento_persona_temp_modelo.dart';

class VDocumentoPersonaTempFuente
    implements FuenteVistaContrato<VDocumentoPersonaTempModelo> {
  final _deserializador = VDocumentoPersonaTempDeserializador();
  static const _vista = 'v_documento_persona_temp';

  @override
  Future<List<VDocumentoPersonaTempModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_vista);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<VDocumentoPersonaTempModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(
      _vista,
      'id_persona_doc',
      id,
    );
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  Future<List<VDocumentoPersonaTempModelo>> listarPorPersona(
    String idPersona,
  ) async {
    final respuesta = await mensajero.listarPor(
      _vista,
      'fk_persona',
      idPersona,
    );
    return respuesta.map(_deserializador.desdeJson).toList();
  }
}
