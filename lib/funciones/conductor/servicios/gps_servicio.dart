import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:trackmape_sup/funciones/conductor/datos/repositorio_conductor.dart';
import 'package:trackmape_sup/funciones/conductor/datos/database_local.dart';

/// ============================================
/// 🚗 GPS SERVICIO - CON MODO OFFLINE
/// ============================================
/// Envía GPS cada 5 segundos a Supabase.
/// Si falla la conexión, guarda en SQLite y
/// sincroniza cuando vuelve internet.
///
class GpsServicio {

  final RepositorioConductor _repo = RepositorioConductor();
  final DatabaseLocal _dbLocal = DatabaseLocal.instance;

  Timer? _timer;
  Timer? _timerSincronizacion;
  bool _enviando = false;
  bool _sincronizando = false;

  // ============================================
  // 🌐 ESTADO DE CONECTIVIDAD
  // ============================================
  bool _tieneInternet = true;
  String tipoConexion = "Verificando...";
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // ============================================
  // 📊 ESTADÍSTICAS PARA UI
  // ============================================
  int enviosExitosos = 0;      // Enviados a Supabase
  int guardadosLocal = 0;       // Guardados en SQLite
  int enviosFallidos = 0;       // Fallaron totalmente
  int pendientesSincronizar = 0;
  String ultimoError = "";
  String ultimaUbicacion = "";
  DateTime? ultimoEnvioExitoso;

  // Callback para notificar cambios a la UI
  Function(String mensaje, bool esError)? onEstadoCambiado;

  // ============================================
  // ⏱️ CONFIGURACIÓN
  // ============================================
  static const int intervaloGpsSegundos = 5;
  static const int intervaloSincronizacionSegundos = 30;

