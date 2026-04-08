import 'package:supabase_flutter/supabase_flutter.dart';

import '../modelos/modelo_equipo.dart';

class RepositorioMonitoreo {
  final _supabase = Supabase.instance.client;
  static const String tipoEquipoSeeedWioTrackerL1 = 'SEEED WIO TRACKER L1';

  static const int _limiteMaximoRegistros = 60000;
  static const Duration _intervaloStreamEnVivo = Duration(seconds: 5);
  static const int _limiteRecienteStream = 5000;
  static const int _limiteDiagnostico = 1000;
  static const int _tamanoPagina = 1000;

  Stream<List<ModeloEquipo>> streamEquipos({
    String? tipoEquipoControl,
  }) {
    return _supabase
        .from('equipos_control')
        .stream(primaryKey: ['id_equipo_control'])
        .map(
          (lista) {
            var equipos = lista
                .map((e) => ModeloEquipo.fromJson(_normalizarEquipo(e)))
                .toList();

            final tipoFiltro = tipoEquipoControl?.trim();
            if (tipoFiltro != null && tipoFiltro.isNotEmpty) {
              equipos = equipos.where((equipo) {
                final tipo = equipo.tipoEquipo?.trim() ?? '';
                return tipo == tipoFiltro;
              }).toList();
            }

            return equipos;
          },
        );
  }

  Future<List<Map<String, dynamic>>> obtenerEquiposRaw({
    bool soloCodigosConPrefijoExclamacion = false,
  }) async {
    try {
      final res = await _supabase.from('equipos_control').select();
      var equipos = List<Map<String, dynamic>>.from(res).map(_normalizarEquipo).toList();

      if (soloCodigosConPrefijoExclamacion) {
        equipos = equipos.where((equipo) {
          final codigo = equipo['codigo_equipo_control']?.toString().trim() ?? '';
          return codigo.startsWith('!');
        }).toList();
      }

      return equipos;
    } catch (e) {
      print('Error en obtenerEquiposRaw: $e');
      return [];
    }
  }

  Future<bool> actualizarEquipo(String id, Map<String, dynamic> datos) async {
    try {
      await _supabase
          .from('equipos_control')
          .update(datos)
          .eq('id_equipo_control', id);
      return true;
    } catch (e) {
      print('Error al actualizar equipo: $e');
      return false;
    }
  }

  Map<String, dynamic> _normalizarEquipo(Map<String, dynamic> equipo) {
    final normalizado = Map<String, dynamic>.from(equipo);
    normalizado['activo'] = normalizado['fecha_final'] == null;
    return normalizado;
  }

  Stream<List<Map<String, dynamic>>> obtenerTrayectoriaStream() {
    return Stream<List<Map<String, dynamic>>>.multi((controller) async {
      while (!controller.isClosed) {
        try {
          controller.add(await _obtenerPosicionesTempValidadas());
        } catch (e, st) {
          controller.addError(e, st);
        }

        await Future<void>.delayed(_intervaloStreamEnVivo);
      }
    });
  }

