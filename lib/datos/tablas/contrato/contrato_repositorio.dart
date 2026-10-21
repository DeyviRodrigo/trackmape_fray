import 'package:trackmape_sup/datos/tablas/contrato/contrato_fuente.dart';
import 'package:trackmape_sup/datos/tablas/contrato/contrato_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class ContratoRepositorio {
  final _fuente = ContratoFuente();

  Future<List<ContratoModelo>> obtenerTodos() =>
      ejecutar('Error al obtener contratos', () => _fuente.obtenerTodos());

  Future<ContratoModelo?> obtenerPorId(String id) =>
      ejecutar('Error al obtener contrato', () => _fuente.obtenerPorId(id));

  Future<ContratoModelo> insertar(ContratoModelo modelo) =>
      ejecutar('Error al insertar contrato', () async {
        await _fuente.insertar(modelo);
        return modelo;
      });

  Future<ContratoModelo> actualizar(ContratoModelo modelo) =>
      ejecutar('Error al actualizar contrato', () async {
        await _fuente.actualizar(modelo);
        return modelo;
      });
}
