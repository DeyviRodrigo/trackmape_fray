import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/persona_documentos/persona_documentos_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/persona_documentos/persona_documentos_modelo.dart';
import 'package:trackmape_sup/datos/tablas/persona_documentos/persona_documentos_serializador.dart';

class PersonaDocumentosFuente
    implements FuenteContrato<PersonaDocumentosModelo> {
  final _deserializador = PersonaDocumentosDeserializador();
  final _serializador = PersonaDocumentosSerializador();
  static const _tabla = 'persona_documentos';

  @override
  Future<List<PersonaDocumentosModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<PersonaDocumentosModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(
      _tabla,
      'id_persona_doc',
      id,
    );
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(PersonaDocumentosModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(PersonaDocumentosModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_persona_doc',
      modelo.id_persona_doc,
    );
  }
}
