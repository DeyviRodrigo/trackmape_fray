import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/documentos_identidad_formatos/documentos_identidad_formatos_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/documentos_identidad_formatos/documentos_identidad_formatos_modelo.dart';
import 'package:trackmape_sup/datos/tablas/documentos_identidad_formatos/documentos_identidad_formatos_serializador.dart';

class DocumentosIdentidadFormatosFuente
    implements FuenteContrato<DocumentosIdentidadFormatosModelo> {
  final _deserializador = DocumentosIdentidadFormatosDeserializador();
  final _serializador = DocumentosIdentidadFormatosSerializador();
  static const _tabla = 'documentos_identidad_formatos';

  @override
  Future<List<DocumentosIdentidadFormatosModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<DocumentosIdentidadFormatosModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(
      _tabla,
      'id_formato_doc',
      id,
    );
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(DocumentosIdentidadFormatosModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(DocumentosIdentidadFormatosModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_formato_doc',
      modelo.id_formato_doc,
    );
  }
}
