// ignore_for_file: file_names, non_constant_identifier_names
import 'package:trackmape_sup/datos/vistas/v_empresas/v_empresas_modelo.dart';

class DocsEmpresaPeruRUCConsultorResultado {
  final bool ok;
  final String ruc;
  final DateTime? ultima_verificacion_ok;
  final VEmpresasModelo empresa;

  const DocsEmpresaPeruRUCConsultorResultado({
    required this.ok,
    required this.ruc,
    this.ultima_verificacion_ok,
    required this.empresa,
  });
}
