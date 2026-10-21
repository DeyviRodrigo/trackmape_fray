import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/documento_empresa_formato/documento_empresa_formato_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/documento_empresa_formato/documento_empresa_formato_modelo.dart';
import 'package:trackmape_sup/datos/tablas/documento_empresa_formato/documento_empresa_formato_serializador.dart';

class DocumentoEmpresaFormatoFuente
    implements FuenteContrato<DocumentoEmpresaFormatoModelo> {
  final _deserializador = DocumentoEmpresaFormatoDeserializador();
  final _serializador = DocumentoEmpresaFormatoSerializador();
  static const _tabla = 'documento_empresa_formato';

  @override
  Future<List<DocumentoEmpresaFormatoModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<DocumentoEmpresaFormatoModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(
      _tabla,
      'id_doc_empresa',
      id,
    );
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(DocumentoEmpresaFormatoModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(DocumentoEmpresaFormatoModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_doc_empresa',
      modelo.id_doc_empresa,
    );
  }
}
