import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:trackmape_sup/core/mapas/coordenadas_operacion.dart';
import 'package:trackmape_sup/funciones/gis/datos/modelos/modelo_gis.dart';
import 'package:trackmape_sup/funciones/gis/datos/repositorios/repositorio_gis.dart';
import 'package:trackmape_sup/funciones/gis/datos/servicios/importador_kml.dart';
import 'package:trackmape_sup/funciones/gis/presentacion/widgets/capas_gis_mapa.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';

class PaginaConfiguracionOperativa extends StatefulWidget {
  const PaginaConfiguracionOperativa({super.key, required this.empresaInicial});

  final String empresaInicial;

  @override
  State<PaginaConfiguracionOperativa> createState() =>
      _PaginaConfiguracionOperativaState();
}

class _PaginaConfiguracionOperativaState
    extends State<PaginaConfiguracionOperativa> {
  final RepositorioGis _repositorio = RepositorioGis();
  final RepositorioMonitoreo _repositorioMonitoreo = RepositorioMonitoreo();
  final MapController _mapController = MapController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _prioridadController = TextEditingController(
    text: '0',
  );
  final FocusNode _tipoFocusNode = FocusNode();

  static const List<String> _categorias = ['area', 'ruta', 'punto'];
  static const List<String> _tiposBase = [
    'Carga',
    'Descarga',
    'Corte',
    'Chute',
    'Desmonte',
    'Caranchero',
    'Estacionamiento',
    'Ruta acarreo',
    'Ruta retorno',
    'Taller',
    'Ingreso',
    'Salida',
    'Zona restringida',
  ];
  static const List<String> _colores = [
    '#ff9800',
    '#00bcd4',
    '#4caf50',
    '#f44336',
    '#9c27b0',
    '#ffeb3b',
    '#03a9f4',
    '#ffffff',
  ];

  late String _empresaSeleccionada;
  String? _sedeSeleccionada;
  String _categoria = 'area';
  String _color = _colores.first;
  bool _activo = true;
  bool _guardando = false;
  bool _importandoKml = false;
  late Future<DatosGisOperativos> _datosFuture;
  late Future<List<SedeOperativa>> _sedesFuture;
  List<EmpresaDashboardMonitoreo> _empresasDashboard =
      RepositorioMonitoreo.empresasDashboardFrancisco;
  final List<ll.LatLng> _puntosDibujo = [];
  ElementoOperativo? _elementoEditando;

  @override
  void initState() {
    super.initState();
    _empresaSeleccionada = widget.empresaInicial;
    _tipoController.text = 'Carga';
    _datosFuture = _crearDatosFuture();
    _sedesFuture = _repositorio.obtenerSedesPorEmpresa(_empresaSeleccionada);
    _cargarEmpresasDashboard();
  }

  @override
  void didUpdateWidget(covariant PaginaConfiguracionOperativa oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.empresaInicial == widget.empresaInicial) return;
    _empresaSeleccionada = widget.empresaInicial;
    _sedeSeleccionada = null;
    _recargarTodo(limpiarDibujo: false);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tipoController.dispose();
    _descripcionController.dispose();
    _prioridadController.dispose();
    _tipoFocusNode.dispose();
    super.dispose();
  }

  Future<DatosGisOperativos> _crearDatosFuture() {
    return _repositorio.obtenerDatosOperativos(
      fkEmpresa: _empresaSeleccionada,
      fkSede: _sedeSeleccionada,
      soloActivos: false,
    );
  }

  Future<void> _cargarEmpresasDashboard() async {
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
        _sedeSeleccionada = null;
        _datosFuture = _crearDatosFuture();
        _sedesFuture = _repositorio.obtenerSedesPorEmpresa(
          _empresaSeleccionada,
        );
      }
    });
  }

  void _recargarTodo({bool limpiarDibujo = true}) {
    _repositorio.limpiarCache();
    setState(() {
      if (limpiarDibujo) {
        _puntosDibujo.clear();
        _elementoEditando = null;
      }
      _datosFuture = _crearDatosFuture();
      _sedesFuture = _repositorio.obtenerSedesPorEmpresa(_empresaSeleccionada);
    });
  }

  void _agregarPunto(ll.LatLng punto) {
    setState(() {
      if (_categoria == 'punto') {
        _puntosDibujo
          ..clear()
          ..add(punto);
      } else {
        _puntosDibujo.add(punto);
      }
    });
  }

  void _nuevoDibujo() {
    setState(() {
      _elementoEditando = null;
      _puntosDibujo.clear();
      _nombreController.clear();
      _descripcionController.clear();
      _prioridadController.text = '0';
      _activo = true;
    });
  }

  void _cambiarCategoria(String categoria) {
    setState(() {
      _categoria = categoria;
      _puntosDibujo.clear();
      if (categoria == 'ruta') {
        _tipoController.text = 'Ruta acarreo';
        _color = '#00bcd4';
      } else if (categoria == 'punto') {
        _tipoController.text = 'Taller';
        _color = '#4caf50';
      } else {
        _tipoController.text = 'Carga';
        _color = '#ff9800';
      }
    });
  }

  Future<void> _guardar() async {
    final error = _validarDibujo();
    if (error != null) {
      _mostrarMensaje(error, esError: true);
      return;
    }

    final nombre = _nombreController.text.trim();
    final tipo = _tipoController.text.trim();
    if (nombre.isEmpty || tipo.isEmpty) {
      _mostrarMensaje('Completa nombre y tipo operativo.', esError: true);
      return;
    }

    Map<String, dynamic> geojson;
    if (_categoria == 'area') {
      geojson = construirGeojsonArea(_puntosDibujo);
    } else if (_categoria == 'ruta') {
      geojson = construirGeojsonRuta(_puntosDibujo);
    } else {
      geojson = construirGeojsonPunto(_puntosDibujo.first);
    }

    setState(() => _guardando = true);
    try {
      final elementoEditando = _elementoEditando;
      if (elementoEditando == null) {
        await _repositorio.crearElementoOperativo(
          fkEmpresa: _empresaSeleccionada,
          fkSede: _sedeSeleccionada,
          categoria: _categoria,
          tipoOperativo: tipo,
          nombre: nombre,
          descripcion: _descripcionController.text,
          color: _color,
          prioridad: int.tryParse(_prioridadController.text.trim()) ?? 0,
          activo: _activo,
          geojson: geojson,
        );
      } else {
        await _repositorio.actualizarElementoOperativo(
          idElemento: elementoEditando.id,
          fkEmpresa: _empresaSeleccionada,
          fkSede: _sedeSeleccionada,
          categoria: _categoria,
          tipoOperativo: tipo,
          nombre: nombre,
          descripcion: _descripcionController.text,
          color: _color,
          prioridad: int.tryParse(_prioridadController.text.trim()) ?? 0,
          activo: _activo,
          geojson: geojson,
        );
      }
      if (!mounted) return;
      _mostrarMensaje(
        elementoEditando == null
            ? 'Elemento guardado correctamente.'
            : 'Elemento actualizado correctamente.',
      );
      _nuevoDibujo();
      _recargarTodo(limpiarDibujo: false);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('No se pudo guardar: $e', esError: true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _abrirImportacionKml() async {
    final items = await showDialog<List<ItemImportacionKml>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _DialogoImportacionKml(colores: _colores);
      },
    );

    if (items == null || items.isEmpty) return;
    await _guardarItemsKml(items);
  }

  Future<void> _guardarItemsKml(List<ItemImportacionKml> items) async {
    final seleccionados = items.where((item) => item.seleccionado).toList();
    if (seleccionados.isEmpty) {
      _mostrarMensaje('Selecciona al menos un elemento KML.', esError: true);
      return;
    }

    setState(() => _importandoKml = true);
    var guardados = 0;
    try {
      for (final item in seleccionados) {
        await _repositorio.crearElementoOperativo(
          fkEmpresa: _empresaSeleccionada,
          fkSede: _sedeSeleccionada,
          categoria: item.categoria,
          tipoOperativo: item.tipoOperativo,
          nombre: item.nombre,
          descripcion: item.nombreOriginal.isEmpty
              ? 'Importado desde KML'
              : 'Importado desde KML: ${item.nombreOriginal}',
          color: item.color,
          prioridad: item.prioridad,
          activo: item.activo,
          geojson: item.geojson,
        );
        guardados++;
      }

      if (!mounted) return;
      _mostrarMensaje('KML importado: $guardados elemento(s) guardado(s).');
      _recargarTodo(limpiarDibujo: false);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje(
        'Se guardaron $guardados, pero fallo la importacion: $e',
        esError: true,
      );
      _recargarTodo(limpiarDibujo: false);
    } finally {
      if (mounted) setState(() => _importandoKml = false);
    }
  }

  String? _validarDibujo() {
    if (_categoria == 'area' && _puntosDibujo.length < 3) {
      return 'Un area necesita minimo 3 puntos.';
    }
    if (_categoria == 'ruta' && _puntosDibujo.length < 2) {
      return 'Una ruta necesita minimo 2 puntos.';
    }
    if (_categoria == 'punto' && _puntosDibujo.isEmpty) {
      return 'Toca el mapa para definir el punto.';
    }
    return null;
  }

  void _editarElemento(ElementoOperativo elemento) {
    final puntos = elemento.esArea
        ? elemento.puntosPoligono
        : elemento.esRuta
        ? elemento.puntosLinea
        : [if (elemento.punto != null) elemento.punto!];

    if (puntos.isEmpty) {
      _mostrarMensaje(
        'Este elemento no tiene geometria valida para editar.',
        esError: true,
      );
      return;
    }

    setState(() {
      _elementoEditando = elemento;
      _empresaSeleccionada = elemento.fkEmpresa;
      _sedeSeleccionada = elemento.fkSede;
      _categoria = elemento.categoria;
      _tipoController.text = elemento.tipoOperativo;
      _nombreController.text = elemento.nombre;
      _descripcionController.text = elemento.descripcion;
      _prioridadController.text = elemento.prioridad.toString();
      _color = elemento.color;
      _activo = elemento.activo;
      _puntosDibujo
        ..clear()
        ..addAll(puntos);
    });

    final centro = elemento.centro ?? puntos.first;
    _mapController.move(centro, _mapController.camera.zoom);
    _mostrarMensaje('Editando "${elemento.nombre}".');
  }

  Future<void> _cambiarActivo(ElementoOperativo elemento) async {
    try {
      await _repositorio.actualizarActivoElemento(
        idElemento: elemento.id,
        activo: !elemento.activo,
      );
      if (!mounted) return;
      _mostrarMensaje(
        elemento.activo ? 'Elemento desactivado.' : 'Elemento activado.',
      );
      _recargarTodo(limpiarDibujo: false);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('No se pudo actualizar: $e', esError: true);
    }
  }

  Future<void> _eliminar(ElementoOperativo elemento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1B1B),
          title: const Text(
            'Eliminar elemento',
            style: TextStyle(color: Colors.orange),
          ),
          content: Text(
            'Se eliminara "${elemento.nombre}" de la configuracion operativa.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await _repositorio.eliminarElemento(idElemento: elemento.id);
      if (!mounted) return;
      _mostrarMensaje('Elemento eliminado.');
      _recargarTodo(limpiarDibujo: false);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('No se pudo eliminar: $e', esError: true);
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.redAccent : Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 820;
        final contenido = isMobile
            ? Column(
                children: [
                  SizedBox(height: 430, child: _buildMapa()),
                  Expanded(child: _buildPanelControl(isMobile: true)),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _buildMapa()),
                  SizedBox(
                    width: 390,
                    child: _buildPanelControl(isMobile: false),
                  ),
                ],
              );

        return Container(color: const Color(0xFF101010), child: contenido);
      },
    );
  }

  Widget _buildMapa() {
    return FutureBuilder<DatosGisOperativos>(
      future: _datosFuture,
      builder: (context, snapshot) {
        final datos = snapshot.data ?? DatosGisOperativos.vacio;
        final capas = construirCapasGisMapa(
          datos,
          mostrarAreas: true,
          mostrarRutas: true,
        );
        final preview = _construirPreview();

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: puntoTrabajoLatLng,
                initialZoom: 15,
                onTap: (_, punto) => _agregarPunto(punto),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                ),
                if (capas.poligonos.isNotEmpty)
                  PolygonLayer(polygons: capas.poligonos),
                if (preview.poligonos.isNotEmpty)
                  PolygonLayer(polygons: preview.poligonos),
                if (capas.rutas.isNotEmpty)
                  PolylineLayer(polylines: capas.rutas),
                if (preview.rutas.isNotEmpty)
                  PolylineLayer(polylines: preview.rutas),
                MarkerLayer(
                  markers: [...capas.marcadores, ...preview.marcadores],
                ),
              ],
            ),
            Positioned(top: 14, left: 14, child: _buildIndicadorDibujo()),
          ],
        );
      },
    );
  }

  CapasGisMapa _construirPreview() {
    final color = colorDesdeHex(_color, fallback: Colors.orangeAccent);
    final poligonos = <Polygon>[];
    final rutas = <Polyline>[];
    final marcadores = <Marker>[];

    if (_categoria == 'area') {
      if (_puntosDibujo.length >= 3) {
        poligonos.add(
          Polygon(
            points: _puntosDibujo,
            color: color.withOpacity(0.22),
            borderColor: color,
            borderStrokeWidth: 3,
          ),
        );
      } else if (_puntosDibujo.length >= 2) {
        rutas.add(
          Polyline(points: _puntosDibujo, color: color, strokeWidth: 3),
        );
      }
    } else if (_categoria == 'ruta' && _puntosDibujo.length >= 2) {
      rutas.add(Polyline(points: _puntosDibujo, color: color, strokeWidth: 4));
    }

    for (var i = 0; i < _puntosDibujo.length; i++) {
      marcadores.add(
        Marker(
          point: _puntosDibujo[i],
          width: 28,
          height: 28,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Text(
              '${i + 1}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return CapasGisMapa(
      poligonos: poligonos,
      rutas: rutas,
      marcadores: marcadores,
    );
  }

  Widget _buildIndicadorDibujo() {
    final editando = _elementoEditando;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.touch_app, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Text(
            editando == null
                ? 'Toca el mapa para dibujar: $_categoria (${_puntosDibujo.length})'
                : 'Editando: ${editando.nombre} (${_puntosDibujo.length})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelControl({required bool isMobile}) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF151515),
        border: Border(left: BorderSide(color: Colors.white12)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTituloPanel(),
            const SizedBox(height: 14),
            _buildFormulario(),
            const SizedBox(height: 14),
            _buildBotonesDibujo(),
            const SizedBox(height: 16),
            _buildListaElementos(),
          ],
        ),
      ),
    );
  }

  Widget _buildTituloPanel() {
    final editando = _elementoEditando;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          editando == null ? 'Configuracion Operativa' : 'Editando elemento',
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          editando == null
              ? 'Crea areas, rutas y puntos fijos sin copiar GeoJSON.'
              : 'Corrige datos o redibuja puntos y guarda la actualizacion.',
          style: TextStyle(color: Colors.white.withOpacity(0.62), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFormulario() {
    return Column(
      children: [
        _buildDropdownEmpresa(),
        const SizedBox(height: 10),
        _buildDropdownSede(),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDropdownCategoria()),
            const SizedBox(width: 10),
            Expanded(child: _buildCampoPrioridad()),
          ],
        ),
        const SizedBox(height: 10),
        _buildCampoTexto(
          controller: _nombreController,
          label: 'Nombre',
          icon: Icons.label,
        ),
        const SizedBox(height: 10),
        _buildCampoTipo(),
        const SizedBox(height: 10),
        _buildCampoTexto(
          controller: _descripcionController,
          label: 'Descripcion',
          icon: Icons.notes,
          maxLines: 2,
        ),
        const SizedBox(height: 10),
        _buildSelectorColor(),
        const SizedBox(height: 8),
        SwitchListTile(
          value: _activo,
          onChanged: (valor) => setState(() => _activo = valor),
          activeColor: Colors.orange,
          contentPadding: EdgeInsets.zero,
          title: const Text('Activo', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildDropdownEmpresa() {
    return DropdownButtonFormField<String>(
      value: _empresaSeleccionada,
      dropdownColor: const Color(0xFF1D1D1D),
      decoration: _decoracionCampo('Empresa', Icons.business),
      style: const TextStyle(color: Colors.white),
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
          _sedeSeleccionada = null;
          _puntosDibujo.clear();
        });
        _recargarTodo(limpiarDibujo: false);
      },
    );
  }

  Widget _buildDropdownSede() {
    return FutureBuilder<List<SedeOperativa>>(
      future: _sedesFuture,
      builder: (context, snapshot) {
        final sedes = snapshot.data ?? const <SedeOperativa>[];
        final opciones = [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Todas / sin sede'),
          ),
          ...sedes.map(
            (sede) => DropdownMenuItem<String?>(
              value: sede.id,
              child: Text(sede.nombre, overflow: TextOverflow.ellipsis),
            ),
          ),
        ];

        return DropdownButtonFormField<String?>(
          value: _sedeSeleccionada,
          dropdownColor: const Color(0xFF1D1D1D),
          decoration: _decoracionCampo('Sede', Icons.location_city),
          style: const TextStyle(color: Colors.white),
          items: opciones,
          onChanged: (valor) {
            setState(() => _sedeSeleccionada = valor);
            _recargarTodo(limpiarDibujo: false);
          },
        );
      },
    );
  }

  Widget _buildDropdownCategoria() {
    return DropdownButtonFormField<String>(
      value: _categoria,
      dropdownColor: const Color(0xFF1D1D1D),
      decoration: _decoracionCampo('Categoria', Icons.category),
      style: const TextStyle(color: Colors.white),
      items: _categorias
          .map(
            (categoria) => DropdownMenuItem<String>(
              value: categoria,
              child: Text(categoria),
            ),
          )
          .toList(),
      onChanged: (valor) {
        if (valor == null) return;
        _cambiarCategoria(valor);
      },
    );
  }

  Widget _buildCampoPrioridad() {
    return _buildCampoTexto(
      controller: _prioridadController,
      label: 'Prioridad',
      icon: Icons.low_priority,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildCampoTipo() {
    return RawAutocomplete<String>(
      textEditingController: _tipoController,
      focusNode: _tipoFocusNode,
      optionsBuilder: (value) {
        final filtro = value.text.toLowerCase().trim();
        if (filtro.isEmpty) return _tiposBase;
        return _tiposBase.where((tipo) => tipo.toLowerCase().contains(filtro));
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(color: Colors.white),
          decoration: _decoracionCampo('Tipo operativo', Icons.route),
          onSubmitted: (_) => onSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: const Color(0xFF242424),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220, maxWidth: 330),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(
                      option,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCampoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _decoracionCampo(label, icon),
    );
  }

  InputDecoration _decoracionCampo(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60),
      prefixIcon: Icon(icon, color: Colors.orange, size: 18),
      filled: true,
      fillColor: const Color(0xFF101010),
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

  Widget _buildSelectorColor() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _colores.map((hex) {
        final color = colorDesdeHex(hex, fallback: Colors.orange);
        final seleccionado = _color == hex;
        return InkWell(
          onTap: () => setState(() => _color = hex),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: seleccionado ? Colors.orange : Colors.white30,
                width: seleccionado ? 3 : 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBotonesDibujo() {
    final editando = _elementoEditando != null;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _botonAccion(Icons.add, 'Nuevo', _nuevoDibujo),
        if (editando)
          _botonAccion(Icons.close, 'Cancelar edicion', _nuevoDibujo),
        _botonAccion(
          Icons.undo,
          'Deshacer punto',
          _puntosDibujo.isEmpty
              ? null
              : () => setState(() => _puntosDibujo.removeLast()),
        ),
        _botonAccion(
          Icons.cleaning_services,
          'Limpiar',
          _puntosDibujo.isEmpty ? null : () => setState(_puntosDibujo.clear),
        ),
        FilledButton.icon(
          onPressed: _guardando || _importandoKml ? null : _guardar,
          icon: _guardando || _importandoKml
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: Text(editando ? 'Actualizar' : 'Guardar'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.black,
          ),
        ),
        FilledButton.icon(
          onPressed: _guardando || _importandoKml ? null : _abrirImportacionKml,
          icon: _importandoKml
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file),
          label: const Text('Importar KML'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _botonAccion(IconData icono, String texto, VoidCallback? onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icono, size: 18),
      label: Text(texto),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.orange,
        side: const BorderSide(color: Colors.orange),
      ),
    );
  }

  Widget _buildListaElementos() {
    return FutureBuilder<DatosGisOperativos>(
      future: _datosFuture,
      builder: (context, snapshot) {
        final elementos =
            snapshot.data?.elementos ?? const <ElementoOperativo>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Elementos creados',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _recargarTodo(limpiarDibujo: false),
                  icon: const Icon(Icons.refresh, color: Colors.orange),
                  tooltip: 'Actualizar',
                ),
              ],
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.all(18),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              )
            else if (elementos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'Todavia no hay areas, rutas o puntos para esta empresa.',
                  style: TextStyle(color: Colors.white54),
                ),
              )
            else
              ...elementos.map(_buildItemElemento),
          ],
        );
      },
    );
  }

  Widget _buildItemElemento(ElementoOperativo elemento) {
    final color = colorDesdeHex(elemento.color, fallback: Colors.orange);
    final editando = _elementoEditando?.id == elemento.id;
    final subtitulo =
        '${elemento.categoria} - ${elemento.tipoOperativo} - ${elemento.activo ? 'activo' : 'inactivo'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: editando
              ? Colors.orange
              : elemento.activo
              ? color.withOpacity(0.85)
              : Colors.white24,
          width: editando ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(_iconoCategoria(elemento.categoria), color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  elemento.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Editar',
            onPressed: () => _editarElemento(elemento),
            icon: Icon(
              editando ? Icons.edit : Icons.edit_outlined,
              color: editando ? Colors.orange : Colors.cyanAccent,
            ),
          ),
          IconButton(
            tooltip: elemento.activo ? 'Desactivar' : 'Activar',
            onPressed: () => _cambiarActivo(elemento),
            icon: Icon(
              elemento.activo ? Icons.visibility : Icons.visibility_off,
              color: elemento.activo ? Colors.greenAccent : Colors.white54,
            ),
          ),
          IconButton(
            tooltip: 'Eliminar',
            onPressed: () => _eliminar(elemento),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  IconData _iconoCategoria(String categoria) {
    switch (categoria) {
      case 'area':
        return Icons.polyline;
      case 'ruta':
        return Icons.route;
      case 'punto':
        return Icons.place;
      default:
        return Icons.category;
    }
  }
}

class _DialogoImportacionKml extends StatefulWidget {
  const _DialogoImportacionKml({required this.colores});

  final List<String> colores;

  @override
  State<_DialogoImportacionKml> createState() => _DialogoImportacionKmlState();
}

class _DialogoImportacionKmlState extends State<_DialogoImportacionKml> {
  final TextEditingController _kmlController = TextEditingController();
  final ImportadorKml _importador = const ImportadorKml();

  List<ItemImportacionKml> _items = [];
  String? _error;
  int _descartados = 0;
  bool _leyendoArchivo = false;

  @override
  void dispose() {
    _kmlController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarArchivo() async {
    setState(() {
      _leyendoArchivo = true;
      _error = null;
    });

    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['kml'],
        withData: true,
      );

      if (resultado == null || resultado.files.isEmpty) return;
      final archivo = resultado.files.single;
      final bytes = archivo.bytes;
      if (bytes == null) {
        setState(() {
          _error =
              'No se pudo leer el archivo. Usa la opcion de pegar texto KML.';
        });
        return;
      }

      _kmlController.text = utf8.decode(bytes, allowMalformed: true);
      _analizarKml();
    } catch (e) {
      setState(() => _error = 'No se pudo abrir el KML: $e');
    } finally {
      if (mounted) setState(() => _leyendoArchivo = false);
    }
  }

  void _analizarKml() {
    try {
      final resultado = _importador.parse(_kmlController.text);
      setState(() {
        _items = resultado.items;
        _descartados = resultado.descartados;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _items = [];
        _descartados = 0;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final seleccionados = _items.where((item) => item.seleccionado).length;

    return Dialog(
      backgroundColor: const Color(0xFF141414),
      insetPadding: const EdgeInsets.all(18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildEntradaKml(),
              const SizedBox(height: 12),
              if (_error != null) _buildError(),
              if (_items.isNotEmpty) _buildResumen(seleccionados),
              const SizedBox(height: 8),
              Expanded(child: _buildPreview()),
              const SizedBox(height: 12),
              _buildAcciones(seleccionados),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.upload_file, color: Colors.cyanAccent),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Importar KML',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildEntradaKml() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            FilledButton.icon(
              onPressed: _leyendoArchivo ? null : _seleccionarArchivo,
              icon: _leyendoArchivo
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.folder_open),
              label: const Text('Seleccionar .kml'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _analizarKml,
              icon: const Icon(Icons.search),
              label: const Text('Analizar texto'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _kmlController,
          maxLines: 5,
          minLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Pega aqui el contenido del archivo KML...',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF0D0D0D),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.cyanAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent),
      ),
      child: Text(
        _error!,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildResumen(int seleccionados) {
    return Text(
      '${_items.length} detectado(s), $seleccionados seleccionado(s), $_descartados descartado(s).',
      style: const TextStyle(color: Colors.white70, fontSize: 12),
    );
  }

  Widget _buildPreview() {
    if (_items.isEmpty) {
      return const Center(
        child: Text(
          'Selecciona un archivo .kml o pega el contenido para previsualizar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.separated(
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildItem(_items[index], index),
    );
  }

  Widget _buildItem(ItemImportacionKml item, int index) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.seleccionado ? Colors.cyanAccent : Colors.white24,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: item.seleccionado,
                activeColor: Colors.orange,
                onChanged: (valor) {
                  setState(() => item.seleccionado = valor == true);
                },
              ),
              Icon(_iconoCategoria(item.categoria), color: _color(item.color)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.nombreOriginal.isEmpty
                      ? 'Elemento KML ${index + 1}'
                      : item.nombreOriginal,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${item.puntos.length} punto(s)',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _campo(
                  label: 'Nombre',
                  initialValue: item.nombre,
                  onChanged: (valor) => item.nombre = valor,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(width: 135, child: _categoriaDetectada(item)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _campo(
                  label: 'Tipo operativo',
                  initialValue: item.tipoOperativo,
                  onChanged: (valor) => item.tipoOperativo = valor,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(width: 92, child: _campoPrioridad(item)),
              const SizedBox(width: 8),
              SizedBox(width: 86, child: _dropdownColor(item)),
              const SizedBox(width: 8),
              Column(
                children: [
                  const Text(
                    'Activo',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  Switch(
                    value: item.activo,
                    activeColor: Colors.orange,
                    onChanged: (valor) => setState(() => item.activo = valor),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoriaDetectada(ItemImportacionKml item) {
    return InputDecorator(
      decoration: _decoracion('Categoria'),
      child: Text(
        item.categoria,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _dropdownColor(ItemImportacionKml item) {
    return DropdownButtonFormField<String>(
      value: item.color,
      dropdownColor: const Color(0xFF1D1D1D),
      decoration: _decoracion('Color'),
      items: widget.colores
          .map(
            (hex) => DropdownMenuItem<String>(
              value: hex,
              child: Container(width: 24, height: 16, color: _color(hex)),
            ),
          )
          .toList(),
      onChanged: (valor) {
        if (valor == null) return;
        setState(() => item.color = valor);
      },
    );
  }

  Widget _campoPrioridad(ItemImportacionKml item) {
    return _campo(
      label: 'Prioridad',
      initialValue: item.prioridad.toString(),
      keyboardType: TextInputType.number,
      onChanged: (valor) => item.prioridad = int.tryParse(valor.trim()) ?? 0,
    );
  }

  Widget _campo({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: _decoracion(label),
      onChanged: onChanged,
    );
  }

  InputDecoration _decoracion(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 11),
      isDense: true,
      filled: true,
      fillColor: const Color(0xFF151515),
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

  Widget _buildAcciones(int seleccionados) {
    return Row(
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: _items.isEmpty
              ? null
              : () {
                  setState(() {
                    final seleccionar = seleccionados != _items.length;
                    for (final item in _items) {
                      item.seleccionado = seleccionar;
                    }
                  });
                },
          child: Text(
            seleccionados == _items.length
                ? 'Quitar todos'
                : 'Seleccionar todos',
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: seleccionados == 0
              ? null
              : () {
                  Navigator.pop(
                    context,
                    _items.where((item) => item.seleccionado).toList(),
                  );
                },
          icon: const Icon(Icons.save),
          label: Text('Guardar $seleccionados'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.black,
          ),
        ),
      ],
    );
  }

  IconData _iconoCategoria(String categoria) {
    switch (categoria) {
      case 'area':
        return Icons.polyline;
      case 'ruta':
        return Icons.route;
      case 'punto':
        return Icons.place;
      default:
        return Icons.category;
    }
  }

  Color _color(String hex) {
    return colorDesdeHex(hex, fallback: Colors.orange);
  }
}
