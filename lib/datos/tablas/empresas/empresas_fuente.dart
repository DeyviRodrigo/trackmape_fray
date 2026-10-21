import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/empresas/empresas_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/empresas/empresas_modelo.dart';
import 'package:trackmape_sup/datos/tablas/empresas/empresas_serializador.dart';

class EmpresasFuente implements FuenteContrato<EmpresasModelo> {
  final _deserializador = EmpresasDeserializador();
  final _serializador = EmpresasSerializador();
  static const _tabla = 'empresas';

  @override
  Future<List<EmpresasModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<EmpresasModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(_tabla, 'id_empresa', id);
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(EmpresasModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(EmpresasModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_empresa',
      modelo.id_empresa,
    );
  }

  Future<void> desactivar(String id) async {
    await mensajero.desactivar(_tabla, {'activo': false}, 'id_empresa', id);
  }
}
