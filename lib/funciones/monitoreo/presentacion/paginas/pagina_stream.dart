import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/core/mapas/coordenadas_operacion.dart';
import 'package:trackmape_sup/core/ui/track_custom_icons.dart';
import 'package:trackmape_sup/funciones/gis/datos/repositorios/repositorio_gis.dart';
import 'package:trackmape_sup/funciones/gis/presentacion/widgets/capas_gis_mapa.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';

class PaginaStream extends StatefulWidget {
  const PaginaStream({
    super.key,
    this.equipoIdFiltro,
    this.nombreEquipoFiltro,
    this.empresaFiltro,
  });

  final String? equipoIdFiltro;
  final String? nombreEquipoFiltro;
  final String? empresaFiltro;

  @override
  State<PaginaStream> createState() => _PaginaStreamState();
}

class _PaginaStreamState extends State<PaginaStream> {
  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();
  final RepositorioGis _repositorioGis = RepositorioGis();
  final MapController _mapController = MapController();
  final ScrollController _tarjetasController = ScrollController();
  static const Duration _duracionColaRastro = Duration(seconds: 40);
  static const Duration _umbralAlertaSinDatos = Duration(minutes: 5);
  static const Duration _intervaloAlertaSinDatos = Duration(seconds: 30);
  static const Duration _intervaloMaximoTramoRastro = Duration(seconds: 8);
  static const int _maxPuntosColaRastro = 9;
  static const double _distanciaMaximaTramoRastroMetros = 300.0;
  static const Duration _ventanaSaltoFuerte = Duration(seconds: 12);
  static const Duration _tiempoMaximoConfirmacionSalto = Duration(seconds: 45);
  static const double _velocidadMaximaRealistaKmh = 95.0;
  static const double _distanciaSaltoFuerteMetros = 260.0;
  static const double _toleranciaSaltoMetros = 80.0;
  static const double _radioConfirmacionSaltoMetros = 140.0;

  static const double _zoomReferenciaMovil = 15.0;
  static const double _zoomReferenciaWeb = 15.0;
  static const double _tamanoBaseIconoMovil = 56.0;
  static const double _tamanoBaseIconoWeb = 60.0;
  static const double _tamanoBaseIconoDesktop = 58.0;
  static const double _tamanoMinimoIconoMovil = 42.0;
  static const double _tamanoMinimoIconoWeb = 46.0;
  static const double _tamanoMinimoIconoDesktop = 44.0;
  static const double _tamanoMaximoIconoMovil = 74.0;
  static const double _tamanoMaximoIconoWeb = 84.0;
  static const double _tamanoMaximoIconoDesktop = 80.0;
  static const double _tamanoBaseTextoMovil = 10.0;
  static const double _tamanoBaseTextoWeb = 10.5;
  static const double _tamanoBaseTextoDesktop = 10.5;
  static const double _tamanoMinimoTextoMovil = 8.5;
  static const double _tamanoMinimoTextoWeb = 9.0;
  static const double _tamanoMinimoTextoDesktop = 9.0;
  static const double _tamanoMaximoTextoMovil = 12.0;
  static const double _tamanoMaximoTextoWeb = 12.5;
  static const double _tamanoMaximoTextoDesktop = 12.0;

  late Stream<List<Map<String, dynamic>>> _trayectoriaStream;
  late Future<DatosGisOperativos> _datosGisFuture;
  Timer? _timerRefrescoUI;
  Timer? _timerAlertasSinDatos;

  final Map<String, List<_PuntoRastro>> _rastrosCrudos = {};
  final Map<String, Map<String, dynamic>> equiposInfo = {};
  final Map<String, ll.LatLng> _posicionAnterior = {};
  final Map<String, DateTime> _tiempoAnterior = {};
  final Map<String, double> _velocidades = {};
  final Map<String, double> _distanciasAcumuladas = {};
  final Map<String, ll.LatLng> _ultimaPosicion = {};
  final Map<String, DateTime> _ultimoTiempo = {};
  final Map<String, bool> _equipoActivo = {};
  final Map<String, DateTime?> _ultimoTiempoSupabase = {};
  final Map<String, _PuntoSospechosoSalto> _saltosPendientes = {};
  List<_AlertaSinDatos> _alertasSinDatos = [];
  Set<String> _volquetesAlertadosSinDatos = {};
  final Set<String> _alertasSinDatosOcultas = {};

  bool _cargandoInicial = true;
  bool _mostrandoDiagnostico = false;
  bool _mostrarAreasGis = true;
  bool _mostrarRutasGis = true;
  double _zoomActual = 15.0;
  Future<List<Map<String, dynamic>>>? _diagnosticoFuture;

  @override
  void initState() {
    super.initState();
    _trayectoriaStream = _crearTrayectoriaStream();
    _datosGisFuture = _crearDatosGisFuture();
    _cargarDatosIniciales();
    _timerRefrescoUI = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
    _timerAlertasSinDatos = Timer.periodic(_intervaloAlertaSinDatos, (_) {
      _verificarAlertasSinDatos();
    });
  }

  @override
  void didUpdateWidget(covariant PaginaStream oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.empresaFiltro == widget.empresaFiltro) return;

