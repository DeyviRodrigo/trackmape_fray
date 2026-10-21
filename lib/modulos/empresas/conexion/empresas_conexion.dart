import 'package:trackmape_sup/datos/tablas/documento_empresa_formato/documento_empresa_formato_repositorio.dart';
import 'package:trackmape_sup/datos/tablas/empresas/empresas_repositorio.dart';
import 'package:trackmape_sup/datos/vistas/v_empresas/v_empresas_repositorio.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajadores_temporal/v_trabajadores_temporal_repositorio.dart';
import 'package:trackmape_sup/datos/rpc/DocsEmpresaPeruRUC_consultor/DocsEmpresaPeruRUC_consultor_repositorio.dart';

class EmpresasConexion {
  final DocumentoEmpresaFormatoRepositorio documentoEmpresaFormato =
      DocumentoEmpresaFormatoRepositorio();
  final EmpresasRepositorio empresas = EmpresasRepositorio();
  final VEmpresasRepositorio vEmpresas = VEmpresasRepositorio();
  final VTrabajadoresTemporalRepositorio vTrabajadoresTemporal =
      VTrabajadoresTemporalRepositorio();
  final DocsEmpresaPeruRUCConsultorRepositorio docsEmpresaPeruRUC =
      DocsEmpresaPeruRUCConsultorRepositorio();
}
