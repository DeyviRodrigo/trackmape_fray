import 'package:flutter/material.dart';
import '../datos/repositorio_conductor.dart';
import '../servicios/gps_servicio.dart';
import '../servicios/identificador_dispositivo.dart';

class PaginaConductor extends StatefulWidget {
  const PaginaConductor({super.key});

  @override
  State<PaginaConductor> createState() => _PaginaConductorState();
}

class _PaginaConductorState extends State<PaginaConductor> {

  final RepositorioConductor _repo = RepositorioConductor();
  final GpsServicio _gps = GpsServicio();

  String? idDispositivo;
  String? errorInicial;

  bool cargando = true;
  bool registrando = false;
  bool registrado = false;
  bool gpsActivo = false;

  // ============================================
  // 📍 DATOS PARA EL DROPDOWN DE SEDES
  // ============================================
  List<Map<String, dynamic>> sedes = [];
  String? sedeSeleccionada;

  final TextEditingController codigoCtrl = TextEditingController();
  final TextEditingController nombreCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await _cargarSedes();
    await _verificarDispositivo();
  }

  /// Carga las sedes desde la base de datos
  Future<void> _cargarSedes() async {
    try {
      final listaSedes = await _repo.obtenerSedes();
      if (mounted) {
        setState(() {
          sedes = listaSedes;
          // Seleccionar la primera sede por defecto si hay
          if (sedes.isNotEmpty) {
            sedeSeleccionada = sedes.first['id_sede']?.toString();
          }
        });
      }
      debugPrint("📍 Sedes cargadas: ${sedes.length}");
    } catch (e) {
      debugPrint("❌ Error cargando sedes: $e");
    }
  }

  Future<void> _verificarDispositivo() async {

    try {

      final id = await IdentificadorDispositivo.obtenerId();

      debugPrint("🔑 ID Dispositivo obtenido: $id");

      idDispositivo = id;

      final existe = await _repo.buscarDispositivo(id);

      if (existe != null) {
        debugPrint("✅ Dispositivo ya registrado: ${existe['codigo_equipo_control']}");
        registrado = true;
      } else {
        debugPrint("📝 Dispositivo no registrado, mostrando formulario");
      }

    } catch (e) {

      debugPrint("❌ ERROR verificando dispositivo: $e");
      errorInicial = e.toString();

    }

    if (mounted) {
      setState(() {
        cargando = false;
      });
    }

  }

  Future<void> _registrar() async {

    // Validaciones
    if (sedeSeleccionada == null) {
      _mensaje("Selecciona una sede", esError: true);
      return;
    }

    if (codigoCtrl.text.trim().isEmpty) {
      _mensaje("Ingresa el código del equipo", esError: true);
      return;
    }

    if (nombreCtrl.text.trim().isEmpty) {
      _mensaje("Ingresa el nombre del conductor", esError: true);
      return;
    }

    if (idDispositivo == null) {
      _mensaje("Error: No se pudo obtener el ID del dispositivo", esError: true);
      return;
    }

    setState(() {
      registrando = true;
    });

    try {

      debugPrint("📤 Intentando registrar dispositivo...");
      debugPrint("   ID: $idDispositivo");
      debugPrint("   Sede: $sedeSeleccionada");
      debugPrint("   Código: ${codigoCtrl.text.trim()}");
      debugPrint("   Nombre: ${nombreCtrl.text.trim()}");

      final resultado = await _repo.registrarDispositivo(
        id: idDispositivo!,
        codigo: codigoCtrl.text.trim(),
        nombre: nombreCtrl.text.trim(),
        fkSede: sedeSeleccionada!,
      );

      debugPrint("📥 Resultado: $resultado");

      if (resultado['exito'] == true) {

        if (mounted) {
          setState(() {
            registrado = true;
          });
        }

        _mensaje(resultado['mensaje'], esError: false);

      } else {

        _mensaje(resultado['mensaje'], esError: true);

      }

    } catch (e) {

      debugPrint("❌ Error en _registrar: $e");
      _mensaje("Error inesperado: $e", esError: true);

    } finally {

      if (mounted) {
        setState(() {
          registrando = false;
        });
      }

    }

  }

  void _activarGps() {

    _gps.iniciar(idDispositivo!);

    setState(() {
      gpsActivo = true;
    });

    _mensaje("GPS activado - Transmitiendo ubicación", esError: false);

  }

  void _detenerGps() {

    _gps.detener();

    setState(() {
      gpsActivo = false;
    });

    _mensaje("GPS detenido", esError: false);

  }

  void _mensaje(String texto, {bool esError = false}) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
        duration: Duration(seconds: esError ? 4 : 2),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    if (cargando) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.orange),
              const SizedBox(height: 20),
              Text(
                "Verificando dispositivo...",
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    // Si hubo error al obtener el ID
    if (errorInicial != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: const Text("Error"),
          backgroundColor: Colors.red.shade700,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                "No se pudo identificar el dispositivo",
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                errorInicial!,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    cargando = true;
                    errorInicial = null;
                  });
                  _inicializar();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Reintentar"),
              ),
            ],
          ),
        ),
      );
    }

    if (!registrado) {
      return _formRegistro();
    }

    return _panelGps();

  }

  Widget _formRegistro() {

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Registrar Dispositivo"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Header con icono
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_android,
                  size: 50,
                  color: Colors.orange,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ID del dispositivo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ID del Dispositivo:",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  SelectableText(
                    idDispositivo ?? "No disponible",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ============================================
            // 📍 DROPDOWN DE SEDES
            // ============================================
            DropdownButtonFormField<String>(
              value: sedeSeleccionada,
              decoration: InputDecoration(
                labelText: "Sede / Ubicación",
                labelStyle: const TextStyle(color: Colors.orange),
                prefixIcon: const Icon(Icons.location_city, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
              ),
              dropdownColor: const Color(0xFF2A2A2A),
              style: const TextStyle(color: Colors.white),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
              items: sedes.map((sede) {
                // Ajusta estos campos según tu tabla de sedes
                final id = sede['id_sede']?.toString() ?? '';
                final nombre = sede['nombre_sede']?.toString() ??
                    sede['nombre']?.toString() ??
                    sede['descripcion']?.toString() ??
                    'Sede $id';

                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(nombre),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  sedeSeleccionada = valor;
                });
              },
              hint: Text(
                sedes.isEmpty ? "Cargando sedes..." : "Selecciona una sede",
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),

            const SizedBox(height: 20),

            // Campo código
            TextField(
              controller: codigoCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Código del equipo",
                hintText: "Ej: V01, MOTO-01, CAM-05",
                hintStyle: TextStyle(color: Colors.grey[600]),
                labelStyle: const TextStyle(color: Colors.orange),
                prefixIcon: const Icon(Icons.qr_code, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
              ),
            ),

            const SizedBox(height: 20),

            // Campo nombre
            TextField(
              controller: nombreCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Nombre del conductor",
                hintText: "Ej: Juan Pérez",
                hintStyle: TextStyle(color: Colors.grey[600]),
                labelStyle: const TextStyle(color: Colors.orange),
                prefixIcon: const Icon(Icons.person, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
              ),
            ),

            const SizedBox(height: 40),

            // Botón registrar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: (registrando || sedes.isEmpty) ? null : _registrar,
                icon: registrando
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
                    : const Icon(Icons.app_registration),
                label: Text(
                  registrando ? "REGISTRANDO..." : "REGISTRAR DISPOSITIVO",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.orange.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Nota informativa
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[300], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Una vez registrado, podrás activar el GPS para transmitir tu ubicación en tiempo real.",
                      style: TextStyle(color: Colors.blue[200], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _panelGps() {

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Modo Conductor"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.orange,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Icono animado de GPS
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: gpsActivo
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: gpsActivo ? Colors.green : Colors.grey,
                    width: 3,
                  ),
                ),
                child: Icon(
                  gpsActivo ? Icons.gps_fixed : Icons.gps_off,
                  size: 60,
                  color: gpsActivo ? Colors.green : Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              // Estado
              Text(
                gpsActivo ? "TRANSMITIENDO" : "GPS INACTIVO",
                style: TextStyle(
                  color: gpsActivo ? Colors.green : Colors.grey,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                gpsActivo
                    ? "Enviando ubicación cada 5 segundos"
                    : "Presiona el botón para iniciar",
                style: TextStyle(color: Colors.grey[500]),
              ),

              const SizedBox(height: 40),

              // Info del dispositivo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      "ID Dispositivo",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      idDispositivo ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Botón principal
              SizedBox(
                width: double.infinity,
                height: 60,
                child: gpsActivo
                    ? ElevatedButton.icon(
                  onPressed: _detenerGps,
                  icon: const Icon(Icons.stop, size: 28),
                  label: const Text(
                    "DETENER GPS",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                )
                    : ElevatedButton.icon(
                  onPressed: _activarGps,
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: const Text(
                    "ACTIVAR GPS",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

}