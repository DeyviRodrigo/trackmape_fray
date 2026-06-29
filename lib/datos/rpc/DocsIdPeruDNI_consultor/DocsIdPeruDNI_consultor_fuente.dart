// ignore_for_file: file_names

import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';

class DocsIdPeruDNIConsultorFuente {
  static const _funcion = 'DocsIdPeruDNI_consultor';

  Future<Map<String, dynamic>> consultar(String dni) async {
    return mensajero.rpc(_funcion, {'p_dni': dni});
  }
}
