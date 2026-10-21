import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/ubigeo/ubigeo_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/ubigeo/ubigeo_modelo.dart';
import 'package:trackmape_sup/datos/tablas/ubigeo/ubigeo_serializador.dart';

class UbigeoFuente implements FuenteContrato<UbigeoModelo> {
  final _deserializador = UbigeoDeserializador();
  final _serializador = UbigeoSerializador();
  static const _tabla = 'ubigeo';

  @override
  Future<List<UbigeoModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<UbigeoModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(_tabla, 'id_ubigeo', id);
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(UbigeoModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(UbigeoModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_ubigeo',
      modelo.id_ubigeo,
    );
  }
}