    setState(() {
      _cargandoInicial = true;
      _mostrandoDiagnostico = false;
      _diagnosticoFuture = null;
      _limpiarEstadoEnVivo();
      _trayectoriaStream = _crearTrayectoriaStream();
      _datosGisFuture = _crearDatosGisFuture();
    });
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _timerRefrescoUI?.cancel();
    _timerAlertasSinDatos?.cancel();
    _tarjetasController.dispose();
    super.dispose();
  }

  String get _empresaFiltroActual =>
      widget.empresaFiltro ?? RepositorioMonitoreo.empresaMonitoreoFija;

  Stream<List<Map<String, dynamic>>> _crearTrayectoriaStream() {
    return _repositorio.obtenerTrayectoriaStream(
      tipoEquipoControl: RepositorioMonitoreo.tipoEquipoSeeedWioTrackerL1,
      fkEmpresa: _empresaFiltroActual,
      fkSede: RepositorioMonitoreo.sedeMonitoreoFija,
    );
  }

  Future<DatosGisOperativos> _crearDatosGisFuture() {
    return _repositorioGis.obtenerDatosOperativos(
      fkEmpresa: _empresaFiltroActual,
      fkSede: RepositorioMonitoreo.sedeMonitoreoFija,
    );
  }

  void _limpiarEstadoEnVivo() {
    _rastrosCrudos.clear();
    equiposInfo.clear();
    _posicionAnterior.clear();
    _tiempoAnterior.clear();
    _velocidades.clear();
    _distanciasAcumuladas.clear();
    _ultimaPosicion.clear();
    _ultimoTiempo.clear();
    _equipoActivo.clear();
    _ultimoTiempoSupabase.clear();
    _saltosPendientes.clear();
    _alertasSinDatos = [];
    _volquetesAlertadosSinDatos = {};
    _alertasSinDatosOcultas.clear();
  }

  void _abrirDiagnostico() {
    setState(() {
      _mostrandoDiagnostico = true;
      _diagnosticoFuture = _repositorio.obtenerDiagnosticoStream(
        tipoEquipoControl: RepositorioMonitoreo.tipoEquipoSeeedWioTrackerL1,
        fkEmpresa: _empresaFiltroActual,
        fkSede: RepositorioMonitoreo.sedeMonitoreoFija,
      );
    });
  }

  void _cerrarDiagnostico() {
    setState(() {
      _mostrandoDiagnostico = false;
    });
  }

  Future<void> _cargarDatosIniciales() async {
    try {
      final equipos = await _repositorio.obtenerEquiposRaw(
        tipoEquipoControl: RepositorioMonitoreo.tipoEquipoSeeedWioTrackerL1,
        fkEmpresa: _empresaFiltroActual,
        fkSede: RepositorioMonitoreo.sedeMonitoreoFija,
      );
      final ultimasPosiciones = await _repositorio.obtenerUltimasPosiciones(
        tipoEquipoControl: RepositorioMonitoreo.tipoEquipoSeeedWioTrackerL1,
        fkEmpresa: _empresaFiltroActual,
        fkSede: RepositorioMonitoreo.sedeMonitoreoFija,
      );
      final ultimosTiemposSupabase = await _repositorio
          .obtenerUltimosTiemposPorEquipo(
            tipoEquipoControl: RepositorioMonitoreo.tipoEquipoSeeedWioTrackerL1,
            fkEmpresa: _empresaFiltroActual,
            fkSede: RepositorioMonitoreo.sedeMonitoreoFija,
          );

      if (!mounted) return;

      setState(() {
        for (final equipo in equipos) {
          final id = equipo['id_equipo_control'].toString();
          if (widget.equipoIdFiltro != null && widget.equipoIdFiltro != id) {
            continue;
          }
          equiposInfo[id] = equipo;
          _equipoActivo.putIfAbsent(id, () => false);
          _velocidades.putIfAbsent(id, () => 0.0);
          _distanciasAcumuladas.putIfAbsent(id, () => 0.0);
        }

        final ahora = DateTime.now();
        for (final pos in ultimasPosiciones) {
          _aplicarPosicion(pos, ahora, esInicial: true);
        }

        _ultimoTiempoSupabase
          ..clear()
          ..addAll(ultimosTiemposSupabase);
        for (final entry in ultimosTiemposSupabase.entries) {
          final tiempoActual = _ultimoTiempo[entry.key];
          final tiempoSupabase = entry.value;
          if (tiempoSupabase != null &&
              (tiempoActual == null || tiempoSupabase.isAfter(tiempoActual))) {
            _ultimoTiempo[entry.key] = tiempoSupabase;
          }
        }

        _cargandoInicial = false;
      });
      _verificarAlertasSinDatos();
    } catch (e) {
      debugPrint('Error cargando datos iniciales: $e');
      if (mounted) {
        setState(() {
          _cargandoInicial = false;
        });
      }
    }
  }

  bool _aplicarPosicion(
    Map<String, dynamic> punto,
    DateTime ahora, {
    bool esInicial = false,
  }) {
    final id = punto['fk_emisor'].toString();
    if (!equiposInfo.containsKey(id)) {
      equiposInfo[id] = {
        'id_equipo_control': punto['id_equipo_control'] ?? id,
        'codigo_equipo_control': punto['codigo_equipo_control'],
        'nombre': punto['nombre'],
        'fk_empresa': punto['fk_empresa'],
        'fk_sede': punto['fk_sede'],
        'tipo_equipo_control': punto['tipo_equipo_control'],
        'activo': punto['activo'] ?? true,
      };
      _equipoActivo.putIfAbsent(id, () => false);
      _velocidades.putIfAbsent(id, () => 0.0);
      _distanciasAcumuladas.putIfAbsent(id, () => 0.0);
    }

    if (equiposInfo[id]?['activo'] != true) return false;

    final lat = (punto['lat_grados'] as num?)?.toDouble() ?? 0.0;
    final lon = (punto['lon_grados'] as num?)?.toDouble() ?? 0.0;

    if (lat == 0.0 || lon == 0.0) return false;
    if (lat < -20 || lat > -10 || lon < -75 || lon > -65) return false;

    final tiempoActual = DateTime.parse(punto['tiempo']);
    final posActual = ll.LatLng(lat, lon);

    final ultimoRegistrado = _ultimoTiempo[id];
    if (ultimoRegistrado != null && !tiempoActual.isAfter(ultimoRegistrado)) {
      final segundos = ahora.difference(ultimoRegistrado).inSeconds.abs();
      _equipoActivo[id] = segundos <= 60;
      return false;
    }

    var cortarTramo = false;
    if (!esInicial) {
      final decision = _evaluarSaltoFuerte(
        id: id,
        posicion: posActual,
        tiempo: tiempoActual,
        ahora: ahora,
      );

      switch (decision) {
        case _DecisionSalto.aceptar:
          break;
        case _DecisionSalto.aceptarCortandoTramo:
          cortarTramo = true;
          break;
        case _DecisionSalto.esperar:
        case _DecisionSalto.descartar:
          return false;
      }
    }

    _registrarPosicionValida(
      id: id,
      posicion: posActual,
      tiempo: tiempoActual,
      ahora: ahora,
      esInicial: esInicial,
      cortarTramo: cortarTramo,
    );

    return true;
  }

  void _registrarPosicionValida({
    required String id,
    required ll.LatLng posicion,
    required DateTime tiempo,
    required DateTime ahora,
    required bool esInicial,
    required bool cortarTramo,
  }) {
    _saltosPendientes.remove(id);
    _ultimaPosicion[id] = posicion;
    _ultimoTiempo[id] = tiempo;
    _equipoActivo[id] = ahora.difference(tiempo).inSeconds.abs() <= 60;

    if (cortarTramo) {
      _velocidades[id] = 0.0;
      _rastrosCrudos[id] = [];
      _agregarPuntoRastro(id, posicion, tiempo, ahora);
      _posicionAnterior[id] = posicion;
      _tiempoAnterior[id] = tiempo;
      return;
    }

    if (!esInicial &&
        _posicionAnterior.containsKey(id) &&
        _tiempoAnterior.containsKey(id)) {
      final metrosTramo = _calcularDistanciaMetros(
        _posicionAnterior[id]!,
        posicion,
      );
      final segundos = tiempo
          .difference(_tiempoAnterior[id]!)
          .inSeconds
          .toDouble();

      if (metrosTramo > 2) {
        _distanciasAcumuladas[id] =
            (_distanciasAcumuladas[id] ?? 0) + (metrosTramo / 1000);

        if (segundos > 0) {
          _velocidades[id] = (metrosTramo / segundos) * 3.6;
        }

        _agregarPuntoRastro(id, posicion, tiempo, ahora);
      }
    } else {
      _agregarPuntoRastro(id, posicion, tiempo, ahora);
    }

    _posicionAnterior[id] = posicion;
    _tiempoAnterior[id] = tiempo;
  }

  _DecisionSalto _evaluarSaltoFuerte({
    required String id,
    required ll.LatLng posicion,
    required DateTime tiempo,
    required DateTime ahora,
  }) {
    final pendiente = _saltosPendientes[id];
    if (pendiente != null) {
      if (!tiempo.isAfter(pendiente.tiempo)) {
        return _DecisionSalto.descartar;
      }

      final confirmaSalto = _esContinuacionRazonable(
        desde: pendiente.posicion,
        tiempoDesde: pendiente.tiempo,
        hasta: posicion,
        tiempoHasta: tiempo,
      );
      final vuelveAlUltimoValido =
          _posicionAnterior[id] != null &&
          _tiempoAnterior[id] != null &&
          _esContinuacionRazonable(
            desde: _posicionAnterior[id]!,
            tiempoDesde: _tiempoAnterior[id]!,
            hasta: posicion,
            tiempoHasta: tiempo,
          );

      if (confirmaSalto) {
        _saltosPendientes.remove(id);
        return _DecisionSalto.aceptarCortandoTramo;
      }

      if (vuelveAlUltimoValido) {
        _saltosPendientes.remove(id);
        return _DecisionSalto.aceptar;
      }

      if (ahora.difference(pendiente.detectadoEn) >=
          _tiempoMaximoConfirmacionSalto) {
        _saltosPendientes.remove(id);
        return _DecisionSalto.aceptarCortandoTramo;
      }

      _saltosPendientes[id] = _PuntoSospechosoSalto(
        posicion: posicion,
        tiempo: tiempo,
        detectadoEn: ahora,
      );
      return _DecisionSalto.esperar;
    }

    final posicionAnterior = _posicionAnterior[id];
    final tiempoAnterior = _tiempoAnterior[id];
    if (posicionAnterior == null || tiempoAnterior == null) {
      return _DecisionSalto.aceptar;
    }

    if (!_esSaltoFuerte(
      desde: posicionAnterior,
      tiempoDesde: tiempoAnterior,
      hasta: posicion,
      tiempoHasta: tiempo,
    )) {
      return _DecisionSalto.aceptar;
    }

    _saltosPendientes[id] = _PuntoSospechosoSalto(
      posicion: posicion,
      tiempo: tiempo,
      detectadoEn: ahora,
    );
    return _DecisionSalto.esperar;
  }

  bool _esSaltoFuerte({
    required ll.LatLng desde,
    required DateTime tiempoDesde,
    required ll.LatLng hasta,
    required DateTime tiempoHasta,
  }) {
    final segundos = tiempoHasta.difference(tiempoDesde).inSeconds;
    if (segundos <= 0) return true;

    final distancia = _calcularDistanciaMetros(desde, hasta);
    final velocidadKmh = (distancia / segundos) * 3.6;
    final metrosMaximosPorVelocidad =
        (_velocidadMaximaRealistaKmh / 3.6) * segundos + _toleranciaSaltoMetros;

    final saltoPorDistanciaCorta =
        segundos <= _ventanaSaltoFuerte.inSeconds &&
        distancia > _distanciaSaltoFuerteMetros;
    final saltoPorVelocidad =
        velocidadKmh > _velocidadMaximaRealistaKmh &&
        distancia > metrosMaximosPorVelocidad;

    return saltoPorDistanciaCorta || saltoPorVelocidad;
  }

  bool _esContinuacionRazonable({
    required ll.LatLng desde,
    required DateTime tiempoDesde,
    required ll.LatLng hasta,
    required DateTime tiempoHasta,
  }) {
    final segundos = tiempoHasta.difference(tiempoDesde).inSeconds;
    if (segundos <= 0) return false;

    final distancia = _calcularDistanciaMetros(desde, hasta);
    if (distancia <= _radioConfirmacionSaltoMetros) return true;

    return !_esSaltoFuerte(
      desde: desde,
      tiempoDesde: tiempoDesde,
      hasta: hasta,
      tiempoHasta: tiempoHasta,
    );
  }

  void _verificarAlertasSinDatos({bool mostrarMensaje = true}) {
    if (!mounted || _cargandoInicial) return;

    final ahora = DateTime.now();
    final alertas = <_AlertaSinDatos>[];

    for (final entry in equiposInfo.entries) {
      final id = entry.key;
      final equipo = entry.value;
      if (equipo['activo'] != true || !_esVolquete(equipo)) continue;

      final ultimoTiempo = _resolverUltimoTiempoEquipo(id);
      final tiempoSinDatos = ultimoTiempo == null
          ? _umbralAlertaSinDatos
          : ahora.difference(ultimoTiempo);
      final tiempoNormalizado = tiempoSinDatos.isNegative
          ? Duration.zero
          : tiempoSinDatos;

      if (ultimoTiempo == null || tiempoNormalizado >= _umbralAlertaSinDatos) {
        alertas.add(
          _AlertaSinDatos(
            id: id,
            nombre: _obtenerEtiquetaEquipo(id),
            ultimoDato: ultimoTiempo,
            tiempoSinDatos: tiempoNormalizado,
          ),
        );
      }
    }

    alertas.sort((a, b) => a.nombre.compareTo(b.nombre));
    final idsActuales = alertas.map((alerta) => alerta.id).toSet();
    final idsNuevos = idsActuales.difference(_volquetesAlertadosSinDatos);

    setState(() {
      _alertasSinDatos = alertas;
      _volquetesAlertadosSinDatos = idsActuales;
      _alertasSinDatosOcultas.removeWhere((id) => !idsActuales.contains(id));
    });

    if (!mostrarMensaje || idsNuevos.isEmpty) return;

    final nuevasAlertas = alertas
        .where((alerta) => idsNuevos.contains(alerta.id))
        .toList();
    final principal = nuevasAlertas.first;
    final tiempoPrincipal = _formatearDuracionSinDatos(
      principal.tiempoSinDatos,
      sinRegistro: principal.ultimoDato == null,
    );
    final extra = nuevasAlertas.length > 1
        ? ' y ${nuevasAlertas.length - 1} volquetes mas'
        : '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent.shade700,
        duration: const Duration(seconds: 8),
        content: Text(
          'Alerta: ${principal.nombre} sin datos $tiempoPrincipal$extra.',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  DateTime? _resolverUltimoTiempoEquipo(String id) {
    final tiempoEnVivo = _ultimoTiempo[id];
    final tiempoSupabase = _ultimoTiempoSupabase[id];

    if (tiempoEnVivo == null) return tiempoSupabase;
    if (tiempoSupabase == null) return tiempoEnVivo;

    return tiempoSupabase.isAfter(tiempoEnVivo) ? tiempoSupabase : tiempoEnVivo;
  }

  bool _esVolquete(Map<String, dynamic> equipo) {
    final descriptor =
        [
              equipo['nombre'],
              equipo['codigo_equipo_control'],
              equipo['tipo_equipo_control'],
              equipo['ubicacion'],
              equipo['observaciones'],
            ]
            .whereType<Object>()
            .map((valor) => valor.toString().toUpperCase())
            .join(' ');

    return descriptor.contains('VOLQUETE');
  }

  void _agregarPuntoRastro(
    String id,
    ll.LatLng posicion,
    DateTime tiempo,
    DateTime ahora,
  ) {
    final rastro = _rastrosCrudos.putIfAbsent(id, () => []);
    final yaExisteTiempo = rastro.isNotEmpty && rastro.last.tiempo == tiempo;
    if (!yaExisteTiempo) {
      rastro.add(_PuntoRastro(posicion: posicion, tiempo: tiempo));
    }
    _recortarRastro(id, ahora);
  }

  void _recortarRastros(DateTime ahora) {
    for (final id in _rastrosCrudos.keys.toList()) {
      _recortarRastro(id, ahora);
    }
  }

  void _recortarRastro(String id, DateTime ahora) {
    final rastro = _rastrosCrudos[id];
    if (rastro == null) return;

    final limite = ahora.subtract(_duracionColaRastro);
    rastro.removeWhere((punto) => punto.tiempo.isBefore(limite));

    if (rastro.length > _maxPuntosColaRastro) {
      _rastrosCrudos[id] = rastro.sublist(rastro.length - _maxPuntosColaRastro);
    }
  }

  double _calcularDistanciaMetros(ll.LatLng p1, ll.LatLng p2) {
    const double p = 0.017453292519943295;
    final double a =
        0.5 -
        math.cos((p2.latitude - p1.latitude) * p) / 2 +
        math.cos(p1.latitude * p) *
            math.cos(p2.latitude * p) *
            (1 - math.cos((p2.longitude - p1.longitude) * p)) /
            2;

    return 12742 * math.asin(math.sqrt(a)) * 1000;
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoInicial) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.orange),
              const SizedBox(height: 20),
              Text(
                'Cargando posiciones...',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;
        final cardHeight = isMobile ? 120.0 : 100.0;
        final alturaMinimaMapa = isMobile ? 320.0 : 420.0;

        return Scaffold(
          backgroundColor: Colors.black,
          body: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _trayectoriaStream,
            builder: (context, snapshot) {
              final ahora = DateTime.now();

              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                for (final punto in snapshot.data!) {
                  _aplicarPosicion(punto, ahora);
                }
              }

              for (final id in equiposInfo.keys) {
                final tiempo = _ultimoTiempo[id];
                if (tiempo == null) {
                  _equipoActivo[id] = false;
                } else {
                  _equipoActivo[id] =
                      ahora.difference(tiempo).inSeconds.abs() <= 60;
                }
              }
              _recortarRastros(ahora);

              final marcadoresVisibles = <String, Marker>{};
              for (final entry in _ultimaPosicion.entries) {
                final id = entry.key;
                final posicion = entry.value;
                final estaActivo = _equipoActivo[id] ?? false;
                final color = estaActivo ? Colors.greenAccent : Colors.grey;

                marcadoresVisibles[id] = Marker(
                  key: ValueKey('live_$id'),
                  point: posicion,
                  width: _anchoMarcador(isMobile),
                  height: _altoMarcador(isMobile),
                  child: _buildIconoOperador(
                    id,
                    color,
                    isMobile: isMobile,
                    zoom: _zoomActual,
                  ),
                );
              }

              final polylines = <Polyline>[];
              for (final id in _rastrosCrudos.keys) {
                if ((_equipoActivo[id] ?? false) != true) continue;
                final rastro = _rastrosCrudos[id]!;
                if (rastro.length < 2) continue;
                polylines.addAll(_construirTramosRastro(rastro));
              }

              final idsTarjetas = equiposInfo.keys.toList()
                ..sort(
                  (a, b) => _obtenerEtiquetaEquipo(
                    a,
                  ).compareTo(_obtenerEtiquetaEquipo(b)),
                );

              final mapa = FutureBuilder<DatosGisOperativos>(
                future: _datosGisFuture,
                builder: (context, gisSnapshot) {
                  final capasGis = construirCapasGisMapa(
                    gisSnapshot.data ?? DatosGisOperativos.vacio,
                    mostrarAreas: _mostrarAreasGis,
                    mostrarRutas: _mostrarRutasGis,
                  );

                  return Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _ultimaPosicion.isNotEmpty
                              ? _ultimaPosicion.values.first
                              : puntoTrabajoLatLng,
                          initialZoom: isMobile ? 14.5 : 15,
                          onPositionChanged: (position, hasGesture) {
                            final nuevoZoom = position.zoom;
                            if ((nuevoZoom - _zoomActual).abs() < 0.01) {
                              return;
                            }
                            setState(() {
                              _zoomActual = nuevoZoom;
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                          ),
                          if (capasGis.poligonos.isNotEmpty)
                            PolygonLayer(polygons: capasGis.poligonos),
                          if (capasGis.rutas.isNotEmpty)
                            PolylineLayer(polylines: capasGis.rutas),
                          PolylineLayer(polylines: polylines),
                          MarkerLayer(
                            markers: [
                              ...capasGis.marcadores,
                              ...marcadoresVisibles.values,
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.equipoIdFiltro != null) ...[
                              _buildFloatingBackButton(),
                              const SizedBox(width: 10),
                            ],
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.equipoIdFiltro != null)
                                    Text(
                                      widget.nombreEquipoFiltro
                                                  ?.trim()
                                                  .isNotEmpty ==
                                              true
                                          ? 'Unidad: ${widget.nombreEquipoFiltro}'
                                          : 'Unidad filtrada',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  if (widget.equipoIdFiltro != null)
                                    const SizedBox(height: 6),
                                  _leyendaItem(
                                    Colors.orange.withOpacity(0.58),
                                    'GPS en vivo',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: ElevatedButton.icon(
                          onPressed: _abrirDiagnostico,
                          icon: const Icon(Icons.analytics, size: 18),
                          label: Text(isMobile ? 'Diag.' : 'Diagnostico'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.8),
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 10 : 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: isMobile ? 58 : 60,
                        right: 10,
                        child: _buildSelectorCapasGis(isMobile: isMobile),
                      ),
                      if (_alertasSinDatos
                          .where(
                            (alerta) =>
                                !_alertasSinDatosOcultas.contains(alerta.id),
                          )
                          .isNotEmpty)
                        Positioned(
                          top: isMobile ? 112 : 116,
                          left: isMobile ? 10 : 16,
                          right: isMobile ? 10 : null,
                          child: _buildBannerAlertasSinDatos(
                            isMobile: isMobile,
                          ),
                        ),
                      if (_mostrandoDiagnostico)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.65),
                            alignment: Alignment.center,
                            child: _buildPanelDiagnostico(isMobile: isMobile),
                          ),
                        ),
                    ],
                  );
                },
              );

              return Column(
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: alturaMinimaMapa),
                      child: mapa,
                    ),
                  ),
                  SizedBox(
                    height: cardHeight + (isMobile ? 12 : 20),
                    child: idsTarjetas.isEmpty
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'No hay equipos disponibles',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : Scrollbar(
                            controller: _tarjetasController,
                            thumbVisibility: true,
                            trackVisibility: !isMobile,
                            interactive: true,
                            child: ListView(
                              controller: _tarjetasController,
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.fromLTRB(
                                isMobile ? 10 : 15,
                                isMobile ? 4 : 8,
                                isMobile ? 10 : 15,
                                isMobile ? 8 : 12,
                              ),
                              children: idsTarjetas
                                  .map(
                                    (id) =>
                                        _buildCardKPI(id, isMobile: isMobile),
                                  )
                                  .toList(),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBannerAlertasSinDatos({required bool isMobile}) {
    final visibles = _alertasSinDatos
        .where((alerta) => !_alertasSinDatosOcultas.contains(alerta.id))
        .toList();
    if (visibles.isEmpty) return const SizedBox.shrink();

    final ancho = isMobile ? double.infinity : 380.0;
    final resumen = visibles
        .take(isMobile ? 2 : 3)
        .map((alerta) {
          final tiempo = _formatearDuracionSinDatos(
            alerta.tiempoSinDatos,
            sinRegistro: alerta.ultimoDato == null,
          );
          final ultimoDato = _formatearUltimoDato(alerta.ultimoDato);
          return '${alerta.nombre}: $tiempo\nUltimo dato: $ultimoDato';
        })
        .join('\n');
    final extra = visibles.length > (isMobile ? 2 : 3)
        ? '\n+${visibles.length - (isMobile ? 2 : 3)} volquetes mas'
        : '';

    return Container(
      width: ancho,
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF180909).withOpacity(0.94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent, width: 1.4),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Volquete sin datos',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$resumen$extra',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Ocultar alerta actual',
            onPressed: () {
              setState(() {
                _alertasSinDatosOcultas.addAll(
                  visibles.map((alerta) => alerta.id),
                );
              });
            },
            icon: const Icon(Icons.close, color: Colors.white70, size: 18),
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  String _formatearDuracionSinDatos(
    Duration duracion, {
    required bool sinRegistro,
  }) {
    if (sinRegistro) return 'sin registro en Supabase';

    final dias = duracion.inDays;
    final horas = duracion.inHours % 24;
    final minutos = duracion.inMinutes % 60;

    if (dias > 0) {
      final textoHoras = horas > 0 ? ' $horas h' : '';
      return 'hace $dias dia${dias == 1 ? '' : 's'}$textoHoras';
    }

    if (duracion.inHours > 0) {
      final textoMinutos = minutos > 0 ? ' $minutos min' : '';
      return 'hace ${duracion.inHours} h$textoMinutos';
    }

    return 'hace ${duracion.inMinutes.clamp(5, 59)} min';
  }

  String _formatearUltimoDato(DateTime? fecha) {
    if (fecha == null) return 'no encontrado';

    String dosDigitos(int valor) => valor.toString().padLeft(2, '0');

    final local = fecha.toLocal();
    return '${dosDigitos(local.day)}/${dosDigitos(local.month)}/${local.year} '
        '${dosDigitos(local.hour)}:${dosDigitos(local.minute)}';
  }

  List<Polyline> _construirTramosRastro(List<_PuntoRastro> rastro) {
    final tramos = <Polyline>[];
    final puntos = [...rastro]..sort((a, b) => a.tiempo.compareTo(b.tiempo));

    for (var i = 1; i < puntos.length; i++) {
      final anterior = puntos[i - 1];
      final actual = puntos[i];
      final diferenciaTiempo = actual.tiempo.difference(anterior.tiempo).abs();
      if (diferenciaTiempo > _intervaloMaximoTramoRastro) continue;

      final distancia = _calcularDistanciaMetros(
        anterior.posicion,
        actual.posicion,
      );
      if (distancia > _distanciaMaximaTramoRastroMetros) continue;

      tramos.add(
        Polyline(
          points: [anterior.posicion, actual.posicion],
          color: Colors.orange.withOpacity(0.58),
          strokeWidth: 3,
        ),
      );
    }

    return tramos;
  }

  Widget _leyendaItem(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 20, height: 3, color: color),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }

  Widget _buildSelectorCapasGis({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.78),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBotonCapaGis(
            texto: 'Areas',
            activo: _mostrarAreasGis,
            color: Colors.orangeAccent,
            onTap: () => setState(() => _mostrarAreasGis = !_mostrarAreasGis),
          ),
          const SizedBox(width: 6),
          _buildBotonCapaGis(
            texto: 'Rutas',
            activo: _mostrarRutasGis,
            color: Colors.cyanAccent,
            onTap: () => setState(() => _mostrarRutasGis = !_mostrarRutasGis),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonCapaGis({
    required String texto,
    required bool activo,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: activo ? color.withOpacity(0.18) : Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: activo ? color : Colors.white30),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: activo ? color : Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBackButton() {
    return Material(
      color: Colors.black.withOpacity(0.82),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.75)),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.orange),
        ),
      ),
    );
  }

  Widget _buildCardKPI(String id, {bool isMobile = false}) {
    final nombre = _obtenerEtiquetaEquipo(id);
    final vel = _velocidades[id] ?? 0.0;
    final dist = _distanciasAcumuladas[id] ?? 0.0;
    final activo = _equipoActivo[id] ?? false;

    return Container(
      width: isMobile ? 180 : 170,
      margin: const EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activo
              ? (vel > 40 ? Colors.redAccent : Colors.green)
              : Colors.grey,
          width: 2,
        ),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nombre,
                  style: TextStyle(
                    color: activo ? Colors.orange : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 13 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                activo ? Icons.circle : Icons.circle_outlined,
                color: activo ? Colors.green : Colors.grey,
                size: 10,
              ),
            ],
          ),
          const SizedBox(height: 6),
          _datoFila(
            Icons.speed,
            '${vel.toStringAsFixed(1)} km/h',
            activo ? Colors.greenAccent : Colors.grey,
          ),
          _datoFila(
            Icons.route,
            '${dist.toStringAsFixed(2)} km rec.',
            activo ? Colors.cyanAccent : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _datoFila(IconData icono, String texto, Color color) {
    return Row(
      children: [
        Icon(icono, size: 14, color: color),
        const SizedBox(width: 6),
        Text(texto, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _buildIconoOperador(
    String id,
    Color color, {
    bool isMobile = false,
    required double zoom,
  }) {
    final tamanoIcono = _tamanoIconoMarcador(isMobile: isMobile, zoom: zoom);
    final tamanoTexto = _tamanoTextoMarcador(isMobile: isMobile, zoom: zoom);
    final iconoEquipo = TrackCustomIcons.iconoPorEquipo(
      nombre: equiposInfo[id]?['nombre']?.toString(),
      codigo: equiposInfo[id]?['codigo_equipo_control']?.toString(),
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 1),
          ),
          child: Text(
            _obtenerEtiquetaEquipo(id),
            style: TextStyle(
              color: Colors.white,
              fontSize: tamanoTexto,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Icon(iconoEquipo, color: color, size: tamanoIcono),
      ],
    );
  }

  double _tamanoIconoMarcador({required bool isMobile, required double zoom}) {
    if (isMobile) {
      return _tamanoProporcional(
        zoom: zoom,
        zoomReferencia: _zoomReferenciaMovil,
        base: _tamanoBaseIconoMovil,
        minimo: _tamanoMinimoIconoMovil,
        maximo: _tamanoMaximoIconoMovil,
        factorEscala: 4.0,
      );
    }

    if (kIsWeb) {
      return _tamanoProporcional(
        zoom: zoom,
        zoomReferencia: _zoomReferenciaWeb,
        base: _tamanoBaseIconoWeb,
        minimo: _tamanoMinimoIconoWeb,
        maximo: _tamanoMaximoIconoWeb,
        factorEscala: 4.5,
      );
    }

    return _tamanoProporcional(
      zoom: zoom,
      zoomReferencia: _zoomReferenciaWeb,
      base: _tamanoBaseIconoDesktop,
      minimo: _tamanoMinimoIconoDesktop,
      maximo: _tamanoMaximoIconoDesktop,
      factorEscala: 4.2,
    );
  }

  double _tamanoTextoMarcador({required bool isMobile, required double zoom}) {
    if (isMobile) {
      return _tamanoProporcional(
        zoom: zoom,
        zoomReferencia: _zoomReferenciaMovil,
        base: _tamanoBaseTextoMovil,
        minimo: _tamanoMinimoTextoMovil,
        maximo: _tamanoMaximoTextoMovil,
        factorEscala: 0.45,
      );
    }

    if (kIsWeb) {
      return _tamanoProporcional(
        zoom: zoom,
        zoomReferencia: _zoomReferenciaWeb,
        base: _tamanoBaseTextoWeb,
        minimo: _tamanoMinimoTextoWeb,
        maximo: _tamanoMaximoTextoWeb,
        factorEscala: 0.5,
      );
    }

    return _tamanoProporcional(
      zoom: zoom,
      zoomReferencia: _zoomReferenciaWeb,
      base: _tamanoBaseTextoDesktop,
      minimo: _tamanoMinimoTextoDesktop,
      maximo: _tamanoMaximoTextoDesktop,
      factorEscala: 0.48,
    );
  }

  double _tamanoProporcional({
    required double zoom,
    required double zoomReferencia,
    required double base,
    required double minimo,
    required double maximo,
    required double factorEscala,
  }) {
    final tamano = base + ((zoom - zoomReferencia) * factorEscala);
    return tamano.clamp(minimo, maximo);
  }

  double _anchoMarcador(bool isMobile) {
    final icono = _tamanoIconoMarcador(isMobile: isMobile, zoom: _zoomActual);
    return isMobile ? icono * 1.9 : icono * 2.0;
  }

  double _altoMarcador(bool isMobile) {
    final icono = _tamanoIconoMarcador(isMobile: isMobile, zoom: _zoomActual);
    return isMobile ? icono * 1.75 : icono * 1.8;
  }

  String _obtenerEtiquetaEquipo(String id) {
    final nombre = equiposInfo[id]?['nombre']?.toString().trim() ?? '';
    if (nombre.isNotEmpty) return nombre;

    final codigo =
        equiposInfo[id]?['codigo_equipo_control']?.toString().trim() ?? '';
    if (codigo.isNotEmpty) return codigo;

    return 'Unidad';
  }

  Widget _buildPanelDiagnostico({bool isMobile = false}) {
    return Container(
      width: isMobile ? double.infinity : 820,
      constraints: BoxConstraints(
        maxWidth: isMobile ? 520 : 820,
        maxHeight: isMobile ? 560 : 620,
      ),
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Diagnostico de Unidades',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _diagnosticoFuture = _repositorio.obtenerDiagnosticoStream(
                      tipoEquipoControl:
                          RepositorioMonitoreo.tipoEquipoSeeedWioTrackerL1,
                      fkEmpresa: _empresaFiltroActual,
                      fkSede: RepositorioMonitoreo.sedeMonitoreoFija,
                    );
                  });
                },
                icon: const Icon(Icons.refresh, color: Colors.orange),
              ),
              IconButton(
                onPressed: _cerrarDiagnostico,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Estado por unidad: ok, sin dato, sin match, coordenada invalida o sin codigo.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _diagnosticoFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  );
                }

                final items = snapshot.data!;
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final nombre =
                        (item['nombre']?.toString().trim().isNotEmpty ?? false)
                        ? item['nombre'].toString()
                        : item['codigo_equipo_control']?.toString() ?? 'Unidad';
                    final estado = item['estado']?.toString() ?? 'desconocido';
                    final detalle = item['detalle']?.toString() ?? '';
                    final color = _colorEstadoDiagnostico(estado);
                    final iconoEquipo = TrackCustomIcons.iconoPorEquipo(
                      nombre: item['nombre']?.toString(),
                      codigo: item['codigo_equipo_control']?.toString(),
                    );

                    return ListTile(
                      leading: Icon(iconoEquipo, color: color),
                      title: Text(
                        nombre,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${item['codigo_equipo_control'] ?? 'Sin codigo'}\n$detalle',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color),
                        ),
                        child: Text(
                          estado,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      isThreeLine: true,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _colorEstadoDiagnostico(String estado) {
    switch (estado) {
      case 'ok':
        return Colors.greenAccent;
      case 'sin_dato_reciente':
        return Colors.grey;
      case 'sin_dato':
        return Colors.orangeAccent;
      case 'sin_match':
        return Colors.redAccent;
      case 'coordenada_invalida':
        return Colors.deepOrangeAccent;
      case 'sin_codigo':
        return Colors.amber;
      default:
        return Colors.white70;
    }
  }
}

class _PuntoRastro {
  const _PuntoRastro({required this.posicion, required this.tiempo});

  final ll.LatLng posicion;
  final DateTime tiempo;
}

class _PuntoSospechosoSalto {
  const _PuntoSospechosoSalto({
    required this.posicion,
    required this.tiempo,
    required this.detectadoEn,
  });

  final ll.LatLng posicion;
  final DateTime tiempo;
  final DateTime detectadoEn;
}

enum _DecisionSalto { aceptar, esperar, aceptarCortandoTramo, descartar }

class _AlertaSinDatos {
  const _AlertaSinDatos({
    required this.id,
    required this.nombre,
    required this.ultimoDato,
    required this.tiempoSinDatos,
  });

  final String id;
  final String nombre;
  final DateTime? ultimoDato;
  final Duration tiempoSinDatos;
}
