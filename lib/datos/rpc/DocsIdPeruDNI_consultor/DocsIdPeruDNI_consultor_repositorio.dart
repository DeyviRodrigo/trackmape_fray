// ignore_for_file: file_names

import 'package:trackmape_sup/datos/rpc/DocsIdPeruDNI_consultor/DocsIdPeruDNI_consultor_deserializador.dart';
import 'package:trackmape_sup/datos/rpc/DocsIdPeruDNI_consultor/DocsIdPeruDNI_consultor_fuente.dart';
import 'package:trackmape_sup/datos/rpc/DocsIdPeruDNI_consultor/DocsIdPeruDNI_consultor_resultado.dart';
import 'package:trackmape_sup/datos/rpc/DocsIdPeruDNI_consultor/DocsIdPeruDNI_consultor_validacion.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class DocsIdPeruDNIConsultorRepositorio {
  final _fuente = DocsIdPeruDNIConsultorFuente();
  final _validacion = DocsIdPeruDNIConsultorValidacion();
  final _deserializador = DocsIdPeruDNIConsultorDeserializador();

  Future<DocsIdPeruDNIConsultorResultado> consultar(String dni) =>
      ejecutar('Error al consultar DocsIdPeruDNI_consultor', () async {
        final crudo = await _fuente.consultar(dni);
        _validacion.validar(crudo);
        return _deserializador.desdeJson(crudo);
      });
}
