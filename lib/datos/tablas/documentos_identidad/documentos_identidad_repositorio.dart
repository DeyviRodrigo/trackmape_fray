import 'package:trackmape_sup/datos/tablas/documentos_identidad/documentos_identidad_fuente.dart';
import 'package:trackmape_sup/datos/tablas/documentos_identidad/documentos_identidad_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class DocumentosIdentidadRepositorio {
  final _fuente = DocumentosIdentidadFuente();

  Future<List<DocumentosIdentidadModelo>> obtenerTodos() => ejecutar(
    'Error al obtener documentos de identidad',
    () => _fuente.obtenerTodos(),
  );

  Future<DocumentosIdentidadModelo?> obtenerPorId(String id) => ejecutar(
    'Error al obtener documento de identidad',
    () => _fuente.obtenerPorId(id),
  );

  Future<DocumentosIdentidadModelo> insertar(
    DocumentosIdentidadModelo modelo,
  ) => ejecutar('Error al insertar documento de identidad', () async {
    await _fuente.insertar(modelo);
    return modelo;
  });

  Future<DocumentosIdentidadModelo> actualizar(
    DocumentosIdentidadModelo modelo,
  ) => ejecutar('Error al actualizar documento de identidad', () async {
    await _fuente.actualizar(modelo);
    return modelo;
  });
}
