import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trackmape_sup/funciones/combustible/datos/modelos/combustible_modelos.dart';
import 'package:trackmape_sup/funciones/combustible/datos/repositorios/repositorio_combustible.dart';

class PaginaCombustible extends StatefulWidget {
  const PaginaCombustible({super.key});

  @override
  State<PaginaCombustible> createState() => _PaginaCombustibleState();
}

class _PaginaCombustibleState extends State<PaginaCombustible> {
  final _repositorio = RepositorioCombustible();
  final _galonesController = TextEditingController();
  final _totalController = TextEditingController();
  final _fkEmisorController = TextEditingController();
  final _kilometrosTramoController = TextEditingController(text: '5');

  List<VehiculoCombustible> _vehiculos = [];
  VehiculoCombustible? _vehiculoIngreso;
  VehiculoCombustible? _vehiculoDashboard;
  DateTime _fechaIngreso = DateTime.now();
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now();
  DashboardCombustible? _dashboard;

  bool _cargandoVehiculos = true;
  bool _guardandoIngreso = false;
  bool _calculandoDashboard = false;
  String? _errorCarga;
  String? _errorIngreso;
  String? _mensajeIngreso;
  String? _errorDashboard;

  @override
  void initState() {
    super.initState();
    _cargarVehiculos();
  }

  @override
  void dispose() {
    _galonesController.dispose();
    _totalController.dispose();
    _fkEmisorController.dispose();
    _kilometrosTramoController.dispose();
    super.dispose();
  }

  Future<void> _cargarVehiculos() async {
    setState(() {
      _cargandoVehiculos = true;
      _errorCarga = null;
    });

    try {
      final vehiculos = await _repositorio.obtenerVehiculos();
      if (!mounted) return;
      setState(() {
        _vehiculos = vehiculos;
        _vehiculoIngreso = vehiculos.isNotEmpty ? vehiculos.first : null;
        _vehiculoDashboard = vehiculos.isNotEmpty ? vehiculos.first : null;
        _fkEmisorController.text = vehiculos.firstOrNull?.fkEquipoControl ?? '';
        _cargandoVehiculos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargandoVehiculos = false;
        _errorCarga = _mensajeErrorSupabase(e);
      });
    }
  }

  Future<void> _registrarIngreso() async {
    final vehiculo = _vehiculoIngreso;
    final galones = int.tryParse(_galonesController.text.trim());
    final total = double.tryParse(_normalizarNumero(_totalController.text));

    if (vehiculo == null) {
      setState(() => _errorIngreso = 'Selecciona un vehiculo.');
      return;
    }
    if (galones == null || galones <= 0) {
      setState(() => _errorIngreso = 'Ingresa una cantidad valida de galones.');
      return;
    }
    if (total == null || total < 0) {
      setState(() => _errorIngreso = 'Ingresa un total valido.');
      return;
    }
    final capacidad = vehiculo.capacidadTanque ?? 0;
    if (capacidad > 0 && galones > capacidad) {
      setState(() {
        _errorIngreso =
            'El ingreso supera la capacidad del tanque (${capacidad.toStringAsFixed(1)} gal).';
      });
      return;
    }

    setState(() {
      _guardandoIngreso = true;
      _errorIngreso = null;
      _mensajeIngreso = null;
    });

    try {
      await _repositorio.registrarIngreso(
        idVehiculo: vehiculo.idVehiculo,
        fechaHora: _fechaIngreso,
        galones: galones,
        total: total,
      );
      if (!mounted) return;
      setState(() {
        _guardandoIngreso = false;
        _mensajeIngreso = 'Ingreso de combustible registrado.';
        _galonesController.clear();
        _totalController.clear();
        _dashboard = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardandoIngreso = false;
        _errorIngreso = _mensajeErrorSupabase(e);
      });
    }
  }