  /// Inicia el envío periódico de GPS
  Future<void> iniciar(String idDispositivo) async {

    debugPrint("🚀 GPS Servicio: Iniciando para $idDispositivo");

    // Cancelar timers anteriores
    _timer?.cancel();
    _timerSincronizacion?.cancel();
    _connectivitySubscription?.cancel();

    // Resetear estadísticas
    enviosExitosos = 0;
    guardadosLocal = 0;
    enviosFallidos = 0;
    ultimoError = "";

    // Verificar conectividad inicial
    final connectivityResult = await Connectivity().checkConnectivity();
    _actualizarEstadoConexion(connectivityResult);
    debugPrint("🌐 Conectividad inicial: $_tieneInternet ($tipoConexion)");

    // Escuchar cambios de conectividad
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      _actualizarEstadoConexion(results);
    });

    // Obtener pendientes actuales
    pendientesSincronizar = await _dbLocal.contarPendientes();
    debugPrint("📊 Pendientes de sincronizar: $pendientesSincronizar");

    // Enviar primera posición
    await _enviarPosicionActual(idDispositivo);

    // Timer para GPS cada 5 segundos
    _timer = Timer.periodic(Duration(seconds: intervaloGpsSegundos), (timer) async {
      await _enviarPosicionActual(idDispositivo);
    });

    // Timer para sincronización cada 30 segundos
    _timerSincronizacion = Timer.periodic(Duration(seconds: intervaloSincronizacionSegundos), (timer) async {
      await _sincronizarPendientes();
    });

    debugPrint("✅ GPS Servicio: Timers iniciados");
  }

  void _actualizarEstadoConexion(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      _tieneInternet = true;
      tipoConexion = "WiFi";
    } else if (results.contains(ConnectivityResult.mobile)) {
      _tieneInternet = true;
      tipoConexion = "Datos";
    } else if (results.contains(ConnectivityResult.ethernet)) {
      _tieneInternet = true;
      tipoConexion = "Ethernet";
    } else {
      _tieneInternet = false;
      tipoConexion = "Sin conexión";
    }

    // Si volvió internet, intentar sincronizar
    if (_tieneInternet && pendientesSincronizar > 0) {
      _sincronizarPendientes();
    }

    _notificar("", false);
  }

  /// Obtiene y envía la posición actual
  Future<void> _enviarPosicionActual(String idDispositivo) async {

    if (_enviando) {
      debugPrint("⏳ GPS: Envío en progreso, saltando...");
      return;
    }

    _enviando = true;

    try {
      debugPrint("📍 GPS: Obteniendo ubicación...");

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      ultimaUbicacion = "Lat: ${pos.latitude.toStringAsFixed(6)}, Lon: ${pos.longitude.toStringAsFixed(6)}";
      debugPrint("📍 GPS: $ultimaUbicacion");

      // Validar coordenadas
      if (pos.latitude == 0.0 || pos.longitude == 0.0) {
        debugPrint("⚠️ GPS: Coordenadas inválidas");
        ultimoError = "Coordenadas inválidas";
        _notificar("Coordenadas inválidas", true);
        _enviando = false;
        return;
      }

      // ============================================
      // 🌐 INTENTAR ENVIAR A SUPABASE
      // ============================================
      if (_tieneInternet) {
        await _enviarASupabase(idDispositivo, pos);
      } else {
        // Sin internet → Guardar en SQLite
        await _guardarEnLocal(idDispositivo, pos);
      }

    } on TimeoutException {
      enviosFallidos++;
      ultimoError = "Timeout GPS";
      debugPrint("⏱️ GPS: $ultimoError");
      _notificar(ultimoError, true);
    } on LocationServiceDisabledException {
      enviosFallidos++;
      ultimoError = "GPS desactivado";
      debugPrint("❌ GPS: $ultimoError");
      _notificar(ultimoError, true);
    } catch (e) {
      enviosFallidos++;
      ultimoError = e.toString();
      debugPrint("❌ GPS Error: $ultimoError");
      _notificar("Error: $ultimoError", true);
    } finally {
      _enviando = false;
    }
  }

  /// Enviar posición a Supabase
  Future<void> _enviarASupabase(String idDispositivo, Position pos) async {
    debugPrint("📤 Enviando a Supabase...");

    final resultado = await _repo.enviarPosicionConDetalle(
      idDispositivo: idDispositivo,
      lat: pos.latitude,
      lon: pos.longitude,
      altitud: pos.altitude,
    );

    if (resultado['exito'] == true) {
      enviosExitosos++;
      ultimoEnvioExitoso = DateTime.now();
      ultimoError = "";
      debugPrint("✅ Supabase: Envío #$enviosExitosos exitoso");
      _notificar("☁️ Enviado", false);
    } else {
      // Falló Supabase → Guardar en SQLite como respaldo
      final errorMsg = resultado['mensaje'] ?? 'Error desconocido';
      ultimoError = errorMsg;
      debugPrint("⚠️ Supabase falló: $errorMsg → Guardando local...");
      await _guardarEnLocal(idDispositivo, pos);
    }
  }

  /// Guardar posición en SQLite
  Future<void> _guardarEnLocal(String idDispositivo, Position pos) async {
    debugPrint("💾 Guardando en SQLite...");

    try {
      await _dbLocal.guardarPosicionLocal(
        fkEmisor: idDispositivo,
        lat: pos.latitude,
        lon: pos.longitude,
        altitud: pos.altitude,
      );

      guardadosLocal++;
      pendientesSincronizar = await _dbLocal.contarPendientes();
      debugPrint("💾 SQLite: Guardado #$guardadosLocal (pendientes: $pendientesSincronizar)");
      _notificar("💾 Guardado local", false);

    } catch (e) {
      enviosFallidos++;
      ultimoError = "Error SQLite: $e";
      debugPrint("❌ SQLite Error: $ultimoError");
      _notificar(ultimoError, true);
    }
  }

  /// Sincronizar posiciones pendientes con Supabase
  Future<void> _sincronizarPendientes() async {
    if (_sincronizando || !_tieneInternet) return;

    _sincronizando = true;

    try {
      final pendientes = await _dbLocal.obtenerPendientes(limite: 20);

      if (pendientes.isEmpty) {
        _sincronizando = false;
        return;
      }

      debugPrint("🔄 Sincronizando ${pendientes.length} posiciones pendientes...");

      int sincronizados = 0;

      for (var pos in pendientes) {
        final resultado = await _repo.enviarPosicionConDetalle(
          idDispositivo: pos['fk_emisor'],
          lat: pos['lat_grados'],
          lon: pos['lon_grados'],
          altitud: pos['alt_msnm']?.toDouble(),
        );

        if (resultado['exito'] == true) {
          await _dbLocal.marcarSincronizado(pos['id']);
          sincronizados++;
        } else {
          await _dbLocal.incrementarIntentos(pos['id']);
        }

        // Pequeña pausa para no saturar
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Actualizar contadores
      pendientesSincronizar = await _dbLocal.contarPendientes();
      enviosExitosos += sincronizados;

      if (sincronizados > 0) {
        debugPrint("✅ Sincronizados: $sincronizados (pendientes: $pendientesSincronizar)");
        _notificar("☁️ Sincronizados: $sincronizados", false);

        // Limpiar registros ya sincronizados
        await _dbLocal.limpiarSincronizados();
      }

    } catch (e) {
      debugPrint("❌ Error sincronizando: $e");
    } finally {
      _sincronizando = false;
    }
  }

  void _notificar(String mensaje, bool esError) {
    onEstadoCambiado?.call(mensaje, esError);
  }

  /// Detiene el envío de GPS
  void detener() {
    _timer?.cancel();
    _timer = null;
    _timerSincronizacion?.cancel();
    _timerSincronizacion = null;
    _connectivitySubscription?.cancel();
    _enviando = false;
    _sincronizando = false;
    debugPrint("🛑 GPS Servicio: Detenido");
  }

  /// Verifica si el GPS está activo
  bool get estaActivo => _timer != null && _timer!.isActive;
  bool get tieneInternet => _tieneInternet;

  /// Forzar sincronización manual
  Future<void> forzarSincronizacion() async {
    await _sincronizarPendientes();
  }

  /// Resumen de estadísticas
  String get resumen => "☁️$enviosExitosos 💾$guardadosLocal ❌$enviosFallidos";
}