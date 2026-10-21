import 'package:trackmape_sup/datos/tablas/documentos_identidad_formatos/documentos_identidad_formatos_fuente.dart';
import 'package:trackmape_sup/datos/tablas/documentos_identidad_formatos/documentos_identidad_formatos_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class DocumentosIdentidadFormatosRepositorio {
  final _fuente = DocumentosIdentidadFormatosFuente();

  Future<List<DocumentosIdentidadFormatosModelo>> obtenerTodos() => ejecutar(
    'Error al obtener formatos de documento de identidad',
    () => _fuente.obtenerTodos(),
  );

  Future<DocumentosIdentidadFormatosModelo?> obtenerPorId(String id) =>
      ejecutar(
        'Error al obtener formato de documento de identidad',
        () => _fuente.obtenerPorId(id),
      );

  Future<DocumentosIdentidadFormatosModelo> insertar(
    DocumentosIdentidadFormatosModelo modelo,
  ) =>
      ejecutar('Error al insertar formato de documento de identidad', () async {
        await _fuente.insertar(modelo);
        return modelo;
      });

  Future<DocumentosIdentidadFormatosModelo> actualizar(
    DocumentosIdentidadFormatosModelo modelo,
  ) => ejecutar(
    'Error al actualizar formato de documento de identidad',
    () async {
      await _fuente.actualizar(modelo);
      return modelo;
    },
  );
}
