import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/documentos_identidad/documentos_identidad_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/documentos_identidad/documentos_identidad_modelo.dart';
import 'package:trackmape_sup/datos/tablas/documentos_identidad/documentos_identidad_serializador.dart';

class DocumentosIdentidadFuente
    implements FuenteContrato<DocumentosIdentidadModelo> {
  final _deserializador = DocumentosIdentidadDeserializador();
  final _serializador = DocumentosIdentidadSerializador();
  static const _tabla = 'documentos_identidad';

  @override
  Future<List<DocumentosIdentidadModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<DocumentosIdentidadModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(_tabla, 'id_doc', id);
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(DocumentosIdentidadModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(DocumentosIdentidadModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_doc',
      modelo.id_doc,
    );
  }
}
