import 'package:supabase_flutter/supabase_flutter.dart';

import '../modelos/modelo_equipo.dart';

class EmpresaDashboardMonitoreo {
  const EmpresaDashboardMonitoreo({required this.id, required this.nombre});

  final String id;
  final String nombre;
}

class RepositorioMonitoreo {
  final _supabase = Supabase.instance.client;
  static const String tipoEquipoSeeedWioTrackerL1 = 'SEEED WIO TRACKER L1';
  static const String empresaFrancisco1 =
      'c6a59aec-29ea-4e42-8ece-581df5e4459d';
  static const String empresaFrancisco2 =
      '63a9ae71-8881-4333-8927-41c48b35d104';
  static const List<String> empresasDashboardIds = [
    empresaFrancisco1,
    empresaFrancisco2,
  ];
  static const List<EmpresaDashboardMonitoreo> empresasDashboardFrancisco = [
    EmpresaDashboardMonitoreo(
      id: empresaFrancisco1,
      nombre: 'Empresa principal',
    ),
    EmpresaDashboardMonitoreo(
      id: empresaFrancisco2,
      nombre: 'EMPRESA MINERA AMS-6 SOCIEDAD ANONIMA',
    ),
  ];
  static const String empresaMonitoreoFija = empresaFrancisco1;
  static const String receptorFrancisco1 =
      'cb988466-ef79-401a-b4e9-6889f18d5466';
  static const String receptorFrancisco2 =
      'a07bb038-dcb9-466e-98c2-b0558a4363ea';
  static const String receptorMonitoreoFijo = receptorFrancisco2;
  static const String? sedeMonitoreoFija = null;

  static const int _limiteMaximoRegistros = 60000;
  static const Duration _intervaloStreamEnVivo = Duration(seconds: 5);
  static const int _limiteRecienteStream = 5000;
  static const int _limiteDiagnostico = 1000;
  static const int _tamanoPagina = 1000;
  static const Duration _ttlEquipos = Duration(minutes: 5);
  static const Duration _ttlTrayectoriaHistorica = Duration(minutes: 10);
  static const Duration _ttlTrayectoriaHoy = Duration(seconds: 20);
  static const Duration _ttlUltimasPosiciones = Duration(seconds: 10);

  static final Map<String, _CacheListaMapas> _cacheListasMapas = {};

  Future<List<EmpresaDashboardMonitoreo>> obtenerEmpresasDashboard() async {
    try {
      final respuesta = await _supabase
          .from('empresas')
          .select('id_empresa, razon_social, nombre_comercial')
          .inFilter('id_empresa', empresasDashboardIds)
          .order('razon_social', ascending: true)
          .timeout(const Duration(seconds: 10));

      final filas = List<Map<String, dynamic>>.from(respuesta);
      final empresasPorId = <String, EmpresaDashboardMonitoreo>{};

      for (final fila in filas) {
        final id = fila['id_empresa']?.toString().trim() ?? '';
        if (id.isEmpty) continue;

        final razonSocial = fila['razon_social']?.toString().trim() ?? '';
        final nombreComercial =
            fila['nombre_comercial']?.toString().trim() ?? '';
        final nombre = razonSocial.isNotEmpty
            ? razonSocial
            : nombreComercial.isNotEmpty
            ? nombreComercial
            : 'Empresa';

        empresasPorId[id] = EmpresaDashboardMonitoreo(id: id, nombre: nombre);
      }

      final empresas = empresasDashboardIds
          .map((id) => empresasPorId[id])
          .whereType<EmpresaDashboardMonitoreo>()
          .toList();

      return empresas.isNotEmpty ? empresas : empresasDashboardFrancisco;
    } catch (e) {
      print('Error obteniendo empresas dashboard: $e');
      return empresasDashboardFrancisco;
    }
  }

  static String nombreEmpresaDashboard(String idEmpresa) {
    for (final empresa in empresasDashboardFrancisco) {
      if (empresa.id == idEmpresa) return empresa.nombre;
    }

    return 'Empresa';
  }

