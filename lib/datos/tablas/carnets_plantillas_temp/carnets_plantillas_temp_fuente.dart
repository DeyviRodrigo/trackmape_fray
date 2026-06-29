import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/carnets_plantillas_temp/carnets_plantillas_temp_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/carnets_plantillas_temp/carnets_plantillas_temp_modelo.dart';
import 'package:trackmape_sup/datos/tablas/carnets_plantillas_temp/carnets_plantillas_temp_serializador.dart';

class CarnetsPlantillasTempFuente
    implements FuenteContrato<CarnetsPlantillasTempModelo> {
  final _deserializador = CarnetsPlantillasTempDeserializador();
  final _serializador = CarnetsPlantillasTempSerializador();
  static const _tabla = 'carnets_plantillas_temp';

  @override
  Future<List<CarnetsPlantillasTempModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<CarnetsPlantillasTempModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(
      _tabla,
      'id_plantilla',
      id,
    );
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  Future<List<CarnetsPlantillasTempModelo>> obtenerPorEmpresa(
    String idEmpresa,
  ) async {
    final respuesta = await mensajero.listarPor(
      _tabla,
      'fk_empresa',
      idEmpresa,
    );
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<void> insertar(CarnetsPlantillasTempModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  Future<CarnetsPlantillasTempModelo> insertarYRetornar(
    CarnetsPlantillasTempModelo modelo,
  ) async {
    final respuesta = await mensajero.insertarYRetornar(
      _tabla,
      _serializador.aJson(modelo),
    );
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> actualizar(CarnetsPlantillasTempModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_plantilla',
      modelo.id_plantilla,
    );
  }

  Future<void> desactivar(String id) async {
    await mensajero.desactivar(
      _tabla,
      {'fecha_eliminacion': DateTime.now().toIso8601String()},
      'id_plantilla',
      id,
    );
  }
}
