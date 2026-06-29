import 'package:trackmape_sup/datos/tablas/persona_documentos/persona_documentos_fuente.dart';
import 'package:trackmape_sup/datos/tablas/persona_documentos/persona_documentos_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class PersonaDocumentosRepositorio {
  final _fuente = PersonaDocumentosFuente();

  Future<List<PersonaDocumentosModelo>> obtenerTodos() => ejecutar(
    'Error al obtener documentos de persona',
    () => _fuente.obtenerTodos(),
  );

  Future<PersonaDocumentosModelo?> obtenerPorId(String id) => ejecutar(
    'Error al obtener documento de persona',
    () => _fuente.obtenerPorId(id),
  );

  Future<PersonaDocumentosModelo> insertar(PersonaDocumentosModelo modelo) =>
      ejecutar('Error al insertar documento de persona', () async {
        await _fuente.insertar(modelo);
        return modelo;
      });

  Future<PersonaDocumentosModelo> actualizar(PersonaDocumentosModelo modelo) =>
      ejecutar('Error al actualizar documento de persona', () async {
        await _fuente.actualizar(modelo);
        return modelo;
      });
}
