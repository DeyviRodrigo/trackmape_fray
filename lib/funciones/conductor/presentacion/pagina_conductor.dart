import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trackmape_sup/funciones/conductor/datos/repositorio_conductor.dart';
import 'package:trackmape_sup/funciones/conductor/servicios/gps_servicio.dart';
import 'package:trackmape_sup/funciones/conductor/servicios/identificador_dispositivo.dart';

/// ============================================
/// PÁGINA CONDUCTOR - NUEVA ESTRUCTURA
/// ============================================
/// Adaptado para:
/// - Selección de EMPRESA obligatoria
/// - Selección de SEDE opcional (filtrada por empresa)
/// - UUID auto-generado para id_equipo_control
/// - id_equipo_fabrica para identificar el celular
///
class PaginaConductor extends StatefulWidget {
  const PaginaConductor({super.key});

  @override
  State<PaginaConductor> createState() => _PaginaConductorState();
}

class _PaginaConductorState extends State<PaginaConductor> with TickerProviderStateMixin {

  final RepositorioConductor _repo = RepositorioConductor();
  final GpsServicio _gps = GpsServicio();

  // IDs del dispositivo
  String? idFabrica;        // ID del celular (Android ID)
  String? idEquipo;         // UUID del equipo en Supabase
  String? errorInicial;

  // Estados
  bool cargando = true;
  bool registrando = false;
  bool registrado = false;
  bool gpsActivo = false;

  // Datos para dropdowns
  List<Map<String, dynamic>> empresas = [];
  List<Map<String, dynamic>> sedes = [];
  String? empresaSeleccionada;
  String? sedeSeleccionada;

  // Controllers
  final TextEditingController codigoCtrl = TextEditingController();
  final TextEditingController nombreCtrl = TextEditingController();
  
  // Animaciones
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _waveController;
  
  Timer? _timerUI;

  @override
  void initState() {
    super.initState();
    _inicializar();
    _iniciarAnimaciones();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _timerUI?.cancel();
    _gps.detener();
    super.dispose();
  }
  
  void _iniciarAnimaciones() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  Future<void> _inicializar() async {
    await _cargarEmpresas();
    await _verificarDispositivo();
  }

  Future<void> _cargarEmpresas() async {
    try {
      final listaEmpresas = await _repo.obtenerEmpresas();
      if (mounted) {
        setState(() {
          empresas = listaEmpresas;
        });
      }
    } catch (e) {
      debugPrint("❌ Error cargando empresas: $e");
    }
  }

  Future<void> _cargarSedesPorEmpresa(String idEmpresa) async {
    try {
      final listaSedes = await _repo.obtenerSedesPorEmpresa(idEmpresa);
      if (mounted) {
        setState(() {
          sedes = listaSedes;
          sedeSeleccionada = null; // Reset sede al cambiar empresa
        });
      }
    } catch (e) {
      debugPrint("❌ Error cargando sedes: $e");
    }
  }

  Future<void> _verificarDispositivo() async {
    try {
      final id = await IdentificadorDispositivo.obtenerId();
      idFabrica = id;
      
      // Buscar si ya está registrado
      final existe = await _repo.buscarDispositivo(id);
      if (existe != null) {
        registrado = true;
        idEquipo = existe['id_equipo_control']?.toString();
      }
    } catch (e) {
      errorInicial = e.toString();
    }
    if (mounted) setState(() => cargando = false);
  }

  Future<void> _registrar() async {
    if (empresaSeleccionada == null || 
        codigoCtrl.text.trim().isEmpty || 
        nombreCtrl.text.trim().isEmpty || 
        idFabrica == null) {
      _mensaje("Completa todos los campos obligatorios", esError: true);
      return;
    }

    setState(() => registrando = true);

    try {
      final resultado = await _repo.registrarDispositivo(
        idFabrica: idFabrica!,
        codigo: codigoCtrl.text.trim(),
        nombre: nombreCtrl.text.trim(),
        fkEmpresa: empresaSeleccionada!,
        fkSede: sedeSeleccionada,
      );

      if (resultado['exito'] == true) {
        idEquipo = resultado['id_equipo']?.toString();
        if (mounted) setState(() => registrado = true);
        _mensaje(resultado['mensaje'], esError: false);
      } else {
        _mensaje(resultado['mensaje'], esError: true);
      }
    } catch (e) {
      _mensaje("Error: $e", esError: true);
    } finally {
      if (mounted) setState(() => registrando = false);
    }
  }

  Future<void> _activarGps() async {
    // Verificar GPS del dispositivo
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _mostrarDialogoGPS();
      return;
    }
    
