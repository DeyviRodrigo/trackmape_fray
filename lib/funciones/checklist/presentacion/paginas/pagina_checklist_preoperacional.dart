import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:trackmape_sup/funciones/checklist/datos/modelos/checklist_modelos.dart';
import 'package:trackmape_sup/funciones/checklist/datos/repositorios/repositorio_checklist.dart';

class PaginaChecklistPreoperacional extends StatefulWidget {
  const PaginaChecklistPreoperacional({super.key});

  @override
  State<PaginaChecklistPreoperacional> createState() =>
      _PaginaChecklistPreoperacionalState();
}

class _PaginaChecklistPreoperacionalState
    extends State<PaginaChecklistPreoperacional> {
  final _repositorio = RepositorioChecklist();
  final _conductorController = TextEditingController();
  final _kilometrajeController = TextEditingController();
  final _nivelCombustibleController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _observacionesController = TextEditingController();

  List<VehiculoChecklist> _vehiculos = [];
  VehiculoChecklist? _vehiculoSeleccionado;
  DateTime _fechaHora = DateTime.now();
  bool _cargandoVehiculos = true;
  bool _guardando = false;
  bool _ubicando = false;
  String? _error;
  String? _mensaje;

  late Map<String, int> _valoresChecklist;

  @override
  void initState() {
    super.initState();
    _valoresChecklist = _valoresIniciales();
    _cargarVehiculos();
  }

  @override
  void dispose() {
    _conductorController.dispose();
    _kilometrajeController.dispose();
    _nivelCombustibleController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _cargarVehiculos() async {
    setState(() {
      _cargandoVehiculos = true;
      _error = null;
    });

    try {
      final vehiculos = await _repositorio.obtenerVehiculos();
      if (!mounted) return;
      setState(() {
        _vehiculos = vehiculos;
        _vehiculoSeleccionado = vehiculos.isNotEmpty ? vehiculos.first : null;
        _cargandoVehiculos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargandoVehiculos = false;
        _error = 'No se pudieron cargar vehiculos: $e';
      });
    }
  }

  Future<void> _seleccionarFechaHora() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaHora,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'Fecha del checklist',
    );
    if (fecha == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaHora),
      helpText: 'Hora del checklist',
    );
    if (hora == null) return;

    setState(() {
      _fechaHora = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hora.hour,
        hora.minute,
      );
    });
  }

  Future<void> _capturarUbicacion() async {
    setState(() {
      _ubicando = true;
      _error = null;
      _mensaje = null;
    });

    try {
      final servicioActivo = await Geolocator.isLocationServiceEnabled();
      if (!servicioActivo) {
        throw Exception('Activa el servicio de ubicacion del dispositivo.');
      }

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        throw Exception('No hay permiso para leer la ubicacion.');
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      if (!mounted) return;
      setState(() {
        _latitudController.text = posicion.latitude.toStringAsFixed(6);
        _longitudController.text = posicion.longitude.toStringAsFixed(6);
        _ubicando = false;
        _mensaje = 'Ubicacion capturada.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _ubicando = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _guardarChecklist() async {
    final vehiculo = _vehiculoSeleccionado;
    final kilometraje = int.tryParse(_kilometrajeController.text.trim());
    final nivelCombustible = double.tryParse(
      _normalizarNumero(_nivelCombustibleController.text),
    );
    final latitud = double.tryParse(_normalizarNumero(_latitudController.text));
    final longitud = double.tryParse(
      _normalizarNumero(_longitudController.text),
    );

    if (vehiculo == null) {
      setState(() => _error = 'Selecciona un vehiculo.');
      return;
    }
    if (_conductorController.text.trim().isEmpty) {
      setState(() => _error = 'Ingresa el conductor.');
      return;
    }
    if (kilometraje == null || kilometraje < 0) {
      setState(() => _error = 'Ingresa un kilometraje valido.');
      return;
    }
    if (nivelCombustible == null ||
        nivelCombustible < 0 ||
        nivelCombustible > 100) {
      setState(() {
        _error = 'Ingresa el nivel de combustible como porcentaje de 0 a 100.';
      });
      return;
    }
    if ((_latitudController.text.trim().isNotEmpty && latitud == null) ||
        (_longitudController.text.trim().isNotEmpty && longitud == null)) {
      setState(() => _error = 'Latitud o longitud no validas.');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
      _mensaje = null;
    });

    final datos = <String, dynamic>{
      'fk_vehiculo': vehiculo.idVehiculo,
      'fecha_hora': _fechaHora.toIso8601String(),
      'conductor': _conductorController.text.trim(),
      'kilometraje': kilometraje,
      'nivel_combustible': nivelCombustible,
      'latitud': latitud,
      'longitud': longitud,
      'observaciones': _observacionesController.text.trim().isEmpty
          ? null
          : _observacionesController.text.trim(),
      'estado_general': _calcularEstadoGeneral(),
      ..._valoresChecklist,
    };

    try {
      final resultado = await _repositorio.registrarChecklist(datos);
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _mensaje =
            'Checklist registrado (${_textoEstado(resultado.estadoGeneral)}).';
        _limpiarFormulario(mantenerVehiculo: true);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = 'No se pudo guardar el checklist: $e';
      });
    }
  }

  void _limpiarFormulario({required bool mantenerVehiculo}) {
    if (!mantenerVehiculo) {
      _vehiculoSeleccionado = _vehiculos.isNotEmpty ? _vehiculos.first : null;
    }
    _fechaHora = DateTime.now();
    _conductorController.clear();
    _kilometrajeController.clear();
    _nivelCombustibleController.clear();
    _latitudController.clear();
    _longitudController.clear();
    _observacionesController.clear();
    _valoresChecklist = _valoresIniciales();
  }

  Map<String, int> _valoresIniciales() {
    return {
      for (final seccion in seccionesChecklistPreoperacional)
        for (final campo in seccion.campos) campo.columna: checklistOk,
    };
  }

  int _calcularEstadoGeneral() {
    return _valoresChecklist.values.contains(checklistObservado)
        ? checklistObservado
        : checklistOk;
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoVehiculos) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 860;
          final inputWidth = isWide ? 280.0 : constraints.maxWidth;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _encabezado(),
                const SizedBox(height: 12),
                _panel(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: isWide ? 360 : constraints.maxWidth,
                        child: _selectorVehiculo(),
                      ),
                      SizedBox(
                        width: inputWidth,
                        child: _campoTexto(
                          controller: _conductorController,
                          label: 'Conductor',
                          icon: Icons.person,
                        ),
                      ),
                      SizedBox(
                        width: isWide ? 180 : constraints.maxWidth,
                        child: _campoTexto(
                          controller: _kilometrajeController,
                          label: 'Kilometraje',
                          icon: Icons.speed,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(
                        width: isWide ? 220 : constraints.maxWidth,
                        child: _campoTexto(
                          controller: _nivelCombustibleController,
                          label: 'Nivel combustible (%)',
                          icon: Icons.local_gas_station,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: isWide ? 230 : constraints.maxWidth,
                        child: OutlinedButton.icon(
                          onPressed: _seleccionarFechaHora,
                          icon: const Icon(Icons.event),
                          label: Text(_formatoFechaHora(_fechaHora)),
                          style: _botonSecundario(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _panel(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: isWide ? 220 : constraints.maxWidth,
                        child: _campoTexto(
                          controller: _latitudController,
                          label: 'Latitud',
                          icon: Icons.my_location,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: isWide ? 220 : constraints.maxWidth,
                        child: _campoTexto(
                          controller: _longitudController,
                          label: 'Longitud',
                          icon: Icons.explore,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: isWide ? 230 : constraints.maxWidth,
                        child: OutlinedButton.icon(
                          onPressed: _ubicando ? null : _capturarUbicacion,
                          icon: _ubicando
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.orange,
                                  ),
                                )
                              : const Icon(Icons.gps_fixed),
                          label: const Text('Usar ubicacion actual'),
                          style: _botonSecundario(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (_error != null) _mensajeEstado(_error!, true),
                if (_mensaje != null) _mensajeEstado(_mensaje!, false),
                const SizedBox(height: 12),
                _resumenEstado(),
                const SizedBox(height: 12),
                ...seccionesChecklistPreoperacional.map(_seccionChecklist),
                _panel(
                  child: TextField(
                    controller: _observacionesController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoracionCampo('Observaciones', Icons.notes),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: isWide ? 240 : double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _guardando ? null : _guardarChecklist,
                    icon: _guardando
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Guardar checklist'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _encabezado() {
    return Row(
      children: [
        const Icon(Icons.fact_check, color: Colors.orange),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Checklist preoperacional',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Recargar vehiculos',
          onPressed: _cargarVehiculos,
          icon: const Icon(Icons.refresh, color: Colors.orange),
        ),
      ],
    );
  }

  Widget _selectorVehiculo() {
    return DropdownButtonFormField<VehiculoChecklist>(
      initialValue: _vehiculoSeleccionado,
      isExpanded: true,
      dropdownColor: const Color(0xFF1E1E1E),
      style: const TextStyle(color: Colors.white),
      decoration: _decoracionCampo('Vehiculo', Icons.local_shipping),
      items: _vehiculos
          .map(
            (vehiculo) => DropdownMenuItem(
              value: vehiculo,
              child: Text(
                vehiculo.nombreMostrar,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (vehiculo) {
        setState(() {
          _vehiculoSeleccionado = vehiculo;
          _error = null;
          _mensaje = null;
        });
      },
    );
  }

  Widget _seccionChecklist(SeccionChecklist seccion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              seccion.titulo,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: seccion.campos.map(_campoChecklist).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoChecklist(CampoChecklist campo) {
    final valor = _valoresChecklist[campo.columna] ?? checklistOk;
    return SizedBox(
      width: 310,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            campo.titulo,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (!states.contains(WidgetState.selected)) {
                  return const Color(0xFF181818);
                }
                return _colorValor(valor).withValues(alpha: 0.22);
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (!states.contains(WidgetState.selected)) {
                  return Colors.white70;
                }
                return _colorValor(valor);
              }),
              side: WidgetStateProperty.resolveWith((states) {
                if (!states.contains(WidgetState.selected)) {
                  return const BorderSide(color: Colors.white24);
                }
                return BorderSide(color: _colorValor(valor));
              }),
            ),
            segments: const [
              ButtonSegment(
                value: checklistOk,
                icon: Icon(Icons.check),
                label: Text('OK'),
              ),
              ButtonSegment(
                value: checklistObservado,
                icon: Icon(Icons.close),
                label: Text('Obs.'),
              ),
              ButtonSegment(
                value: checklistNoAplica,
                icon: Icon(Icons.remove),
                label: Text('N/A'),
              ),
            ],
            selected: {valor},
            onSelectionChanged: (selection) {
              setState(() {
                _valoresChecklist[campo.columna] = selection.first;
                _error = null;
                _mensaje = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _resumenEstado() {
    final observados = _valoresChecklist.values
        .where((valor) => valor == checklistObservado)
        .length;
    final noAplica = _valoresChecklist.values
        .where((valor) => valor == checklistNoAplica)
        .length;
    final estado = _calcularEstadoGeneral();

    return _panel(
      child: Wrap(
        spacing: 14,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _datoResumen(
            icon: estado == checklistOk ? Icons.check_circle : Icons.warning,
            titulo: 'Estado general',
            valor: _textoEstado(estado),
            color: estado == checklistOk
                ? Colors.greenAccent
                : Colors.redAccent,
          ),
          _datoResumen(
            icon: Icons.report_problem,
            titulo: 'Observados',
            valor: '$observados',
            color: observados == 0 ? Colors.white70 : Colors.redAccent,
          ),
          _datoResumen(
            icon: Icons.remove_circle_outline,
            titulo: 'No aplica',
            valor: '$noAplica',
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _datoResumen({
    required IconData icon,
    required String titulo,
    required String valor,
    required Color color,
  }) {
    return SizedBox(
      width: 220,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  valor,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _decoracionCampo(label, icon),
    );
  }

  InputDecoration _decoracionCampo(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.orange),
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF181818),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.orange),
      ),
    );
  }

  ButtonStyle _botonSecundario() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.orange,
      side: const BorderSide(color: Colors.orange),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }

  Widget _mensajeEstado(String texto, bool error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: error
            ? Colors.redAccent.withValues(alpha: 0.12)
            : Colors.greenAccent.withValues(alpha: 0.12),
        border: Border.all(
          color: error ? Colors.redAccent : Colors.greenAccent,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(color: error ? Colors.redAccent : Colors.greenAccent),
      ),
    );
  }

  Color _colorValor(int valor) {
    return switch (valor) {
      checklistObservado => Colors.redAccent,
      checklistNoAplica => Colors.white70,
      _ => Colors.greenAccent,
    };
  }

  String _textoEstado(int estado) {
    return estado == checklistOk ? 'Apto' : 'Observado';
  }

  String _normalizarNumero(String value) => value.trim().replaceAll(',', '.');

  String _formatoFechaHora(DateTime value) {
    return DateFormat('yyyy-MM-dd HH:mm').format(value);
  }
}