  Future<List<Map<String, dynamic>>> obtenerUltimasPosiciones() async {
    try {
      final equiposPorCodigo = await _obtenerEquiposPorCodigo(
        soloCodigosConPrefijoExclamacion: true,
      );
      final respuesta = await _supabase
          .from('posiciones_temp')
          .select()
          .order('tiempo', ascending: false)
          .limit(_limiteMaximoRegistros);

      final posicionesValidadas =
          _normalizarPosicionesTemp(respuesta as List, equiposPorCodigo);

      final listaUnica = <String, Map<String, dynamic>>{};
      for (final item in posicionesValidadas) {
        final idEmisor = item['fk_emisor'].toString();
        if (!listaUnica.containsKey(idEmisor)) {
          listaUnica[idEmisor] = Map<String, dynamic>.from(item);
        }
      }
      return listaUnica.values.toList();
    } catch (e) {
      print('Error en obtenerUltimasPosiciones: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> streamUltimasConexiones() {
    return _supabase
        .from('posiciones_temp')
        .stream(primaryKey: ['id_posicion'])
        .order('tiempo', ascending: false)
        .limit(200)
        .asyncMap((lista) async {
          final equiposPorCodigo = await _obtenerEquiposPorCodigo(
            soloCodigosConPrefijoExclamacion: true,
          );
          return _normalizarPosicionesTemp(lista, equiposPorCodigo);
        });
  }

  Future<List<Map<String, dynamic>>> obtenerDatosParaSimulacion(DateTime fecha) async {
    return _obtenerPosicionesTempValidadasPorFecha(fecha);
  }

  Future<List<Map<String, dynamic>>> obtenerTrayectoriaPorFecha(DateTime fecha) async {
    try {
      return _obtenerPosicionesTempValidadasPorFecha(fecha);
    } catch (e) {
      print('Error en obtenerTrayectoriaPorFecha: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> obtenerDiagnosticoStream() async {
    final equipos = await obtenerEquiposRaw(
      soloCodigosConPrefijoExclamacion: true,
    );
      final equiposPorCodigo = await _obtenerEquiposPorCodigo(
        soloCodigosConPrefijoExclamacion: true,
      );
    final respuesta = await _supabase
        .from('posiciones_temp')
        .select()
        .order('tiempo', ascending: false)
        .limit(_limiteDiagnostico);

    final posiciones = List<Map<String, dynamic>>.from(respuesta);
    final posicionesValidadas = _normalizarPosicionesTemp(posiciones, equiposPorCodigo);
    final ultimaValidaPorEquipo = <String, Map<String, dynamic>>{};

    for (final item in posicionesValidadas) {
      final id = item['fk_emisor'].toString();
      ultimaValidaPorEquipo.putIfAbsent(id, () => item);
    }

    final ultimaCrudaPorCodigo = <String, Map<String, dynamic>>{};
    for (final item in posiciones) {
      final codigoOriginal = item['fk_emisor']?.toString().trim() ?? '';
      final codigoLimpio = _canonizarCodigoVinculo(codigoOriginal);
      if (codigoLimpio.isEmpty) continue;
      ultimaCrudaPorCodigo.putIfAbsent(codigoLimpio, () => item);
    }

    final ahora = DateTime.now();
    final diagnostico = <Map<String, dynamic>>[];

    for (final equipo in equipos) {
      final id = equipo['id_equipo_control'].toString();
      final codigo = equipo['codigo_equipo_control']?.toString().trim() ?? '';
      final codigoLimpio = _canonizarCodigoVinculo(codigo);
      final valida = ultimaValidaPorEquipo[id];
      final cruda = codigoLimpio.isEmpty ? null : ultimaCrudaPorCodigo[codigoLimpio];

      String estado;
      String detalle;

      if (codigoLimpio.isEmpty) {
        estado = 'sin_codigo';
        detalle = 'El equipo no tiene codigo_equipo_control';
      } else if (valida != null) {
        final tiempo = DateTime.tryParse(valida['tiempo']?.toString() ?? '');
        final activo = tiempo != null && ahora.difference(tiempo).inSeconds.abs() <= 60;
        estado = activo ? 'ok' : 'sin_dato_reciente';
        detalle = activo
            ? 'Recibiendo datos correctamente'
            : 'Tiene dato vinculado, pero no reciente';
      } else if (cruda == null) {
        estado = 'sin_dato';
        detalle = 'No existe registro reciente en posiciones_temp';
      } else {
        final lat = (cruda['lat_grados'] as num?)?.toDouble() ?? 0.0;
        final lon = (cruda['lon_grados'] as num?)?.toDouble() ?? 0.0;

        if (lat == 0.0 || lon == 0.0 || lat < -20 || lat > -10 || lon < -75 || lon > -65) {
          estado = 'coordenada_invalida';
          detalle = 'Existe registro, pero la coordenada es invalida';
        } else {
          estado = 'sin_match';
          detalle = 'Hay dato, pero no logro vincularse con equipos_control';
        }
      }

      diagnostico.add({
        'id_equipo_control': id,
        'nombre': equipo['nombre'],
        'codigo_equipo_control': codigo,
        'estado': estado,
        'detalle': detalle,
        'ultimo_valido': valida,
        'ultimo_crudo': cruda,
      });
    }

    diagnostico.sort((a, b) {
      final nombreA = (a['nombre']?.toString().trim().isNotEmpty ?? false)
          ? a['nombre'].toString()
          : a['codigo_equipo_control']?.toString() ?? '';
      final nombreB = (b['nombre']?.toString().trim().isNotEmpty ?? false)
          ? b['nombre'].toString()
          : b['codigo_equipo_control']?.toString() ?? '';
      return nombreA.compareTo(nombreB);
    });

    return diagnostico;
  }

  Future<Map<String, Map<String, dynamic>>> _obtenerEquiposPorCodigo({
    bool soloCodigosConPrefijoExclamacion = false,
  }) async {
    final equipos = await obtenerEquiposRaw(
      soloCodigosConPrefijoExclamacion: soloCodigosConPrefijoExclamacion,
    );
    final mapa = <String, Map<String, dynamic>>{};

    for (final equipo in equipos) {
      final codigo = _canonizarCodigoVinculo(
        equipo['codigo_equipo_control']?.toString(),
      );
      if (codigo.isEmpty) continue;
      mapa[codigo] = equipo;
    }

    return mapa;
  }

  Future<List<Map<String, dynamic>>> _obtenerPosicionesTempValidadas() async {
    final equiposPorCodigo = await _obtenerEquiposPorCodigo(
      soloCodigosConPrefijoExclamacion: true,
    );
    final respuesta = await _supabase
        .from('posiciones_temp')
        .select()
        .order('tiempo', ascending: false)
        .limit(_limiteRecienteStream);

    final normalizadas =
        _normalizarPosicionesTemp(respuesta as List, equiposPorCodigo);
    normalizadas.sort((a, b) => a['tiempo'].compareTo(b['tiempo']));
    return normalizadas;
  }

  Future<List<Map<String, dynamic>>> _obtenerPosicionesTempValidadasPorFecha(
    DateTime fecha,
  ) async {
    final equiposPorCodigo = await _obtenerEquiposPorCodigo();
    final inicioDia = DateTime(fecha.year, fecha.month, fecha.day, 0, 0, 0)
        .toIso8601String();
    final finDia = DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59)
        .toIso8601String();

    final acumulado = <Map<String, dynamic>>[];
    var pagina = 0;

    while (acumulado.length < _limiteMaximoRegistros) {
      final inicio = pagina * _tamanoPagina;
      final fin = inicio + _tamanoPagina - 1;

      final respuesta = await _supabase
          .from('posiciones_temp')
          .select()
          .gte('tiempo', inicioDia)
          .lte('tiempo', finDia)
          .order('tiempo', ascending: true)
          .range(inicio, fin);

      final bloque = List<Map<String, dynamic>>.from(respuesta);
      if (bloque.isEmpty) break;

      acumulado.addAll(bloque);

      if (bloque.length < _tamanoPagina) break;
      pagina++;
    }

    if (acumulado.length > _limiteMaximoRegistros) {
      acumulado.removeRange(_limiteMaximoRegistros, acumulado.length);
    }

    return _normalizarPosicionesTemp(acumulado, equiposPorCodigo);
  }

  List<Map<String, dynamic>> _normalizarPosicionesTemp(
    List<dynamic> posiciones,
    Map<String, Map<String, dynamic>> equiposPorCodigo,
  ) {
    final resultado = <Map<String, dynamic>>[];

    for (final item in posiciones) {
      final posicion = Map<String, dynamic>.from(item as Map);
      final codigoEmisorOriginal = posicion['fk_emisor']?.toString().trim() ?? '';
      final codigoEmisor = _canonizarCodigoVinculo(codigoEmisorOriginal);

      if (codigoEmisor.isEmpty) continue;

      final equipo = equiposPorCodigo[codigoEmisor];
      if (equipo == null) continue;

      resultado.add({
        ...posicion,
        'fk_emisor_original': codigoEmisorOriginal,
        'fk_emisor_codigo_limpio': codigoEmisor,
        'fk_emisor': equipo['id_equipo_control'],
        'id_equipo_control': equipo['id_equipo_control'],
        'codigo_equipo_control': equipo['codigo_equipo_control'],
      });
    }

    return resultado;
  }

  String _canonizarCodigoVinculo(String? valor) {
    if (valor == null) return '';

    var limpio = valor.trim().toUpperCase();
    if (limpio.isEmpty) return '';

    limpio = limpio.replaceFirst(RegExp(r'^0X'), '');
    limpio = limpio.replaceFirst(RegExp(r'^[^A-Z0-9]+'), '');
    limpio = limpio.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    return limpio;
  }
}