    // Verificar permisos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _mensaje("Permiso denegado", esError: true);
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _mostrarDialogoPermiso();
      return;
    }

    // Obtener el UUID del equipo si no lo tenemos
    if (idEquipo == null && idFabrica != null) {
      idEquipo = await _repo.obtenerIdEquipo(idFabrica!);
    }

    if (idEquipo == null) {
      _mensaje("Error: No se encontró el equipo registrado", esError: true);
      return;
    }
    
    // Configurar callback para actualizar UI
    _gps.onEstadoCambiado = (mensaje, esError) {
      if (mounted) setState(() {});
    };

    // Iniciar GPS con el UUID del equipo
    await _gps.iniciar(idEquipo!);

    setState(() => gpsActivo = true);
    
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
    
    _timerUI = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    
    _mensaje("GPS activado", esError: false);
  }
  
  void _mostrarDialogoGPS() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_off, color: Colors.red, size: 32),
            ),
            const SizedBox(width: 15),
            const Text("GPS Apagado", style: TextStyle(color: Colors.white, fontSize: 22)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Necesitas activar el GPS para enviar tu ubicación.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app, color: Colors.orange, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Desliza desde arriba y activa UBICACIÓN",
                      style: TextStyle(color: Colors.orange[200], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            icon: const Icon(Icons.settings),
            label: const Text("Configuración"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
  
  void _mostrarDialogoPermiso() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.block, color: Colors.red, size: 32),
            SizedBox(width: 15),
            Text("Permiso Requerido", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          "Debes habilitar el permiso de ubicación en configuración.",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Abrir Config", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _detenerGps() {
    _gps.detener();
    _pulseController.stop();
    _waveController.stop();
    _timerUI?.cancel();
    setState(() => gpsActivo = false);
    _mensaje("GPS detenido", esError: false);
  }

  void _mensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(esError ? Icons.error : Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(texto, style: const TextStyle(fontSize: 15))),
          ],
        ),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) return _pantallaCargando();
    if (errorInicial != null) return _pantallaError();
    if (!registrado) return _formRegistro();
    return _panelGps();
  }
  
  Widget _pantallaCargando() {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 20),
            Text("Verificando...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  
  Widget _pantallaError() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 70, color: Colors.red),
            const SizedBox(height: 20),
            Text(errorInicial!, style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() { cargando = true; errorInicial = null; });
                _inicializar();
              },
              child: const Text("Reintentar"),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // 📝 FORMULARIO DE REGISTRO
  // ============================================
  Widget _formRegistro() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text("Registrar Dispositivo"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_android, size: 60, color: Colors.orange),
            ),
            const SizedBox(height: 25),
            
            // ID del dispositivo
            _infoCard("ID Dispositivo", idFabrica ?? "---", Icons.fingerprint),
            const SizedBox(height: 20),
            
            // EMPRESA (obligatorio)
            _dropdownEmpresas(),
            const SizedBox(height: 15),
            
            // SEDE (opcional, filtrada por empresa)
            if (empresaSeleccionada != null) ...[
              _dropdownSedes(),
              const SizedBox(height: 15),
            ],
            
            // Código del vehículo
            _textField(codigoCtrl, "Código *", "V01", Icons.qr_code),
            const SizedBox(height: 15),
            
            // Nombre del conductor
            _textField(nombreCtrl, "Nombre *", "Juan Pérez", Icons.person),
            const SizedBox(height: 30),
            
            // Botón registrar
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: registrando ? null : _registrar,
                icon: registrando 
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.check_circle, size: 24),
                label: Text(registrando ? "REGISTRANDO..." : "REGISTRAR"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            Text(
              "* Campos obligatorios",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icono, color: Colors.orange),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                Text(valor, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownEmpresas() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 5),
            child: Text("Empresa *", style: TextStyle(color: Colors.orange[300], fontSize: 12)),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: empresaSeleccionada,
              isExpanded: true,
              dropdownColor: const Color(0xFF252525),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
              hint: Text(
                empresas.isEmpty ? "Cargando empresas..." : "Selecciona una empresa",
                style: TextStyle(color: Colors.grey[500]),
              ),
              items: empresas.map((e) => DropdownMenuItem(
                value: e['id_empresa']?.toString(),
                child: Text(
                  e['razon_social'] ?? e['nombre_comercial'] ?? 'Empresa',
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              )).toList(),
              onChanged: (v) {
                setState(() => empresaSeleccionada = v);
                if (v != null) _cargarSedesPorEmpresa(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownSedes() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 5),
            child: Text("Sede (opcional)", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: sedeSeleccionada,
              isExpanded: true,
              dropdownColor: const Color(0xFF252525),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              hint: Text(
                sedes.isEmpty ? "Sin sedes disponibles" : "Selecciona una sede",
                style: TextStyle(color: Colors.grey[600]),
              ),
              items: sedes.map((s) => DropdownMenuItem(
                value: s['id_sede']?.toString(),
                child: Text(
                  s['nombre_sede'] ?? s['nombre'] ?? 'Sede',
                  style: const TextStyle(color: Colors.white),
                ),
              )).toList(),
              onChanged: (v) => setState(() => sedeSeleccionada = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String label, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600]),
        labelStyle: const TextStyle(color: Colors.orange),
        prefixIcon: Icon(icon, color: Colors.orange),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
      ),
    );
  }

  // ============================================
  // 📱 PANEL GPS
  // ============================================
  Widget _panelGps() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _gpsIcon(),
                    const SizedBox(height: 25),
                    _estadoGps(),
                    const SizedBox(height: 30),
                    if (gpsActivo) _panelCoordenadas(),
                    if (gpsActivo) const SizedBox(height: 20),
                    if (gpsActivo) _panelEstadisticas(),
                    if (gpsActivo && _gps.ultimoError.isNotEmpty) const SizedBox(height: 15),
                    if (gpsActivo && _gps.ultimoError.isNotEmpty) _panelError(),
                    const SizedBox(height: 25),
                    _botonPrincipal(),
                    const SizedBox(height: 20),
                    _infoDispositivo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "MODO CONDUCTOR",
              style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _gps.tieneInternet ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _gps.tieneInternet ? Icons.wifi : Icons.wifi_off,
                  color: _gps.tieneInternet ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  _gps.tipoConexion,
                  style: TextStyle(
                    color: _gps.tieneInternet ? Colors.green : Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gpsIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            if (gpsActivo) ...[
              _wave(100, 0.1),
              _wave(130, 0.07),
              _wave(160, 0.04),
            ],
            Transform.scale(
              scale: gpsActivo ? _pulseAnimation.value : 1.0,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: (gpsActivo ? Colors.green : Colors.grey).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: gpsActivo ? Colors.green : Colors.grey, width: 3),
                  boxShadow: gpsActivo ? [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)] : null,
                ),
                child: Icon(gpsActivo ? Icons.gps_fixed : Icons.gps_off, size: 80, color: gpsActivo ? Colors.green : Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _wave(double size, double opacity) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Container(
          width: size + (_waveController.value * 30),
          height: size + (_waveController.value * 30),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.withOpacity(opacity * (1 - _waveController.value)), width: 2),
          ),
        );
      },
    );
  }

  Widget _estadoGps() {
    return Column(
      children: [
        Text(
          gpsActivo ? "TRANSMITIENDO" : "GPS INACTIVO",
          style: TextStyle(color: gpsActivo ? Colors.green : Colors.grey, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 3),
        ),
        const SizedBox(height: 10),
        Text(
          gpsActivo ? "Enviando ubicación cada 5 segundos" : "Presiona el botón para iniciar",
          style: TextStyle(color: Colors.grey[500], fontSize: 16),
        ),
      ],
    );
  }

  Widget _panelCoordenadas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.cyan.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.my_location, color: Colors.cyan, size: 24),
              ),
              const SizedBox(width: 15),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ÚLTIMA COORDENADA", style: TextStyle(color: Colors.cyan, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text("Enviada al servidor", style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_gps.ultimaUbicacion.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _coordenada("LAT", _extraerLat()),
                  const SizedBox(height: 10),
                  _coordenada("LON", _extraerLon()),
                ],
              ),
            )
          else
            Text("Obteniendo ubicación...", style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  String _extraerLat() {
    try { return _gps.ultimaUbicacion.split(", ")[0].replaceAll("Lat: ", ""); } catch (e) { return "---"; }
  }
  String _extraerLon() {
    try { return _gps.ultimaUbicacion.split(", ")[1].replaceAll("Lon: ", ""); } catch (e) { return "---"; }
  }

  Widget _coordenada(String label, String valor) {
    return Row(
      children: [
        Container(
          width: 50,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(color: Colors.cyan.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
          child: Text(label, style: const TextStyle(color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(valor, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ),
      ],
    );
  }

  Widget _panelEstadisticas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Colors.orange, size: 20),
              SizedBox(width: 10),
              Text("ESTADÍSTICAS", style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _contador("☁️", "SERVIDOR", _gps.enviosExitosos, Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _contador("💾", "LOCAL", _gps.guardadosLocal, Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _contador("❌", "FALLIDO", _gps.enviosFallidos, Colors.red)),
            ],
          ),
          if (_gps.pendientesSincronizar > 0)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sync, color: Colors.blue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "${_gps.pendientesSincronizar} pendientes de sincronizar",
                        style: const TextStyle(color: Colors.blue, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await _gps.forzarSincronizacion();
                        setState(() {});
                      },
                      icon: const Icon(Icons.cloud_upload, color: Colors.blue, size: 22),
                      tooltip: "Sincronizar ahora",
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _contador(String emoji, String label, int valor, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 5),
          Text("$valor", style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 9, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _panelError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ERROR", style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_gps.ultimoError, style: TextStyle(color: Colors.red[200], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonPrincipal() {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: gpsActivo ? _detenerGps : _activarGps,
        style: ElevatedButton.styleFrom(
          backgroundColor: gpsActivo ? Colors.red : Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: gpsActivo ? 0 : 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(gpsActivo ? Icons.stop_circle : Icons.play_circle_fill, size: 35),
            const SizedBox(width: 15),
            Text(gpsActivo ? "DETENER GPS" : "ACTIVAR GPS", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }

  Widget _infoDispositivo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.smartphone, color: Colors.grey, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text("ID Fábrica: ${idFabrica ?? '---'}", style: TextStyle(color: Colors.grey[600], fontSize: 10, fontFamily: 'monospace'))),
            ],
          ),
          if (idEquipo != null) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.key, color: Colors.grey, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text("ID Equipo: $idEquipo", style: TextStyle(color: Colors.grey[600], fontSize: 10, fontFamily: 'monospace'))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
