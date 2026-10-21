// ignore_for_file: file_names

import 'package:trackmape_sup/datos/rpc/DocsEmpresaPeruRUC_consultor/DocsEmpresaPeruRUC_consultor_deserializador.dart';
import 'package:trackmape_sup/datos/rpc/DocsEmpresaPeruRUC_consultor/DocsEmpresaPeruRUC_consultor_fuente.dart';
import 'package:trackmape_sup/datos/rpc/DocsEmpresaPeruRUC_consultor/DocsEmpresaPeruRUC_consultor_resultado.dart';
import 'package:trackmape_sup/datos/rpc/DocsEmpresaPeruRUC_consultor/DocsEmpresaPeruRUC_consultor_validacion.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class DocsEmpresaPeruRUCConsultorRepositorio {
  final _fuente = DocsEmpresaPeruRUCConsultorFuente();
  final _validacion = DocsEmpresaPeruRUCConsultorValidacion();
  final _deserializador = DocsEmpresaPeruRUCConsultorDeserializador();

  Future<DocsEmpresaPeruRUCConsultorResultado> consultar(String ruc) =>
      ejecutar('Error al consultar DocsEmpresaPeruRUC_consultor', () async {
        final crudo = await _fuente.consultar(ruc);
        _validacion.validar(crudo);
        return _deserializador.desdeJson(crudo);
      });
}
