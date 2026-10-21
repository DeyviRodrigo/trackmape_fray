import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/niveles_ubigeo/niveles_ubigeo_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/niveles_ubigeo/niveles_ubigeo_modelo.dart';
import 'package:trackmape_sup/datos/tablas/niveles_ubigeo/niveles_ubigeo_serializador.dart';

class NivelesUbigeoFuente implements FuenteContrato<NivelesUbigeoModelo> {
  final _deserializador = NivelesUbigeoDeserializador();
  final _serializador = NivelesUbigeoSerializador();
  static const _tabla = 'niveles_ubigeo';

  @override
  Future<List<NivelesUbigeoModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<NivelesUbigeoModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(
      _tabla,
      'id_nivel_ubigeo',
      id,
    );
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(NivelesUbigeoModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(NivelesUbigeoModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_nivel_ubigeo',
      modelo.id_nivel_ubigeo,
    );
  }
}