  Future<void> _calcularDashboard() async {
    final vehiculo = _vehiculoDashboard;
    final fkEmisor = _fkEmisorController.text.trim();
    final kilometrosTramo = double.tryParse(
      _normalizarNumero(_kilometrosTramoController.text),
    );

    if (vehiculo == null) {
      setState(() => _errorDashboard = 'Selecciona un vehiculo.');
      return;
    }
    if (!vehiculo.tieneParametrosConsumo) {
      setState(() {
        _errorDashboard =
            'Configura rendimiento_km_galon y capacidad_tanque para ${vehiculo.placa}.';
      });
      return;
    }
    if (fkEmisor.isEmpty) {
      setState(() {
        _errorDashboard =
            'Ingresa el fk_emisor GPS asociado al vehiculo para leer posiciones.';
      });
      return;
    }
    if (kilometrosTramo == null || kilometrosTramo <= 0) {
      setState(() => _errorDashboard = 'Ingresa un tamano de tramo valido.');
      return;
    }

    final inicio = DateTime(
      _fechaInicio.year,
      _fechaInicio.month,
      _fechaInicio.day,
    );
    final fin = DateTime(
      _fechaFin.year,
      _fechaFin.month,
      _fechaFin.day,
      23,
      59,
      59,
      999,
    );

    if (fin.isBefore(inicio)) {
      setState(() => _errorDashboard = 'La fecha final no puede ser anterior.');
      return;
    }

    setState(() {
      _calculandoDashboard = true;
      _errorDashboard = null;
      _dashboard = null;
    });

    try {
      final resultado = await _repositorio.obtenerDashboard(
        vehiculo: vehiculo,
        fkEmisor: fkEmisor,
        inicio: inicio,
        fin: fin,
        kilometrosPorTramo: kilometrosTramo,
      );
      if (!mounted) return;
      setState(() {
        _calculandoDashboard = false;
        _dashboard = resultado;
        if (resultado.tramos.isEmpty) {
          _errorDashboard =
              'No se generaron tramos. Revisa posiciones GPS o parametros del vehiculo.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _calculandoDashboard = false;
        _errorDashboard = _mensajeErrorSupabase(e);
      });
    }
  }

  Future<void> _seleccionarFechaIngreso() async {
    final nuevaFecha = await _seleccionarFechaHora(_fechaIngreso);
    if (nuevaFecha != null) {
      setState(() => _fechaIngreso = nuevaFecha);
    }
  }

  Future<void> _seleccionarFechaInicio() async {
    final nuevaFecha = await _seleccionarFecha(_fechaInicio);
    if (nuevaFecha != null) {
      setState(() => _fechaInicio = nuevaFecha);
    }
  }

  Future<void> _seleccionarFechaFin() async {
    final nuevaFecha = await _seleccionarFecha(_fechaFin);
    if (nuevaFecha != null) {
      setState(() => _fechaFin = nuevaFecha);
    }
  }

  Future<DateTime?> _seleccionarFecha(DateTime actual) async {
    return showDatePicker(
      context: context,
      initialDate: actual,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'Seleccionar fecha',
    );
  }

  Future<DateTime?> _seleccionarFechaHora(DateTime actual) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: actual,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Fecha del ingreso',
    );
    if (fecha == null || !mounted) return null;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(actual),
      helpText: 'Hora del ingreso',
    );
    if (hora == null) return null;

    return DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoVehiculos) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    if (_errorCarga != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorCarga!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _cargarVehiculos,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Column(
          children: [
            Container(
              color: Colors.black,
              child: const TabBar(
                indicatorColor: Colors.orange,
                labelColor: Colors.orange,
                unselectedLabelColor: Colors.white60,
                tabs: [
                  Tab(icon: Icon(Icons.local_gas_station), text: 'Ingreso'),
                  Tab(icon: Icon(Icons.analytics), text: 'Dashboard'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [_buildFormularioIngreso(), _buildDashboard()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioIngreso() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tituloSeccion('Nuevo ingreso de combustible'),
              const SizedBox(height: 12),
              _panel(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: isWide ? 360 : constraints.maxWidth,
                      child: _selectorVehiculo(
                        value: _vehiculoIngreso,
                        onChanged: (vehiculo) {
                          setState(() {
                            _vehiculoIngreso = vehiculo;
                            _errorIngreso = null;
                            _mensajeIngreso = null;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: isWide ? 220 : constraints.maxWidth,
                      child: _campoTexto(
                        controller: _galonesController,
                        label: 'Galones',
                        icon: Icons.water_drop,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(
                      width: isWide ? 220 : constraints.maxWidth,
                      child: _campoTexto(
                        controller: _totalController,
                        label: 'Total pagado',
                        icon: Icons.payments,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isWide ? 240 : constraints.maxWidth,
                      child: OutlinedButton.icon(
                        onPressed: _seleccionarFechaIngreso,
                        icon: const Icon(Icons.event),
                        label: Text(_formatoFechaHora(_fechaIngreso)),
                        style: _botonSecundario(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_vehiculoIngreso != null)
                _panel(child: _buildResumenCapacidad(_vehiculoIngreso!)),
              const SizedBox(height: 12),
              if (_errorIngreso != null) _mensajeEstado(_errorIngreso!, true),
              if (_mensajeIngreso != null)
                _mensajeEstado(_mensajeIngreso!, false),
              const SizedBox(height: 12),
              SizedBox(
                width: isWide ? 240 : double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _guardandoIngreso ? null : _registrarIngreso,
                  icon: _guardandoIngreso
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Guardar ingreso'),
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
    );
  }

  Widget _buildDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 860;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tituloSeccion('Consumo de combustible por tramos'),
              const SizedBox(height: 12),
              _panel(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: isWide ? 330 : constraints.maxWidth,
                      child: _selectorVehiculo(
                        value: _vehiculoDashboard,
                        onChanged: (vehiculo) {
                          setState(() {
                            _vehiculoDashboard = vehiculo;
                            _fkEmisorController.text =
                                vehiculo?.fkEquipoControl ?? '';
                            _dashboard = null;
                            _errorDashboard = null;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: isWide ? 300 : constraints.maxWidth,
                      child: _campoTexto(
                        controller: _fkEmisorController,
                        label: 'fk_emisor GPS',
                        icon: Icons.gps_fixed,
                      ),
                    ),
                    SizedBox(
                      width: isWide ? 170 : constraints.maxWidth,
                      child: _campoTexto(
                        controller: _kilometrosTramoController,
                        label: 'Km por tramo',
                        icon: Icons.route,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isWide ? 190 : constraints.maxWidth,
                      child: OutlinedButton.icon(
                        onPressed: _seleccionarFechaInicio,
                        icon: const Icon(Icons.date_range),
                        label: Text('Inicio ${_formatoFecha(_fechaInicio)}'),
                        style: _botonSecundario(),
                      ),
                    ),
                    SizedBox(
                      width: isWide ? 190 : constraints.maxWidth,
                      child: OutlinedButton.icon(
                        onPressed: _seleccionarFechaFin,
                        icon: const Icon(Icons.date_range),
                        label: Text('Fin ${_formatoFecha(_fechaFin)}'),
                        style: _botonSecundario(),
                      ),
                    ),
                    SizedBox(
                      width: isWide ? 180 : constraints.maxWidth,
                      child: ElevatedButton.icon(
                        onPressed: _calculandoDashboard
                            ? null
                            : _calcularDashboard,
                        icon: _calculandoDashboard
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(Icons.calculate),
                        label: const Text('Calcular'),
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
              ),
              const SizedBox(height: 12),
              if (_errorDashboard != null)
                _mensajeEstado(_errorDashboard!, true),
              if (_dashboard == null && !_calculandoDashboard)
                _panel(
                  child: const Text(
                    'Selecciona un vehiculo, vincula el fk_emisor GPS y calcula el periodo.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              if (_dashboard != null)
                _buildResultadoDashboard(_dashboard!, constraints),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResumenCapacidad(VehiculoCombustible vehiculo) {
    final galones = int.tryParse(_galonesController.text.trim()) ?? 0;
    final capacidad = vehiculo.capacidadTanque ?? 0;
    final porcentaje = capacidad > 0 ? (galones / capacidad) * 100 : 0.0;
    final rendimiento = vehiculo.rendimientoKmGalon ?? 0;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _datoCompacto(
          icon: Icons.local_shipping,
          titulo: 'Vehiculo',
          valor: vehiculo.nombreMostrar,
        ),
        _datoCompacto(
          icon: Icons.propane_tank,
          titulo: 'Capacidad',
          valor: capacidad > 0
              ? '${capacidad.toStringAsFixed(1)} gal'
              : 'Sin dato',
        ),
        _datoCompacto(
          icon: Icons.percent,
          titulo: 'Ingreso vs tanque',
          valor: capacidad > 0
              ? '${porcentaje.toStringAsFixed(1)} %'
              : 'Sin dato',
        ),
        _datoCompacto(
          icon: Icons.speed,
          titulo: 'Rendimiento',
          valor: rendimiento > 0
              ? '${rendimiento.toStringAsFixed(1)} km/gal'
              : 'Sin dato',
        ),
      ],
    );
  }

  Widget _buildResultadoDashboard(
    DashboardCombustible dashboard,
    BoxConstraints constraints,
  ) {
    final anchoTarjeta = constraints.maxWidth >= 900
        ? (constraints.maxWidth - 64) / 4
        : constraints.maxWidth >= 620
        ? (constraints.maxWidth - 40) / 2
        : constraints.maxWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _tarjetaMetrica(
              ancho: anchoTarjeta,
              titulo: 'Km analizados',
              valor: dashboard.kilometrosTotales.toStringAsFixed(2),
              unidad: 'km',
              icono: Icons.route,
              color: Colors.lightBlueAccent,
            ),
            _tarjetaMetrica(
              ancho: anchoTarjeta,
              titulo: 'Consumo estimado',
              valor: dashboard.galonesConsumidos.toStringAsFixed(2),
              unidad: 'gal',
              icono: Icons.local_gas_station,
              color: Colors.orangeAccent,
            ),
            _tarjetaMetrica(
              ancho: anchoTarjeta,
              titulo: 'Tanque consumido',
              valor: dashboard.porcentajeTanqueConsumido.toStringAsFixed(1),
              unidad: '%',
              icono: Icons.percent,
              color: Colors.redAccent,
            ),
            _tarjetaMetrica(
              ancho: anchoTarjeta,
              titulo: 'Saldo estimado',
              valor: dashboard.galonesRestantesEstimados.toStringAsFixed(2),
              unidad: 'gal',
              icono: Icons.opacity,
              color: Colors.greenAccent,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _panel(
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _textoResumen(
                'Ingresos del periodo',
                '${dashboard.galonesIngresados.toStringAsFixed(0)} gal',
              ),
              _textoResumen(
                'Total ingresado',
                'S/ ${dashboard.costoIngresado.toStringAsFixed(2)}',
              ),
              _textoResumen(
                'Costo estimado consumido',
                'S/ ${dashboard.costoEstimadoConsumo.toStringAsFixed(2)}',
              ),
              _textoResumen(
                'Autonomia tanque',
                '${dashboard.vehiculo.autonomiaTanqueKm.toStringAsFixed(1)} km',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _panel(
          child: SizedBox(
            height: 260,
            child: dashboard.tramos.isEmpty
                ? const Center(
                    child: Text(
                      'Sin tramos calculados',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : _graficoTramos(dashboard.tramos),
          ),
        ),
        const SizedBox(height: 12),
        _panel(child: _tablaTramos(dashboard.tramos)),
      ],
    );
  }

  Widget _graficoTramos(List<TramoConsumoCombustible> tramos) {
    final visibles = tramos.take(10).toList();
    final maxGalones = visibles.fold<double>(
      0,
      (maximo, tramo) => math.max(maximo, tramo.galonesConsumidos),
    );
    final maxY = maxGalones <= 0 ? 1.0 : maxGalones * 1.25;

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        barTouchData: const BarTouchData(enabled: true),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              const FlLine(color: Colors.white12, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 38),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= visibles.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: Text(
                    'T${visibles[index].numero}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var index = 0; index < visibles.length; index++)
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: visibles[index].galonesConsumidos,
                  width: 18,
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: Colors.white10,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _tablaTramos(List<TramoConsumoCombustible> tramos) {
    if (tramos.isEmpty) {
      return const Text(
        'No hay detalle de tramos para mostrar.',
        style: TextStyle(color: Colors.white70),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: const TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
        ),
        dataTextStyle: const TextStyle(color: Colors.white70),
        columns: const [
          DataColumn(label: Text('Tramo')),
          DataColumn(label: Text('Hora')),
          DataColumn(label: Text('Km')),
          DataColumn(label: Text('Gal')),
          DataColumn(label: Text('% tanque')),
          DataColumn(label: Text('Vel. prom.')),
          DataColumn(label: Text('Costo')),
        ],
        rows: tramos
            .map(
              (tramo) => DataRow(
                cells: [
                  DataCell(Text('T${tramo.numero}')),
                  DataCell(
                    Text(
                      '${_formatoHora(tramo.inicio)} - ${_formatoHora(tramo.fin)}',
                    ),
                  ),
                  DataCell(Text(tramo.kilometros.toStringAsFixed(2))),
                  DataCell(Text(tramo.galonesConsumidos.toStringAsFixed(2))),
                  DataCell(Text(tramo.porcentajeTanque.toStringAsFixed(2))),
                  DataCell(
                    Text(
                      '${tramo.velocidadPromedioKmh.toStringAsFixed(1)} km/h',
                    ),
                  ),
                  DataCell(
                    Text('S/ ${tramo.costoEstimado.toStringAsFixed(2)}'),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _selectorVehiculo({
    required VehiculoCombustible? value,
    required ValueChanged<VehiculoCombustible?> onChanged,
  }) {
    return DropdownButtonFormField<VehiculoCombustible>(
      initialValue: value,
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
      onChanged: onChanged,
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
      onChanged: (_) {
        if (label == 'Galones') setState(() {});
      },
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

  Widget _tituloSeccion(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 21,
        fontWeight: FontWeight.w700,
      ),
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

  Widget _datoCompacto({
    required IconData icon,
    required String titulo,
    required String valor,
  }) {
    return SizedBox(
      width: 230,
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaMetrica({
    required double ancho,
    required String titulo,
    required String valor,
    required String unidad,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      width: ancho,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color),
          const SizedBox(height: 10),
          Text(
            titulo,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  valor,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unidad,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textoResumen(String titulo, String valor) {
    return SizedBox(
      width: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _normalizarNumero(String value) => value.trim().replaceAll(',', '.');

  String _formatoFecha(DateTime value) =>
      DateFormat('yyyy-MM-dd').format(value);

  String _formatoFechaHora(DateTime value) {
    return DateFormat('yyyy-MM-dd HH:mm').format(value);
  }

  String _formatoHora(DateTime value) => DateFormat('HH:mm').format(value);

  String _mensajeErrorSupabase(Object error) {
    final texto = error.toString();
    if (texto.contains('fk_vehiculo') || texto.contains('schema cache')) {
      return 'Falta ejecutar database/combustible_modulo.sql para relacionar ingresos con vehiculos.';
    }
    return texto;
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
