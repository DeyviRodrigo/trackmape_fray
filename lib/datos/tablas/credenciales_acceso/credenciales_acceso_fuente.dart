import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/credenciales_acceso/credenciales_acceso_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/credenciales_acceso/credenciales_acceso_modelo.dart';
import 'package:trackmape_sup/datos/tablas/credenciales_acceso/credenciales_acceso_serializador.dart';

class CredencialesAccesoFuente
    implements FuenteContrato<CredencialesAccesoModelo> {
  final _deserializador = CredencialesAccesoDeserializador();
  final _serializador = CredencialesAccesoSerializador();
  static const _tabla = 'credenciales_acceso';

  @override
  Future<List<CredencialesAccesoModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<CredencialesAccesoModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(
      _tabla,
      'id_credencial',
      id,
    );
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(CredencialesAccesoModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(CredencialesAccesoModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_credencial',
      modelo.id_credencial,
    );
  }
}
