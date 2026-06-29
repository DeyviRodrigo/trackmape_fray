// ignore_for_file: file_names

import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';

class DocsEmpresaPeruRUCConsultorFuente {
  static const _funcion = 'DocsEmpresaPeruRUC_consultor';

  Future<Map<String, dynamic>> consultar(String ruc) async {
    return mensajero.rpc(_funcion, {'p_ruc': ruc});
  }
}
