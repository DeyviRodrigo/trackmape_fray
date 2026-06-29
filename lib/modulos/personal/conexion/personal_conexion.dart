import 'package:trackmape_sup/datos/rpc/DocsIdPeruDNI_consultor/DocsIdPeruDNI_consultor_repositorio.dart';
import 'package:trackmape_sup/datos/tablas/contrato/contrato_repositorio.dart';
import 'package:trackmape_sup/datos/tablas/personas/personas_repositorio.dart';
import 'package:trackmape_sup/datos/tablas/sedes/sedes_repositorio.dart';
import 'package:trackmape_sup/datos/tablas/documentos_identidad/documentos_identidad_repositorio.dart';
import 'package:trackmape_sup/datos/tablas/documentos_identidad_formatos/documentos_identidad_formatos_repositorio.dart';
import 'package:trackmape_sup/datos/tablas/trabajadores/trabajadores_repositorio.dart';
import 'package:trackmape_sup/datos/vistas/v_persona_temp/v_persona_temp_repositorio.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajadores_temp/v_trabajadores_temp_repositorio.dart';
import 'package:trackmape_sup/datos/vistas/v_documento_persona_temp/v_documento_persona_temp_repositorio.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajador_contrato_temp/v_trabajador_contrato_temp_repositorio.dart';
import 'package:trackmape_sup/datos/vistas/v_trabajador_credenciales_temp/v_trabajador_credenciales_temp_repositorio.dart';

class PersonalConexion {
  // Tablas
  final PersonasRepositorio personas = PersonasRepositorio();
  final TrabajadoresRepositorio trabajadores = TrabajadoresRepositorio();
  final ContratoRepositorio contrato = ContratoRepositorio();
  final DocumentosIdentidadRepositorio documentosIdentidad =
      DocumentosIdentidadRepositorio();
  final DocumentosIdentidadFormatosRepositorio documentosIdentidadFormatos =
      DocumentosIdentidadFormatosRepositorio();
  final SedesRepositorio sedes = SedesRepositorio();
  final DocsIdPeruDNIConsultorRepositorio docsIdPeruDNI =
      DocsIdPeruDNIConsultorRepositorio();

  // Vistas nuevas
  final VPersonaTempRepositorio vPersonaTemp = VPersonaTempRepositorio();
  final VTrabajadoresTempRepositorio vTrabajadoresTemp =
      VTrabajadoresTempRepositorio();
  final VDocumentoPersonaTempRepositorio vDocumentoPersonaTemp =
      VDocumentoPersonaTempRepositorio();
  final VTrabajadorContratoTempRepositorio vContratoTemp =
      VTrabajadorContratoTempRepositorio();
  final VTrabajadorCredencialesTempRepositorio vCredencialesTemp =
      VTrabajadorCredencialesTempRepositorio();
}
