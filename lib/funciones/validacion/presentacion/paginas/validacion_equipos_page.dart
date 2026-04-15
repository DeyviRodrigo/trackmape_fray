import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import 'package:trackmape_sup/funciones/validacion/presentacion/cubit/validation_cubit.dart';
import 'package:trackmape_sup/funciones/validacion/presentacion/cubit/validation_state.dart';

class ValidacionEquiposPage extends StatelessWidget {
  const ValidacionEquiposPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ValidationCubit()..cargarEquipos(),
      child: const _ValidacionEquiposView(),
    );
  }
}

class _ValidacionEquiposView extends StatelessWidget {
  const _ValidacionEquiposView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ValidationCubit, ValidationState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 960;
            final isMobile = constraints.maxWidth < 700;
            final mapWidget = _MapaValidacion(state: state);
            final listWidget = _ListaDatosCrudos(state: state);
            final mapHeight = isMobile ? 360.0 : 420.0;
            final panelHeight = isMobile ? 240.0 : 170.0;
            final listHeight = isMobile ? 320.0 : 280.0;

            if (isWide) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ControlesSuperiores(state: state),
                    const SizedBox(height: 8),
                    _ResumenCarga(state: state),
                    const SizedBox(height: 12),
                    if (state.status == ValidationStatus.loading || state.cargandoEquipo)
                      const LinearProgressIndicator(color: Colors.orange),
                    if (state.status == ValidationStatus.failure)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          state.error ?? 'Error desconocido',
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: mapWidget),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                _PanelTramoSeleccionado(state: state),
                                const SizedBox(height: 12),
                                Expanded(child: listWidget),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ControlesSuperiores(state: state),
                  const SizedBox(height: 8),
                  _ResumenCarga(state: state),
                  const SizedBox(height: 12),
                  if (state.status == ValidationStatus.loading || state.cargandoEquipo)
                    const LinearProgressIndicator(color: Colors.orange),
                  if (state.status == ValidationStatus.failure)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        state.error ?? 'Error desconocido',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(height: mapHeight, child: mapWidget),
                  const SizedBox(height: 12),
                  SizedBox(height: panelHeight, child: _PanelTramoSeleccionado(state: state)),
                  const SizedBox(height: 12),
                  SizedBox(height: listHeight, child: listWidget),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ControlesSuperiores extends StatelessWidget {
  const _ControlesSuperiores({required this.state});

  final ValidationState state;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Rendimiento de Operador',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Container(
          constraints: BoxConstraints(
            minWidth: screenWidth < 700 ? screenWidth - 32 : 260,
            maxWidth: screenWidth < 700 ? screenWidth - 32 : 420,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.equipoSeleccionadoId,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E1E1E),
              hint: const Text('Seleccionar unidad'),
              items: state.equipos
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
              onChanged: state.equipos.isEmpty
                  ? null
                  : (value) => context.read<ValidationCubit>().seleccionarEquipo(value),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final cubit = context.read<ValidationCubit>();
            final fecha = state.fechaSeleccionada;
            final seleccionada = await showDatePicker(
              context: context,
              initialDate: fecha,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              helpText: 'Seleccionar fecha',
            );
            if (seleccionada != null) {
              await cubit.cambiarFecha(seleccionada);
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange,
            side: const BorderSide(color: Colors.orange),
          ),
          icon: const Icon(Icons.calendar_month),
          label: Text(
            '${state.fechaSeleccionada.year.toString().padLeft(4, '0')}-${state.fechaSeleccionada.month.toString().padLeft(2, '0')}-${state.fechaSeleccionada.day.toString().padLeft(2, '0')}',
          ),
        ),
        Text(
          'Puntos: ${state.totalRegistrosValidos}',
          style: const TextStyle(color: Colors.white70),
        ),
        IconButton(
          onPressed: () => context.read<ValidationCubit>().cargarRendimiento(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Recargar rendimiento',
        ),
      ],
    );
  }
}

