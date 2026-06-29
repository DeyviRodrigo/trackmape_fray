import 'package:trackmape_sup/recursos/errores/repositorio_exception.dart';

Future<T> ejecutar<T>(String contexto, Future<T> Function() accion) async {
  try {
    return await accion();
  } catch (e, s) {
    if (e is RepositorioException) rethrow;
    throw RepositorioException(contexto, causa: e, rastreo: s);
  }
}
