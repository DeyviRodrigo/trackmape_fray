import 'package:trackmape_sup/datos/tablas/carnets_plantillas_temp/carnets_plantillas_temp_fuente.dart';
import 'package:trackmape_sup/datos/tablas/carnets_plantillas_temp/carnets_plantillas_temp_modelo.dart';
import 'package:trackmape_sup/recursos/errores/ejecutar_errores.dart';

class CarnetsPlantillasTempRepositorio {
  final _fuente = CarnetsPlantillasTempFuente();

  Future<List<CarnetsPlantillasTempModelo>> obtenerTodos() =>
      ejecutar('Error al obtener plantillas', () => _fuente.obtenerTodos());

  Future<CarnetsPlantillasTempModelo?> obtenerPorId(String id) =>
      ejecutar('Error al obtener plantilla', () => _fuente.obtenerPorId(id));

  Future<List<CarnetsPlantillasTempModelo>> obtenerPorEmpresa(
    String idEmpresa,
  ) => ejecutar(
    'Error al obtener plantillas de empresa',
    () => _fuente.obtenerPorEmpresa(idEmpresa),
  );

  Future<CarnetsPlantillasTempModelo> insertar(
    CarnetsPlantillasTempModelo modelo,
  ) => ejecutar('Error al insertar plantilla', () async {
    await _fuente.insertar(modelo);
    return modelo;
  });

  Future<CarnetsPlantillasTempModelo> insertarYRetornar(
    CarnetsPlantillasTempModelo modelo,
  ) => ejecutar(
    'Error al insertar plantilla',
    () => _fuente.insertarYRetornar(modelo),
  );

  Future<CarnetsPlantillasTempModelo> actualizar(
    CarnetsPlantillasTempModelo modelo,
  ) => ejecutar('Error al actualizar plantilla', () async {
    await _fuente.actualizar(modelo);
    return modelo;
  });

  Future<void> desactivar(String id) =>
      ejecutar('Error al eliminar plantilla', () => _fuente.desactivar(id));
}
