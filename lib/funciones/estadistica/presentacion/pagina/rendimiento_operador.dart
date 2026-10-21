import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/modelos/equipo_rendimiento.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/modelos/resumen_rendimiento.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/repositorios/repositorio_rendimiento_operacional.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/servicios/procesador_rendimiento_operacional.dart';

class RendimientoOperador extends StatefulWidget {
  const RendimientoOperador({super.key});

  @override
  State<RendimientoOperador> createState() => _RendimientoOperadorState();
}

class _RendimientoOperadorState extends State<RendimientoOperador> {
  final _repo = RepositorioRendimientoOperacional();
  final _processor = const ProcesadorRendimientoOperacional();

  DateTime _selectedDate = DateTime.now();
  List<EquipoRendimiento> _equipos = const [];
  EquipoRendimiento? _equipoSeleccionado;
  bool _loading = false;
  bool _loadingEquipos = true;
  String? _error;
  ResumenRendimiento? _result;

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
  }

  Future<void> _cargarEquipos() async {
    try {
      final equipos = await _repo.obtenerEquiposDisponibles();
      if (!mounted) {
        return;
      }

      setState(() {
        _equipos = equipos;
        _equipoSeleccionado = equipos.isNotEmpty ? equipos.first : null;
        _loadingEquipos = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingEquipos = false;
        _error = 'No se pudieron cargar los equipos: $e';
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Seleccionar fecha',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _runAnalytics() async {
    final equipo = _equipoSeleccionado;
    if (equipo == null) {
      setState(() {
        _error = 'Selecciona un equipo valido.';
        _result = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final puntos = await _repo.obtenerPuntosPorEquipoYFecha(
        equipo: equipo,
        fecha: _selectedDate,
      );

      if (puntos.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'No hay datos para ese dia y equipo.';
        });
        return;
      }

      final stats = _processor.procesar(puntos);

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _result = stats;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = 'Error procesando datos: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _loadingEquipos
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Analitica Operacional',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Los procesos matematicos quedaron separados en una carpeta propia para que sea facil ubicarlos y mantenerlos.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: isWide ? 220 : constraints.maxWidth,
                            child: OutlinedButton(
                              onPressed: _selectDate,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                                side: const BorderSide(color: Colors.orange),
                              ),
                              child: Text('Fecha: $dateLabel'),
                            ),
                          ),
                          SizedBox(
                            width: isWide ? 360 : constraints.maxWidth,
                            child: DropdownButtonFormField<String>(
                              value: _equipoSeleccionado?.idEquipoControl,
                              dropdownColor: const Color(0xFF1E1E1E),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Equipo',
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white24),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.orange),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: _equipos
                                  .map(
                                    (equipo) => DropdownMenuItem<String>(
                                      value: equipo.idEquipoControl,
                                      child: Text(
                                        '${equipo.etiquetaVisible} (${equipo.codigoEquipoControl})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _loading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _equipoSeleccionado = _equipos.firstWhere(
                                          (equipo) =>
                                              equipo.idEquipoControl == value,
                                        );
                                      });
                                    },
                            ),
                          ),
                          SizedBox(
                            width: isWide ? 160 : constraints.maxWidth,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _runAnalytics,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Calcular'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child:
                                CircularProgressIndicator(color: Colors.orange),
                          ),
                        ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      if (_result != null)
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _metricCard(
                              title: 'Kilometros Totales',
                              value:
                                  '${_result!.distanciaTotalKm.toStringAsFixed(2)} km',
                            ),
                            _metricCard(
                              title: 'Horas Detenido',
                              value: _result!.tiempoDetenidoHoras
                                  .toStringAsFixed(2),
                            ),
                            _metricCard(
                              title: 'Horas Operativas',
                              value: _result!.tiempoOperativoHoras
                                  .toStringAsFixed(2),
                            ),
                            _metricCard(
                              title: 'Velocidad Promedio',
                              value:
                                  '${_result!.velocidadPromedioKmh.toStringAsFixed(1)} km/h',
                            ),
                            _metricCard(
                              title: 'Rendimiento',
                              value:
                                  '${_result!.rendimientoKmh.toStringAsFixed(1)} km/h',
                            ),
                            _metricCard(
                              title: 'Puntos Validos',
                              value: _result!.puntosValidos.toString(),
                            ),
                            _metricCard(
                              title: 'Puntos Descartados',
                              value: _result!.puntosDescartados.toString(),
                            ),
                            _metricCard(
                              title: 'Paradas Detectadas',
                              value: _result!.paradasDetectadas.toString(),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _metricCard({required String title, required String value}) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
