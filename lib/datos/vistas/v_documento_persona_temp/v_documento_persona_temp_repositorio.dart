import 'package:trackmape_sup/datos/vistas/v_documento_persona_temp/v_documento_persona_temp_fuente.dart';
import 'package:trackmape_sup/datos/vistas/v_documento_persona_temp/v_documento_persona_temp_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class VDocumentoPersonaTempRepositorio {
  final _fuente = VDocumentoPersonaTempFuente();

  Future<List<VDocumentoPersonaTempModelo>> listarPorPersona(
    String idPersona,
  ) => ejecutar(
    'Error al listar documentos',
    () => _fuente.listarPorPersona(idPersona),
  );
}