  static String receptorMonitoreoParaEmpresa(String? idEmpresa) {
    switch (idEmpresa) {
      case empresaFrancisco1:
        return receptorFrancisco1;
      case empresaFrancisco2:
        return receptorFrancisco2;
      default:
        return receptorMonitoreoFijo;
    }
  }

  Stream<List<ModeloEquipo>> streamEquipos({
    String? tipoEquipoControl,
    String? fkEmpresa,
    String? fkSede,
  }) {
    return _supabase
        .from('equipos_control')
        .stream(primaryKey: ['id_equipo_control'])
        .map((lista) {
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

          final empresaFiltro = fkEmpresa?.trim();
          if (empresaFiltro != null && empresaFiltro.isNotEmpty) {
            equipos = equipos.where((equipo) {
              return (equipo.fkEmpresa?.trim() ?? '') == empresaFiltro;
            }).toList();
          }

          final sedeFiltro = fkSede?.trim();
          if (sedeFiltro != null && sedeFiltro.isNotEmpty) {
            equipos = equipos.where((equipo) {
              return (equipo.fkSede?.trim() ?? '') == sedeFiltro;
            }).toList();
          }

          return equipos;
        });
  }

  Future<List<Map<String, dynamic>>> obtenerEquiposRaw({
    bool soloCodigosConPrefijoExclamacion = false,
    String? tipoEquipoControl,
    String? fkEmpresa,
    String? fkSede,
  }) async {
    final cacheKey =
        'equipos::$soloCodigosConPrefijoExclamacion::${tipoEquipoControl ?? ''}::${fkEmpresa ?? ''}::${fkSede ?? ''}';
    final cache = _cacheListasMapas[cacheKey];
    if (cache != null && !cache.expirado(_ttlEquipos)) {
      return _clonarListaMapas(cache.data);
    }

    try {
      dynamic query = _supabase.from('equipos_control').select();
      if (fkEmpresa != null && fkEmpresa.trim().isNotEmpty) {
        query = query.eq('fk_empresa', fkEmpresa.trim());
      }
      if (fkSede != null && fkSede.trim().isNotEmpty) {
        query = query.eq('fk_sede', fkSede.trim());
      }

      final res = await query;
      var equipos = List<Map<String, dynamic>>.from(
        res,
      ).map(_normalizarEquipo).toList();

      final tipoFiltro = tipoEquipoControl?.trim();
      if (tipoFiltro != null && tipoFiltro.isNotEmpty) {
        equipos = equipos.where((equipo) {
          final tipo = equipo['tipo_equipo_control']?.toString().trim() ?? '';
          return tipo == tipoFiltro;
        }).toList();
      }

      if (soloCodigosConPrefijoExclamacion) {
        equipos = equipos.where((equipo) {
          final codigo =
              equipo['codigo_equipo_control']?.toString().trim() ?? '';
          return codigo.startsWith('!');
        }).toList();
      }

      _cacheListasMapas[cacheKey] = _CacheListaMapas(
        _clonarListaMapas(equipos),
      );
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
      _cacheListasMapas.removeWhere((key, _) => key.startsWith('equipos::'));
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

  Stream<List<Map<String, dynamic>>> obtenerTrayectoriaStream({
    String? tipoEquipoControl,
    String? fkEmpresa,
    String? fkSede,
  }) {
    return Stream<List<Map<String, dynamic>>>.multi((controller) async {
      while (!controller.isClosed) {
        try {
          controller.add(
            await _obtenerPosicionesTempValidadas(
              tipoEquipoControl: tipoEquipoControl,
              fkEmpresa: fkEmpresa,
              fkSede: fkSede,
            ),
          );
        } catch (e, st) {
          controller.addError(e, st);
        }

        await Future<void>.delayed(_intervaloStreamEnVivo);
      }
    });
  }

  Future<List<Map<String, dynamic>>> obtenerUltimasPosiciones({
    String? tipoEquipoControl,
    String? fkEmpresa,
    String? fkSede,
  }) async {
    final cacheKey =
        'ultimas_posiciones::${tipoEquipoControl ?? ''}::${fkEmpresa ?? ''}::${fkSede ?? ''}';
    final cache = _cacheListasMapas[cacheKey];
    if (cache != null && !cache.expirado(_ttlUltimasPosiciones)) {
      return _clonarListaMapas(cache.data);
    }

    try {
      final equiposPorId = await _obtenerEquiposPorId(
        tipoEquipoControl: tipoEquipoControl,
        fkEmpresa: fkEmpresa,
        fkSede: fkSede,
      );
      final equiposPorCodigo = await _obtenerEquiposPorCodigo(
        tipoEquipoControl: tipoEquipoControl,
        fkEmpresa: fkEmpresa,
        fkSede: fkSede,
      );
      final consultaPosiciones = await _obtenerPosicionesTempNormalizadas(
        limite: _limiteMaximoRegistros,
        fkReceptor: receptorMonitoreoParaEmpresa(fkEmpresa),
        equiposPorId: equiposPorId,
        equiposPorCodigo: equiposPorCodigo,
      );
      final posicionesValidadas = consultaPosiciones.normalizadas;

      final listaUnica = <String, Map<String, dynamic>>{};
      for (final item in posicionesValidadas) {
        final idEmisor = item['fk_emisor'].toString();
        if (!listaUnica.containsKey(idEmisor)) {
          listaUnica[idEmisor] = Map<String, dynamic>.from(item);
        }
      }
      final resultado = listaUnica.values.toList();
      _cacheListasMapas[cacheKey] = _CacheListaMapas(
        _clonarListaMapas(resultado),
      );
      return resultado;
    } catch (e) {
      print('Error en obtenerUltimasPosiciones: $e');
      return [];
    }
  }

  Future<Map<String, DateTime?>> obtenerUltimosTiemposPorEquipo({
    String? tipoEquipoControl,
    String? fkEmpresa,
    String? fkSede,
  }) async {
    try {
      final equipos = await obtenerEquiposRaw(
        tipoEquipoControl: tipoEquipoControl,
        fkEmpresa: fkEmpresa,
        fkSede: fkSede,
      );
      final resultado = <String, DateTime?>{};
      final receptor = receptorMonitoreoParaEmpresa(fkEmpresa);

      for (final equipo in equipos) {
        final id = equipo['id_equipo_control']?.toString().trim() ?? '';
        if (id.isEmpty) continue;

        final identificadores = _identificadoresPosiblesEquipo(equipo);
        DateTime? ultimo;

        for (final tabla in ['posiciones_temp', 'posiciones']) {
          final tiempo = await _obtenerUltimoTiempoEquipoEnTabla(
            tabla: tabla,
            identificadores: identificadores,
            fkReceptor: receptor,
          );
          if (tiempo != null && (ultimo == null || tiempo.isAfter(ultimo))) {
            ultimo = tiempo;
          }
        }

        resultado[id] = ultimo;
      }

      return resultado;
    } catch (e) {
      print('Error en obtenerUltimosTiemposPorEquipo: $e');
      return {};
    }
  }

  Stream<List<Map<String, dynamic>>> streamUltimasConexiones({
    String? tipoEquipoControl,
    String? fkEmpresa,
    String? fkSede,
  }) {
    return _supabase
        .from('posiciones_temp')
        .stream(primaryKey: ['id_posicion'])
        .eq('fk_receptor', receptorMonitoreoParaEmpresa(fkEmpresa))
        .order('tiempo', ascending: false)
        .limit(200)
        .asyncMap((lista) async {
          final equiposPorId = await _obtenerEquiposPorId(
            tipoEquipoControl: tipoEquipoControl,
            fkEmpresa: fkEmpresa,
            fkSede: fkSede,
          );
          final equiposPorCodigo = await _obtenerEquiposPorCodigo(
            tipoEquipoControl: tipoEquipoControl,
            fkEmpresa: fkEmpresa,
            fkSede: fkSede,
          );
          return _normalizarPosicionesTemp(
            lista,
            equiposPorId: equiposPorId,
            equiposPorCodigo: equiposPorCodigo,
          );
        });
  }

  Future<List<Map<String, dynamic>>> obtenerDatosParaSimulacion(
    DateTime fecha,
  ) async {
    return obtenerTrayectoriaPorFecha(fecha);
  }

  Future<List<Map<String, dynamic>>> obtenerTrayectoriaPorFecha(
    DateTime fecha, {
    String? tipoEquipoControl,
    String? fkEmpresa,
    String? fkSede,
  }) async {
    final esHoy = _esMismoDia(fecha, DateTime.now());
    final cacheKey =
        'trayectoria::${_claveFecha(fecha)}::${tipoEquipoControl ?? ''}::${fkEmpresa ?? ''}::${fkSede ?? ''}';
    final cache = _cacheListasMapas[cacheKey];
    final ttl = esHoy ? _ttlTrayectoriaHoy : _ttlTrayectoriaHistorica;
    if (cache != null && !cache.expirado(ttl)) {
      return _clonarListaMapas(cache.data);
    }

    try {
      final resultado = await _obtenerPosicionesHistoricasValidadasPorFecha(
        fecha,
        tipoEquipoControl: tipoEquipoControl,
        fkEmpresa: fkEmpresa,
        fkSede: fkSede,
      );
      _cacheListasMapas[cacheKey] = _CacheListaMapas(
        _clonarListaMapas(resultado),
      );
      return resultado;
    } catch (e) {
      print('Error en obtenerTrayectoriaPorFecha: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> obtenerDiagnosticoStream({
    String? tipoEquipoControl,
    String? fkEmpresa,
    String? fkSede,
  }) async {
    final tipoFiltro = tipoEquipoControl ?? tipoEquipoSeeedWioTrackerL1;
    final empresaFiltro = fkEmpresa ?? empresaMonitoreoFija;
    final sedeFiltro = fkSede ?? sedeMonitoreoFija;
    final equipos = await obtenerEquiposRaw(
      tipoEquipoControl: tipoFiltro,
      fkEmpresa: empresaFiltro,
      fkSede: sedeFiltro,
    );
    final equiposPorId = await _obtenerEquiposPorId(
      tipoEquipoControl: tipoFiltro,
      fkEmpresa: empresaFiltro,
      fkSede: sedeFiltro,
    );
    final equiposPorCodigo = await _obtenerEquiposPorCodigo(
      tipoEquipoControl: tipoFiltro,
      fkEmpresa: empresaFiltro,
      fkSede: sedeFiltro,
    );
    final consultaPosiciones = await _obtenerPosicionesTempNormalizadas(
      limite: _limiteDiagnostico,
      fkReceptor: receptorMonitoreoParaEmpresa(empresaFiltro),
      equiposPorId: equiposPorId,
      equiposPorCodigo: equiposPorCodigo,
    );
    final posiciones = consultaPosiciones.raw;
    final posicionesValidadas = consultaPosiciones.normalizadas;
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
      final cruda = codigoLimpio.isEmpty
          ? null
          : ultimaCrudaPorCodigo[codigoLimpio];

      String estado;
      String detalle;

      if (codigoLimpio.isEmpty) {
        estado = 'sin_codigo';
        detalle = 'El equipo no tiene codigo_equipo_control';
      } else if (valida != null) {
        final tiempo = DateTime.tryParse(valida['tiempo']?.toString() ?? '');
        final activo =
            tiempo != null && ahora.difference(tiempo).inSeconds.abs() <= 60;
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

        if (lat == 0.0 ||
            lon == 0.0 ||
            lat < -20 ||
            lat > -10 ||
            lon < -75 ||
            lon > -65) {
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
    String? tipoEquipoControl,
    String? fkEmpresa,
    String? fkSede,
  }) async {
    final equipos = await obtenerEquiposRaw(
      soloCodigosConPrefijoExclamacion: soloCodigosConPrefijoExclamacion,
      tipoEquipoControl: tipoEquipoControl,
      fkEmpresa: fkEmpresa,
      fkSede: fkSede,
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

  Future<Map<String, Map<String, dynamic>>> _obtenerEquiposPorId({
    String? tipoEquipoControl,
    String? fkEmpresa,
    String? fkSede,
  }) async {
    final equipos = await obtenerEquiposRaw(
      tipoEquipoControl: tipoEquipoControl,
      fkEmpresa: fkEmpresa,
      fkSede: fkSede,
    );
    final mapa = <String, Map<String, dynamic>>{};

    for (final equipo in equipos) {
      final id = equipo['id_equipo_control']?.toString().trim() ?? '';
      if (id.isEmpty) continue;
      mapa[id] = equipo;
    }

    return mapa;
  }

  Future<List<Map<String, dynamic>>> _obtenerPosicionesTempValidadas({
    String? tipoEquipoControl,
    String? fkEmpresa,
    String? fkSede,
  }) async {
    final equiposPorId = await _obtenerEquiposPorId(
      tipoEquipoControl: tipoEquipoControl,
      fkEmpresa: fkEmpresa,
      fkSede: fkSede,
    );
    final equiposPorCodigo = await _obtenerEquiposPorCodigo(
      tipoEquipoControl: tipoEquipoControl,
      fkEmpresa: fkEmpresa,
      fkSede: fkSede,
    );
    final consultaPosiciones = await _obtenerPosicionesTempNormalizadas(
      limite: _limiteRecienteStream,
      fkReceptor: receptorMonitoreoParaEmpresa(fkEmpresa),
      equiposPorId: equiposPorId,
      equiposPorCodigo: equiposPorCodigo,
    );
    final normalizadas = consultaPosiciones.normalizadas;
    normalizadas.sort((a, b) => a['tiempo'].compareTo(b['tiempo']));
    return normalizadas;
  }

  Future<_ConsultaPosicionesTemp> _obtenerPosicionesTempNormalizadas({
    required int limite,
    required String fkReceptor,
    required Map<String, Map<String, dynamic>> equiposPorId,
    required Map<String, Map<String, dynamic>> equiposPorCodigo,
  }) async {
    final conReceptor = await _consultarPosicionesTempRecientes(
      limite: limite,
      fkReceptor: fkReceptor,
    );
    final normalizadasConReceptor = _normalizarPosicionesTemp(
      conReceptor,
      equiposPorId: equiposPorId,
      equiposPorCodigo: equiposPorCodigo,
    );

    if (normalizadasConReceptor.any(_posicionTieneCoordenadaOperativa)) {
      return _ConsultaPosicionesTemp(
        raw: conReceptor,
        normalizadas: normalizadasConReceptor,
      );
    }

    final sinReceptor = await _consultarPosicionesTempRecientes(limite: limite);
    final normalizadasSinReceptor = _normalizarPosicionesTemp(
      sinReceptor,
      equiposPorId: equiposPorId,
      equiposPorCodigo: equiposPorCodigo,
    );

    if (normalizadasSinReceptor.any(_posicionTieneCoordenadaOperativa)) {
      return _ConsultaPosicionesTemp(
        raw: sinReceptor,
        normalizadas: normalizadasSinReceptor,
      );
    }

    return _ConsultaPosicionesTemp(
      raw: conReceptor.isNotEmpty ? conReceptor : sinReceptor,
      normalizadas: normalizadasConReceptor.isNotEmpty
          ? normalizadasConReceptor
          : normalizadasSinReceptor,
    );
  }

  Future<List<Map<String, dynamic>>> _consultarPosicionesTempRecientes({
    required int limite,
    String? fkReceptor,
  }) async {
    dynamic query = _supabase.from('posiciones_temp').select();
    if (fkReceptor != null && fkReceptor.trim().isNotEmpty) {
      query = query.eq('fk_receptor', fkReceptor.trim());
    }

    final respuesta = await query
        .order('tiempo', ascending: false)
        .limit(limite);

    return List<Map<String, dynamic>>.from(respuesta);
  }

  Future<DateTime?> _obtenerUltimoTiempoEquipoEnTabla({
    required String tabla,
    required Set<String> identificadores,
    required String fkReceptor,
  }) async {
    DateTime? ultimo;

    for (final identificador in identificadores) {
      if (identificador.trim().isEmpty) continue;

      dynamic query = _supabase
          .from(tabla)
          .select('tiempo')
          .eq('fk_emisor', identificador.trim());
      if (fkReceptor.trim().isNotEmpty) {
        query = query.eq('fk_receptor', fkReceptor.trim());
      }

      final respuesta = await query.order('tiempo', ascending: false).limit(1);
      final filas = List<Map<String, dynamic>>.from(respuesta);
      if (filas.isEmpty) continue;

      final tiempo = DateTime.tryParse(filas.first['tiempo']?.toString() ?? '');
      if (tiempo != null && (ultimo == null || tiempo.isAfter(ultimo))) {
        ultimo = tiempo;
      }
    }

    return ultimo;
  }

  Future<List<Map<String, dynamic>>>
  _obtenerPosicionesHistoricasValidadasPorFecha(
    DateTime fecha, {
    String? tipoEquipoControl,
    String? fkEmpresa,
    String? fkSede,
  }) async {
    final equiposPorId = await _obtenerEquiposPorId(
      tipoEquipoControl: tipoEquipoControl,
      fkEmpresa: fkEmpresa,
      fkSede: fkSede,
    );
    final equiposPorCodigo = await _obtenerEquiposPorCodigo(
      tipoEquipoControl: tipoEquipoControl,
      fkEmpresa: fkEmpresa,
      fkSede: fkSede,
    );
    final inicioDia = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      0,
      0,
      0,
    ).toIso8601String();
    final finDia = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      23,
      59,
      59,
    ).toIso8601String();

    final receptor = receptorMonitoreoParaEmpresa(fkEmpresa);
    var acumulado = await _consultarPosicionesPorFecha(
      tabla: 'posiciones_temp',
      inicioDia: inicioDia,
      finDia: finDia,
      fkReceptor: receptor,
    );

    var normalizadas = _normalizarPosicionesHistoricas(
      acumulado,
      equiposPorId: equiposPorId,
      equiposPorCodigo: equiposPorCodigo,
    );

    if (normalizadas.any(_posicionTieneCoordenadaOperativa)) {
      return normalizadas;
    }

    acumulado = await _consultarPosicionesPorFecha(
      tabla: 'posiciones',
      inicioDia: inicioDia,
      finDia: finDia,
      fkReceptor: receptor,
    );

    normalizadas = _normalizarPosicionesHistoricas(
      acumulado,
      equiposPorId: equiposPorId,
      equiposPorCodigo: equiposPorCodigo,
    );

    if (normalizadas.any(_posicionTieneCoordenadaOperativa)) {
      return normalizadas;
    }

    final tempSinReceptor = await _consultarPosicionesPorFecha(
      tabla: 'posiciones_temp',
      inicioDia: inicioDia,
      finDia: finDia,
    );

    return _normalizarPosicionesHistoricas(
      tempSinReceptor,
      equiposPorId: equiposPorId,
      equiposPorCodigo: equiposPorCodigo,
    );
  }

  Future<List<Map<String, dynamic>>> _consultarPosicionesPorFecha({
    required String tabla,
    required String inicioDia,
    required String finDia,
    String? fkReceptor,
  }) async {
    final acumulado = <Map<String, dynamic>>[];
    var pagina = 0;

    while (acumulado.length < _limiteMaximoRegistros) {
      final inicio = pagina * _tamanoPagina;
      final fin = inicio + _tamanoPagina - 1;

      dynamic query = _supabase
          .from(tabla)
          .select()
          .gte('tiempo', inicioDia)
          .lte('tiempo', finDia);

      if (fkReceptor != null && fkReceptor.trim().isNotEmpty) {
        query = query.eq('fk_receptor', fkReceptor.trim());
      }

      final respuesta = await query
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

    return acumulado;
  }

  List<Map<String, dynamic>> _normalizarPosicionesTemp(
    List<dynamic> posiciones, {
    required Map<String, Map<String, dynamic>> equiposPorId,
    required Map<String, Map<String, dynamic>> equiposPorCodigo,
  }) {
    final resultado = <Map<String, dynamic>>[];

    for (final item in posiciones) {
      final posicion = Map<String, dynamic>.from(item as Map);
      final emisorOriginal = posicion['fk_emisor']?.toString().trim() ?? '';
      if (emisorOriginal.isEmpty) continue;

      Map<String, dynamic>? equipo = equiposPorId[emisorOriginal];
      String codigoEmisor = '';
      if (equipo == null) {
        codigoEmisor = _canonizarCodigoVinculo(emisorOriginal);
        if (codigoEmisor.isEmpty) continue;
        equipo = equiposPorCodigo[codigoEmisor];
      }
      if (equipo == null) continue;

      if (codigoEmisor.isEmpty) {
        codigoEmisor = _canonizarCodigoVinculo(
          equipo['codigo_equipo_control']?.toString(),
        );
      }

      resultado.add({
        ...posicion,
        'fk_emisor_original': emisorOriginal,
        'fk_emisor_codigo_limpio': codigoEmisor,
        'fk_emisor': equipo['id_equipo_control'],
        'id_equipo_control': equipo['id_equipo_control'],
        'codigo_equipo_control': equipo['codigo_equipo_control'],
        'nombre': equipo['nombre'],
        'fk_empresa': equipo['fk_empresa'],
        'fk_sede': equipo['fk_sede'],
        'tipo_equipo_control': equipo['tipo_equipo_control'],
        'activo': equipo['activo'],
      });
    }

    return resultado;
  }

  bool _posicionTieneCoordenadaOperativa(Map<String, dynamic> posicion) {
    final lat = (posicion['lat_grados'] as num?)?.toDouble() ?? 0.0;
    final lon = (posicion['lon_grados'] as num?)?.toDouble() ?? 0.0;

    return lat != 0.0 &&
        lon != 0.0 &&
        lat >= -20 &&
        lat <= -10 &&
        lon >= -75 &&
        lon <= -65;
  }

  List<Map<String, dynamic>> _normalizarPosicionesHistoricas(
    List<dynamic> posiciones, {
    required Map<String, Map<String, dynamic>> equiposPorId,
    required Map<String, Map<String, dynamic>> equiposPorCodigo,
  }) {
    final resultado = <Map<String, dynamic>>[];

    for (final item in posiciones) {
      final posicion = Map<String, dynamic>.from(item as Map);
      final emisorOriginal = posicion['fk_emisor']?.toString().trim() ?? '';
      if (emisorOriginal.isEmpty) continue;

      Map<String, dynamic>? equipo = equiposPorId[emisorOriginal];
      String? codigoLimpio;

      if (equipo == null) {
        codigoLimpio = _canonizarCodigoVinculo(emisorOriginal);
        if (codigoLimpio.isEmpty) continue;
        equipo = equiposPorCodigo[codigoLimpio];
      }

      if (equipo == null) continue;

      codigoLimpio ??= _canonizarCodigoVinculo(
        equipo['codigo_equipo_control']?.toString(),
      );

      resultado.add({
        ...posicion,
        'fk_emisor_original': emisorOriginal,
        'fk_emisor_codigo_limpio': codigoLimpio,
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

  Set<String> _identificadoresPosiblesEquipo(Map<String, dynamic> equipo) {
    final identificadores = <String>{};

    void agregar(String? valor) {
      final limpio = valor?.trim();
      if (limpio == null || limpio.isEmpty) return;
      identificadores.add(limpio);
      identificadores.add(limpio.toUpperCase());

      final canonico = _canonizarCodigoVinculo(limpio);
      if (canonico.isNotEmpty) {
        identificadores.add(canonico);
        identificadores.add('!$canonico');
      }
    }

    agregar(equipo['id_equipo_control']?.toString());
    agregar(equipo['codigo_equipo_control']?.toString());
    agregar(equipo['id_equipo_fabrica']?.toString());

    return identificadores;
  }

  List<Map<String, dynamic>> _clonarListaMapas(
    List<Map<String, dynamic>> origen,
  ) {
    return origen.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  bool _esMismoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _claveFecha(DateTime fecha) {
    final normalizada = DateTime(fecha.year, fecha.month, fecha.day);
    return normalizada.toIso8601String().split('T').first;
  }
}

class _CacheListaMapas {
  final List<Map<String, dynamic>> data;
  final DateTime creadoEn;

  _CacheListaMapas(this.data) : creadoEn = DateTime.now();

  bool expirado(Duration ttl) => DateTime.now().difference(creadoEn) > ttl;
}

class _ConsultaPosicionesTemp {
  final List<Map<String, dynamic>> raw;
  final List<Map<String, dynamic>> normalizadas;

  const _ConsultaPosicionesTemp({
    required this.raw,
    required this.normalizadas,
  });
}
