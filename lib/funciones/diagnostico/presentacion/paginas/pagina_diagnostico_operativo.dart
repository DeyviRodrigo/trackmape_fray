import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/core/mapas/coordenadas_operacion.dart';
import 'package:trackmape_sup/funciones/diagnostico/dominio/servicios/servicio_diagnostico_operativo.dart';
import 'package:trackmape_sup/funciones/gis/datos/repositorios/repositorio_gis.dart';
import 'package:trackmape_sup/funciones/gis/presentacion/widgets/capas_gis_mapa.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/modelos/modelo_equipo.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';

class PaginaDiagnosticoOperativo extends StatefulWidget {
  const PaginaDiagnosticoOperativo({super.key, required this.empresaInicial});

  final String empresaInicial;

  @override
  State<PaginaDiagnosticoOperativo> createState() =>
      _PaginaDiagnosticoOperativoState();
}

class _PaginaDiagnosticoOperativoState
    extends State<PaginaDiagnosticoOperativo> {
  final RepositorioMonitoreo _repositorioMonitoreo = RepositorioMonitoreo();
  final RepositorioGis _repositorioGis = RepositorioGis();
  final ServicioDiagnosticoOperativo _servicioDiagnostico =
      const ServicioDiagnosticoOperativo();

  late String _empresaSeleccionada;
  late DateTime _fechaSeleccionada;
  String? _equipoSeleccionado;
  late Future<_DatosDiagnosticoOperativoVista> _future;
  List<EmpresaDashboardMonitoreo> _empresasDashboard =
      RepositorioMonitoreo.empresasDashboardFrancisco;

  @override
  void initState() {
    super.initState();
    _empresaSeleccionada = widget.empresaInicial;
    _fechaSeleccionada = DateTime.now();
    _future = _cargarDatos();
    _cargarEmpresas();
  }

  @override
  void didUpdateWidget(covariant PaginaDiagnosticoOperativo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.empresaInicial == widget.empresaInicial) return;
    _empresaSeleccionada = widget.empresaInicial;
    _equipoSeleccionado = null;
    _future = _cargarDatos();
  }

  Future<void> _cargarEmpresas() async {
    final empresas = await _repositorioMonitoreo.obtenerEmpresasDashboard();
    if (!mounted) return;

    setState(() {
      _empresasDashboard = empresas;
      if (!_empresasDashboard.any(
        (empresa) => empresa.id == _empresaSeleccionada,
      )) {
        _empresaSeleccionada = _empresasDashboard.isNotEmpty
            ? _empresasDashboard.first.id
            : RepositorioMonitoreo.empresaMonitoreoFija;
        _equipoSeleccionado = null;
        _future = _cargarDatos();
      }
    });
  }

  Future<_DatosDiagnosticoOperativoVista> _cargarDatos() async {
    final equiposRaw = await _repositorioMonitoreo.obtenerEquiposRaw(
      tipoEquipoControl: RepositorioMonitoreo.tipoEquipoSeeedWioTrackerL1,
      fkEmpresa: _empresaSeleccionada,
      fkSede: RepositorioMonitoreo.sedeMonitoreoFija,
    );
    final equipos = equiposRaw.map(ModeloEquipo.fromJson).toList()
      ..sort((a, b) => a.nombreMostrar.compareTo(b.nombreMostrar));

    final trayectoria = await _repositorioMonitoreo.obtenerTrayectoriaPorFecha(
      _fechaSeleccionada,
      tipoEquipoControl: RepositorioMonitoreo.tipoEquipoSeeedWioTrackerL1,
      fkEmpresa: _empresaSeleccionada,
      fkSede: RepositorioMonitoreo.sedeMonitoreoFija,
    );

    final datosGis = await _repositorioGis.obtenerDatosOperativos(
      fkEmpresa: _empresaSeleccionada,
      fkSede: RepositorioMonitoreo.sedeMonitoreoFija,
    );

    final resultado = _servicioDiagnostico.procesar(
      fecha: _fechaSeleccionada,
      equipos: equipos,
      trayectoria: trayectoria,
      rutas: datosGis.rutas,
      areas: datosGis.areas,
      puntos: datosGis.puntos,
      equipoIdFiltro: _equipoSeleccionado,
    );

    return _DatosDiagnosticoOperativoVista(
      equipos: equipos,
      datosGis: datosGis,
      resultado: resultado,
    );
  }

  void _recargar() {
    _repositorioGis.limpiarCache();
    setState(() => _future = _cargarDatos());
  }

  void _cambiarFecha(int dias) {
    setState(() {
      _fechaSeleccionada = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day + dias,
      );
      _future = _cargarDatos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DatosDiagnosticoOperativoVista>(
      future: _future,
      builder: (context, snapshot) {
        final datos = snapshot.data;
        final cargando = snapshot.connectionState == ConnectionState.waiting;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 820;
            return Container(
              color: const Color(0xFF101010),
              child: isMobile
                  ? Column(
                      children: [
                        Expanded(
                          child: _buildMapa(datos: datos, cargando: cargando),
                        ),
                        SizedBox(
                          height: 330,
                          child: _buildPanel(datos: datos, cargando: cargando),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildMapa(datos: datos, cargando: cargando),
                        ),
                        SizedBox(
                          width: 410,
                          child: _buildPanel(datos: datos, cargando: cargando),
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildMapa({
    required _DatosDiagnosticoOperativoVista? datos,
    required bool cargando,
  }) {
    final capasGis = datos == null
        ? CapasGisMapa.vacias
        : construirCapasGisMapa(
            datos.datosGis,
            mostrarAreas: true,
            mostrarRutas: true,
          );
    final lineasDiagnostico = datos == null
        ? const <Polyline>[]
        : _construirLineasDiagnostico(datos.resultado);
    final marcadoresDiagnostico = datos == null
        ? const <Marker>[]
        : _construirMarcadoresDiagnostico(datos.resultado);

    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: puntoTrabajoLatLng,
            initialZoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
            ),
            if (capasGis.poligonos.isNotEmpty)
              PolygonLayer(polygons: capasGis.poligonos),
            if (capasGis.rutas.isNotEmpty)
              PolylineLayer(polylines: capasGis.rutas),
            if (lineasDiagnostico.isNotEmpty)
              PolylineLayer(polylines: lineasDiagnostico),
            MarkerLayer(
              markers: [...capasGis.marcadores, ...marcadoresDiagnostico],
            ),
          ],
        ),
        Positioned(top: 14, left: 14, child: _buildLeyenda(cargando)),
      ],
    );
  }

  Widget _buildLeyenda(bool cargando) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cargando) ...[
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
          ],
          const Text(
            'Diagnostico: naranja GPS limpio, rojo sin ruta',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel({
    required _DatosDiagnosticoOperativoVista? datos,
    required bool cargando,
  }) {
    final resumenes = datos?.resultado.resumenes ?? const [];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF151515),
        border: Border(left: BorderSide(color: Colors.white12)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const Text(
            'Diagnostico Operativo',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Prueba de rutas, areas y saltos GPS. No guarda resultados.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 14),
          _buildSelectorEmpresa(),
          const SizedBox(height: 10),
          _buildSelectorFecha(),
          const SizedBox(height: 10),
          _buildSelectorEquipo(datos?.equipos ?? const []),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: cargando ? null : _recargar,
            icon: const Icon(Icons.refresh),
            label: const Text('Recalcular'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          if (cargando)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            )
          else if (datos == null || resumenes.isEmpty)
            _buildVacio()
          else ...[
            _buildResumenGeneral(datos.resultado),
            const SizedBox(height: 10),
            ...resumenes.map(_buildResumenEquipo),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectorEmpresa() {
    return _contenedorCampo(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _empresaSeleccionada,
          isExpanded: true,
          dropdownColor: const Color(0xFF1D1D1D),
          iconEnabledColor: Colors.orange,
          style: const TextStyle(color: Colors.orange),
          items: _empresasDashboard
              .map(
                (empresa) => DropdownMenuItem<String>(
                  value: empresa.id,
                  child: Text(empresa.nombre, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (valor) {
            if (valor == null || valor == _empresaSeleccionada) return;
            setState(() {
              _empresaSeleccionada = valor;
              _equipoSeleccionado = null;
              _future = _cargarDatos();
            });
          },
        ),
      ),
    );
  }

  Widget _buildSelectorFecha() {
    return Row(
      children: [
        IconButton(
          onPressed: () => _cambiarFecha(-1),
          icon: const Icon(Icons.chevron_left, color: Colors.orange),
          tooltip: 'Dia anterior',
        ),
        Expanded(
          child: _contenedorCampo(
            child: Text(
              _formatearFecha(_fechaSeleccionada),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => _cambiarFecha(1),
          icon: const Icon(Icons.chevron_right, color: Colors.orange),
          tooltip: 'Dia siguiente',
        ),
      ],
    );
  }

  Widget _buildSelectorEquipo(List<ModeloEquipo> equipos) {
    final existeSeleccion = equipos.any(
      (equipo) => equipo.id == _equipoSeleccionado,
    );
    final valor = existeSeleccion ? _equipoSeleccionado : null;

    return _contenedorCampo(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: valor,
          isExpanded: true,
          dropdownColor: const Color(0xFF1D1D1D),
          iconEnabledColor: Colors.orange,
          style: const TextStyle(color: Colors.white),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Todos los volquetes'),
            ),
            ...equipos.map(
              (equipo) => DropdownMenuItem<String?>(
                value: equipo.id,
                child: Text(
                  equipo.nombreMostrar,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: (valor) {
            setState(() {
              _equipoSeleccionado = valor;
              _future = _cargarDatos();
            });
          },
        ),
      ),
    );
  }

  Widget _contenedorCampo({required Widget child}) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: child,
    );
  }

  Widget _buildVacio() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _decoracionTarjeta(),
      child: const Text(
        'No hay datos historicos para la fecha o equipo seleccionado.',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildResumenGeneral(ResultadoDiagnosticoOperativo resultado) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _decoracionTarjeta(color: Colors.orange),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen general',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _dato('Equipos analizados', '${resultado.resumenes.length}'),
          _dato('Puntos crudos', '${resultado.puntosCrudosTotal}'),
          _dato('Puntos limpios', '${resultado.puntosLimpiosTotal}'),
          _dato('Saltos descartados', '${resultado.puntosDescartadosTotal}'),
          _dato('Rutas configuradas', '${resultado.rutas.length}'),
          _dato('Areas configuradas', '${resultado.areas.length}'),
        ],
      ),
    );
  }

  Widget _buildResumenEquipo(ResumenDiagnosticoEquipo resumen) {
    final color = resumen.requiereMasRutas
        ? Colors.redAccent
        : Colors.greenAccent;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _decoracionTarjeta(color: color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  resumen.equipo.nombreMostrar,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${resumen.porcentajeAcople.toStringAsFixed(0)}%',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _dato(
            'Crudos / limpios',
            '${resumen.puntosCrudos} / ${resumen.puntosLimpios}',
          ),
          _dato('Descartados', '${resumen.puntosDescartados}'),
          _dato('Acoplados a ruta', '${resumen.puntosAcoplados}'),
          _dato('Sin ruta cercana', '${resumen.puntosSinRuta}'),
          _dato('Ambiguos', '${resumen.puntosAmbiguos}'),
          _dato('Distancia limpia', _km(resumen.distanciaLimpiaMetros)),
          _dato('Distancia acoplada', _km(resumen.distanciaAcopladaMetros)),
          _dato('Movimiento', _duracion(resumen.tiempoMovimiento)),
          _dato('Detenido', _duracion(resumen.tiempoDetenido)),
          if (resumen.rutasUsadas.isNotEmpty)
            _dato(
              'Rutas usadas',
              resumen.rutasUsadas.map((e) => e.nombre).join(', '),
            ),
          if (resumen.areasVisitadas.isNotEmpty)
            _dato(
              'Areas visitadas',
              resumen.areasVisitadas.map((e) => e.nombre).join(', '),
            ),
          if (resumen.permanencias.isNotEmpty)
            _dato('Permanencias', '${resumen.permanencias.length} area(s)'),
          if (resumen.requiereMasRutas) ...[
            const SizedBox(height: 8),
            const Text(
              'Advertencia: faltan caminos o el radio de acople no cubre bien esta trayectoria.',
              style: TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              titulo,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _decoracionTarjeta({Color color = Colors.white24}) {
    return BoxDecoration(
      color: const Color(0xFF101010),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.65)),
    );
  }

  List<Polyline> _construirLineasDiagnostico(
    ResultadoDiagnosticoOperativo resultado,
  ) {
    final lineas = <Polyline>[];
    for (final resumen in resultado.resumenes) {
      final puntos = resumen.asignaciones
          .map((item) => ll.LatLng(item.punto.latitud, item.punto.longitud))
          .toList();
      if (puntos.length < 2) continue;
      lineas.add(
        Polyline(
          points: puntos,
          color: Colors.orange.withValues(alpha: 0.82),
          strokeWidth: _equipoSeleccionado == null ? 3 : 4,
        ),
      );
    }
    return lineas;
  }

  List<Marker> _construirMarcadoresDiagnostico(
    ResultadoDiagnosticoOperativo resultado,
  ) {
    final marcadores = <Marker>[];
    var marcadoresRevision = 0;
    for (final resumen in resultado.resumenes) {
      for (final asignacion in resumen.asignaciones) {
        if (asignacion.estado == EstadoAcopleRutaDiagnostico.acoplado) {
          continue;
        }
        if (marcadoresRevision >= 350) continue;
        marcadoresRevision++;
        final color = asignacion.estado == EstadoAcopleRutaDiagnostico.ambiguo
            ? Colors.yellowAccent
            : Colors.redAccent;
        marcadores.add(
          Marker(
            point: ll.LatLng(
              asignacion.punto.latitud,
              asignacion.punto.longitud,
            ),
            width: 16,
            height: 16,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
            ),
          ),
        );
      }

      if (resumen.asignaciones.isEmpty) continue;
      final ultimo = resumen.asignaciones.last.punto;
      marcadores.add(
        Marker(
          point: ll.LatLng(ultimo.latitud, ultimo.longitud),
          width: 110,
          height: 32,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Text(
              resumen.equipo.nombreMostrar,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    return marcadores;
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  String _km(double metros) => '${(metros / 1000).toStringAsFixed(2)} km';

  String _duracion(Duration duracion) {
    final horas = duracion.inHours;
    final minutos = duracion.inMinutes.remainder(60);
    if (horas > 0) return '${horas}h ${minutos}m';
    return '${minutos}m';
  }
}

class _DatosDiagnosticoOperativoVista {
  const _DatosDiagnosticoOperativoVista({
    required this.equipos,
    required this.datosGis,
    required this.resultado,
  });

  final List<ModeloEquipo> equipos;
  final DatosGisOperativos datosGis;
  final ResultadoDiagnosticoOperativo resultado;
}
