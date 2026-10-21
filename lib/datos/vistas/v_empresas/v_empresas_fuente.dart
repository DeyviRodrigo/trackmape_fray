import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_vista_contrato.dart';
import 'package:trackmape_sup/datos/vistas/v_empresas/v_empresas_deserializador.dart';
import 'package:trackmape_sup/datos/vistas/v_empresas/v_empresas_modelo.dart';

class VEmpresasFuente implements FuenteVistaContrato<VEmpresasModelo> {
  final _deserializador = VEmpresasDeserializador();
  static const _vista = 'v_empresas';

  @override
  Future<List<VEmpresasModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_vista);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<VEmpresasModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(_vista, 'id_empresa', id);
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }
}
