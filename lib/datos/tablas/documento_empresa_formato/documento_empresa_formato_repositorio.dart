import 'package:trackmape_sup/datos/tablas/documento_empresa_formato/documento_empresa_formato_fuente.dart';
import 'package:trackmape_sup/datos/tablas/documento_empresa_formato/documento_empresa_formato_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class DocumentoEmpresaFormatoRepositorio {
  final _fuente = DocumentoEmpresaFormatoFuente();

  Future<List<DocumentoEmpresaFormatoModelo>> obtenerTodos() => ejecutar(
    'Error al obtener documentos_empresa_formato',
    () => _fuente.obtenerTodos(),
  );

  Future<DocumentoEmpresaFormatoModelo?> obtenerPorId(String id) => ejecutar(
    'Error al obtener documento_empresa_formato',
    () => _fuente.obtenerPorId(id),
  );

  Future<DocumentoEmpresaFormatoModelo> insertar(
    DocumentoEmpresaFormatoModelo modelo,
  ) => ejecutar('Error al insertar documento_empresa_formato', () async {
    await _fuente.insertar(modelo);
    return modelo;
  });

  Future<DocumentoEmpresaFormatoModelo> actualizar(
    DocumentoEmpresaFormatoModelo modelo,
  ) => ejecutar('Error al actualizar documento_empresa_formato', () async {
    await _fuente.actualizar(modelo);
    return modelo;
  });
}
