import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/monedas/monedas_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/monedas/monedas_modelo.dart';
import 'package:trackmape_sup/datos/tablas/monedas/monedas_serializador.dart';

class MonedasFuente implements FuenteContrato<MonedasModelo> {
  final _deserializador = MonedasDeserializador();
  final _serializador = MonedasSerializador();
  static const _tabla = 'monedas';

  @override
  Future<List<MonedasModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<MonedasModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(_tabla, 'id_moneda', id);
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(MonedasModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(MonedasModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_moneda',
      modelo.id_moneda,
    );
  }
}