class _ResumenCarga extends StatelessWidget {
  const _ResumenCarga({required this.state});

  final ValidationState state;

  @override
  Widget build(BuildContext context) {
    final resumen = state.resumen;

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _chip(
          'Unidades tracker: ${state.equipos.length}',
          color: Colors.white24,
        ),
        _chip(
          'Registros brutos: ${state.totalRegistrosBrutos}',
          color: Colors.white24,
        ),
        _chip(
          'Registros validos: ${state.totalRegistrosValidos}',
          color: Colors.white24,
        ),
        _chip(
          'Km: ${resumen?.distanciaTotalKm.toStringAsFixed(2) ?? '0.00'}',
          color: Colors.lightGreenAccent.withOpacity(0.15),
          borderColor: Colors.lightGreenAccent,
        ),
        _chip(
          'Vel promedio: ${resumen?.velocidadPromedioKmh.toStringAsFixed(1) ?? '0.0'} km/h',
          color: Colors.orangeAccent.withOpacity(0.15),
          borderColor: Colors.orangeAccent,
        ),
        _chip(
          'Vel corregida: ${state.velocidadCorregidaPromedioKmh.toStringAsFixed(1)} km/h',
          color: Colors.blueAccent.withOpacity(0.12),
          borderColor: Colors.blueAccent,
        ),
        _chip(
          'Paradas: ${resumen?.paradasDetectadas ?? 0}',
          color: Colors.redAccent.withOpacity(0.12),
          borderColor: Colors.redAccent,
        ),
        _chip('Tramos: ${state.segmentos.length}', color: Colors.white24),
        _chip(
          'Tramos descartados: ${state.tramosDescartados}',
          color: Colors.grey.withOpacity(0.15),
          borderColor: Colors.grey,
        ),
      ],
    );
  }

  Widget _chip(
    String texto, {
    required Color color,
    Color borderColor = Colors.white24,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        texto,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}

class _MapaValidacion extends StatelessWidget {
  const _MapaValidacion({required this.state});

  final ValidationState state;

  @override
  Widget build(BuildContext context) {
    final puntos = state.puntos
        .map((p) => ll.LatLng(p.latitud, p.longitud))
        .toList();
    final centro = _calcularCentro(puntos) ?? const ll.LatLng(-15.488405, -70.150497);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: centro,
              initialZoom: 15,
              onTap: (_, point) {
                context.read<ValidationCubit>().seleccionarSegmentoMasCercano(
                  latitud: point.latitude,
                  longitud: point.longitude,
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
              ),
              if (state.segmentos.isNotEmpty)
                PolylineLayer(
                  polylines: state.segmentos
                      .where((segmento) => segmento.esVisible)
                      .map(
                        (segmento) => Polyline(
                          points: [
                            ll.LatLng(
                              segmento.latitudInicioDibujo,
                              segmento.longitudInicioDibujo,
                            ),
                            ll.LatLng(
                              segmento.latitudFinDibujo,
                              segmento.longitudFinDibujo,
                            ),
                          ],
                          color: segmento.color,
                          strokeWidth: state.segmentoSeleccionado == segmento
                              ? 6
                              : segmento.estado == 'descartado'
                                  ? 2
                                  : 4,
                          strokeCap: StrokeCap.round,
                          strokeJoin: StrokeJoin.round,
                        ),
                      )
                      .toList(),
                ),
              MarkerLayer(
                markers: [
                  if (puntos.isNotEmpty)
                    Marker(
                      point: puntos.first,
                      width: 28,
                      height: 28,
                      child: const Icon(
                        Icons.play_circle_fill,
                        color: Colors.lightGreenAccent,
                        size: 24,
                      ),
                    ),
                  if (puntos.length > 1)
                    Marker(
                      point: puntos.last,
                      width: 22,
                      height: 22,
                      child: const Icon(
                        Icons.radio_button_checked,
                        color: Colors.lightBlueAccent,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LeyendaItem(color: Colors.lightGreenAccent, texto: 'Normal'),
                  SizedBox(height: 4),
                  _LeyendaItem(color: Colors.orangeAccent, texto: 'Atencion'),
                  SizedBox(height: 4),
                  _LeyendaItem(color: Colors.redAccent, texto: 'Critico'),
                  SizedBox(height: 4),
                  _LeyendaItem(color: Colors.grey, texto: 'Descartado'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ll.LatLng? _calcularCentro(List<ll.LatLng> puntos) {
    if (puntos.isEmpty) return null;
    var lat = 0.0;
    var lon = 0.0;
    for (final punto in puntos) {
      lat += punto.latitude;
      lon += punto.longitude;
    }
    return ll.LatLng(lat / puntos.length, lon / puntos.length);
  }
}

class _LeyendaItem extends StatelessWidget {
  const _LeyendaItem({
    required this.color,
    required this.texto,
  });

  final Color color;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 4,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          texto,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

class _ListaDatosCrudos extends StatelessWidget {
  const _ListaDatosCrudos({required this.state});

  final ValidationState state;

  @override
  Widget build(BuildContext context) {
    if (state.detalles.isEmpty) {
      return const Center(
        child: Text(
          'No hay datos para la unidad seleccionada.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListView.separated(
        itemCount: state.detalles.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
        itemBuilder: (context, index) {
          final detalle = state.detalles[index];
          return ListTile(
            onTap: () {
              final segmento = state.segmentos.firstWhere(
                (item) =>
                    item.fin.tiempo == detalle.punto.tiempo &&
                    item.fin.latitud == detalle.punto.latitud &&
                    item.fin.longitud == detalle.punto.longitud,
                orElse: () => state.segmentos[index.clamp(0, state.segmentos.length - 1)],
              );
              context.read<ValidationCubit>().seleccionarSegmento(segmento);
            },
            dense: true,
            leading: Icon(
              Icons.timeline,
              color: detalle.color,
              size: 18,
            ),
            title: Text(
              '${detalle.tiempoInicio.toIso8601String()} -> ${detalle.punto.tiempo.toIso8601String()}',
              style: const TextStyle(fontSize: 12),
            ),
            subtitle: Text(
              '${detalle.velocidadKmh.toStringAsFixed(1)} km/h  |  ${detalle.distanciaMetros.toStringAsFixed(1)} m  |  ${detalle.estado}  |  ${detalle.motivo}',
              style: const TextStyle(fontSize: 11, color: Colors.white60),
            ),
            trailing: Text(
              '${detalle.deltaSegundos}s',
              style: TextStyle(
                fontSize: 11,
                color: detalle.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PanelTramoSeleccionado extends StatelessWidget {
  const _PanelTramoSeleccionado({required this.state});

  final ValidationState state;

  @override
  Widget build(BuildContext context) {
    final segmento = state.segmentoSeleccionado;
    if (segmento == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Toca un tramo para ver su detalle.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final deltaSegundos =
        segmento.fin.tiempo.difference(segmento.inicio.tiempo).inSeconds;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: segmento.color, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tramo seleccionado',
            style: TextStyle(
              color: segmento.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inicio: ${segmento.inicio.tiempo.toIso8601String()}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            'Fin: ${segmento.fin.tiempo.toIso8601String()}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'Coord. inicio: ${segmento.inicio.latitud.toStringAsFixed(6)}, ${segmento.inicio.longitud.toStringAsFixed(6)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            'Coord. fin: ${segmento.fin.latitud.toStringAsFixed(6)}, ${segmento.fin.longitud.toStringAsFixed(6)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _datoMini('Segundos', '$deltaSegundos s'),
              _datoMini('Metros', '${segmento.distanciaMetros.toStringAsFixed(1)} m'),
              _datoMini('Velocidad', '${segmento.velocidadKmh.toStringAsFixed(1)} km/h'),
              _datoMini('Estado', segmento.estado),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Motivo: ${segmento.motivo}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _datoMini(String titulo, String valor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$titulo: $valor',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
