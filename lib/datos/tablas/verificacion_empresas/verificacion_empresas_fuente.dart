import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/verificacion_empresas/verificacion_empresas_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/verificacion_empresas/verificacion_empresas_modelo.dart';
import 'package:trackmape_sup/datos/tablas/verificacion_empresas/verificacion_empresas_serializador.dart';

class VerificacionEmpresasFuente
    implements FuenteContrato<VerificacionEmpresasModelo> {
  final _deserializador = VerificacionEmpresasDeserializador();
  final _serializador = VerificacionEmpresasSerializador();
  static const _tabla = 'verificacion_empresas';

  @override
  Future<List<VerificacionEmpresasModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<VerificacionEmpresasModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(
      _tabla,
      'id_verificacion_empresa',
      id,
    );
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(VerificacionEmpresasModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(VerificacionEmpresasModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_verificacion_empresa',
      modelo.id_verificacion_empresa,
    );
  }
}
