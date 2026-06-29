import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/idiomas/idiomas_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/idiomas/idiomas_modelo.dart';
import 'package:trackmape_sup/datos/tablas/idiomas/idiomas_serializador.dart';

class IdiomasFuente implements FuenteContrato<IdiomasModelo> {
  final _deserializador = IdiomasDeserializador();
  final _serializador = IdiomasSerializador();
  static const _tabla = 'idiomas';

  @override
  Future<List<IdiomasModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<IdiomasModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(_tabla, 'codigo', id);
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(IdiomasModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(IdiomasModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'codigo',
      modelo.codigo,
    );
  }
}
