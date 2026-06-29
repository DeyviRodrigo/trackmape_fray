import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/contrato/contrato_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/contrato/contrato_modelo.dart';
import 'package:trackmape_sup/datos/tablas/contrato/contrato_serializador.dart';

class ContratoFuente implements FuenteContrato<ContratoModelo> {
  final _deserializador = ContratoDeserializador();
  final _serializador = ContratoSerializador();
  static const _tabla = 'contrato';

  @override
  Future<List<ContratoModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<ContratoModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(_tabla, 'id_contrato', id);
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(ContratoModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(ContratoModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_contrato',
      modelo.id_contrato,
    );
  }
}
