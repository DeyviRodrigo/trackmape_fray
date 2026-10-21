import 'package:trackmape_sup/app/conexion_backend/mensajero_activo.dart';
import 'package:trackmape_sup/datos/interfaces/fuente_contrato.dart';
import 'package:trackmape_sup/datos/tablas/paises/paises_deserializador.dart';
import 'package:trackmape_sup/datos/tablas/paises/paises_modelo.dart';
import 'package:trackmape_sup/datos/tablas/paises/paises_serializador.dart';

class PaisesFuente implements FuenteContrato<PaisesModelo> {
  final _deserializador = PaisesDeserializador();
  final _serializador = PaisesSerializador();
  static const _tabla = 'paises';

  @override
  Future<List<PaisesModelo>> obtenerTodos() async {
    final respuesta = await mensajero.seleccionar(_tabla);
    return respuesta.map(_deserializador.desdeJson).toList();
  }

  @override
  Future<PaisesModelo?> obtenerPorId(String id) async {
    final respuesta = await mensajero.seleccionarPor(_tabla, 'id_pais', id);
    if (respuesta == null) return null;
    return _deserializador.desdeJson(respuesta);
  }

  @override
  Future<void> insertar(PaisesModelo modelo) async {
    await mensajero.insertar(_tabla, _serializador.aJson(modelo));
  }

  @override
  Future<void> actualizar(PaisesModelo modelo) async {
    await mensajero.actualizar(
      _tabla,
      _serializador.aJson(modelo),
      'id_pais',
      modelo.id_pais,
    );
  }
}
