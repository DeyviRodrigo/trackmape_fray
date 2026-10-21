import 'package:flutter/material.dart';
import 'package:trackmape_sup/app/tokens/tokens_sistema.dart';
import 'package:trackmape_sup/funciones/diagnostico/presentacion/paginas/pagina_diagnostico_operativo.dart';
import 'package:trackmape_sup/funciones/estadistica/presentacion/pagina/comparativo_rutas_page.dart';
import 'package:trackmape_sup/funciones/estadistica/presentacion/pagina/pagina_informe.dart';
import 'package:trackmape_sup/funciones/estadistica/presentacion/pagina/rendimiento_operador.dart';
import 'package:trackmape_sup/funciones/gis/presentacion/paginas/pagina_configuracion_operativa.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_historico.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_operadores.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_ranking.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_simulacion.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_stream.dart';
import 'package:trackmape_sup/funciones/validacion/presentacion/paginas/validacion_equipos_page.dart';
import 'package:trackmape_sup/widgets/atomos/nivel1/icono_atomo.dart';
import 'package:trackmape_sup/widgets/atomos/nivel1/texto_atomo.dart';
import 'package:trackmape_sup/widgets/atomos/nivel2/item_menu_atomo.dart';
import 'package:trackmape_sup/widgets/moleculas/contenido/opciones_superiores_mol.dart';
import 'package:trackmape_sup/widgets/moleculas/menu_lateral/seccion_expandible_mol.dart';
import 'package:trackmape_sup/widgets/moleculas/menu_lateral/seccion_superior_mol.dart';
import 'package:trackmape_sup/widgets/moleculas/menu_lateral/seccion_usuario_mol.dart';
import 'package:trackmape_sup/widgets/organismos/contenido/contenido_org.dart';
import 'package:trackmape_sup/widgets/organismos/encabezado/encabezado_org.dart';
import 'package:trackmape_sup/widgets/organismos/menu_lateral/menu_lateral_org.dart';

class ContenedorPrincipal extends StatefulWidget {
  const ContenedorPrincipal({super.key});

  @override
  State<ContenedorPrincipal> createState() => _ContenedorPrincipalState();
}

class _ContenedorPrincipalState extends State<ContenedorPrincipal> {
  static const bool _modoClienteSimple = false;
  final RepositorioMonitoreo _repositorioMonitoreo = RepositorioMonitoreo();

  int _indiceActual = 0;
  String _empresaSeleccionada = RepositorioMonitoreo.empresaMonitoreoFija;
  List<EmpresaDashboardMonitoreo> _empresasDashboard =
      RepositorioMonitoreo.empresasDashboardFrancisco;

  @override
  void initState() {
    super.initState();
    _cargarEmpresasDashboard();
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
      }
    });
  }

  List<_DestinoNavegacion> get _destinos {
    final destinosCliente = [
      _DestinoNavegacion(
        etiqueta: 'Monitoreo en Tiempo Real',
        titulo: 'TRACKING EN VIVO',
        icono: Iconos.monitoreo,
        seccion: _SeccionMenu.formularios,
        pagina: PaginaStream(
          key: ValueKey('stream_$_empresaSeleccionada'),
          empresaFiltro: _empresaSeleccionada,
        ),
      ),
      _DestinoNavegacion(
        etiqueta: 'Consulta Historica',
        titulo: 'HISTORIAL DE RUTAS',
        icono: Iconos.historico,
        seccion: _SeccionMenu.informes,
        pagina: PaginaHistorico(
          key: ValueKey('historico_$_empresaSeleccionada'),
          empresaFiltro: _empresaSeleccionada,
        ),
      ),
      _DestinoNavegacion(
        etiqueta: 'Base de Operadores',
        titulo: 'GESTION DE OPERADORES',
        icono: Iconos.operadores,
        seccion: _SeccionMenu.formularios,
        pagina: PaginaOperadores(
          key: ValueKey('operadores_$_empresaSeleccionada'),
          empresaFiltro: _empresaSeleccionada,
        ),
      ),
    ];

    if (_modoClienteSimple) return destinosCliente;

    return [
      ...destinosCliente,
      const _DestinoNavegacion(
        etiqueta: 'Reporte de Turno',
        titulo: 'REGISTRO DE INFORME',
        icono: Iconos.reporte,
        seccion: _SeccionMenu.formularios,
        pagina: PaginaInforme(),
      ),
      const _DestinoNavegacion(
        etiqueta: 'Ranking Operativo',
        titulo: 'RANKING OPERATIVO',
        icono: Iconos.ranking,
        seccion: _SeccionMenu.informes,
        pagina: PaginaRanking(),
      ),
      const _DestinoNavegacion(
        etiqueta: 'Rendimiento de Operador',
        titulo: 'RENDIMIENTO DE OPERADOR',
        icono: Iconos.rendimiento,
        seccion: _SeccionMenu.informes,
        pagina: RendimientoOperador(),
      ),
      const _DestinoNavegacion(
        etiqueta: 'Comparativo de Rutas',
        titulo: 'COMPARATIVO DE RUTAS',
        icono: Iconos.comparativo,
        seccion: _SeccionMenu.informes,
        pagina: ComparativoRutasPage(),
      ),
      _DestinoNavegacion(
        etiqueta: 'Diagnostico Operativo',
        titulo: 'DIAGNOSTICO OPERATIVO',
        icono: Iconos.diagnostico,
        seccion: _SeccionMenu.informes,
        pagina: PaginaDiagnosticoOperativo(
          key: ValueKey('diagnostico_operativo_$_empresaSeleccionada'),
          empresaInicial: _empresaSeleccionada,
        ),
      ),
      const _DestinoNavegacion(
        etiqueta: 'Transcurso Simulado',
        titulo: 'TRANSCURSO SIMULADO',
        icono: Iconos.simulacion,
        seccion: _SeccionMenu.configuraciones,
        pagina: HojaSimulacion(),
      ),
      const _DestinoNavegacion(
        etiqueta: 'Validacion de Equipos',
        titulo: 'VALIDACION DE EQUIPOS',
        icono: Iconos.validar,
        seccion: _SeccionMenu.configuraciones,
        pagina: ValidacionEquiposPage(),
      ),
      _DestinoNavegacion(
        etiqueta: 'Configuracion Operativa',
        titulo: 'CONFIGURACION OPERATIVA',
        icono: Iconos.configuracionOperativa,
        seccion: _SeccionMenu.configuraciones,
        pagina: PaginaConfiguracionOperativa(
          key: ValueKey('config_operativa_$_empresaSeleccionada'),
          empresaInicial: _empresaSeleccionada,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final destinos = _destinos;
    final indicePagina = _indiceActual < destinos.length ? _indiceActual : 0;
    final destinoActual = destinos[indicePagina];
    final paginas = destinos.map((destino) => destino.pagina).toList();
    final nombreEmpresa = _nombreEmpresaSeleccionada();

    return Scaffold(
      backgroundColor: ColoresApp.fondoSecundario,
      appBar: EncabezadoOrg(
        izquierda: Builder(
          builder: (context) {
            return IconButton(
              tooltip: 'Menu',
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const IconoAtomo(
                icono: Iconos.menu,
                contexto: ContextoIcono.activo,
                tamano: 26,
              ),
            );
          },
        ),
        centro: _buildCentroEncabezado(destinoActual.titulo),
        derecha: _buildAccionSesion(),
      ),
      drawer: _crearMenuLateral(destinos),
      body: ContenidoOrg(
        opcionesSuperiores: _buildPanelFiltrosGlobal(nombreEmpresa),
        contenidoPrincipal: IndexedStack(
          index: indicePagina,
          children: paginas,
        ),
      ),
    );
  }

  String _nombreEmpresaSeleccionada() {
    for (final empresa in _empresasDashboard) {
      if (empresa.id == _empresaSeleccionada) return empresa.nombre;
    }

    return RepositorioMonitoreo.nombreEmpresaDashboard(_empresaSeleccionada);
  }

  Widget _buildCentroEncabezado(String tituloHeader) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextoAtomo(
          texto: 'TrackMAPE',
          contexto: ContextoTexto.secundario,
        ),
        TextoAtomo(
          texto: tituloHeader,
          contexto: ContextoTexto.titulo,
          maxLineas: 1,
        ),
      ],
    );
  }

  Widget _buildAccionSesion() {
    return IconButton(
      tooltip: 'Sesion',
      onPressed: () {},
      icon: const IconoAtomo(
        icono: Iconos.sesion,
        contexto: ContextoIcono.normal,
        tamano: 24,
      ),
    );
  }

  Widget _buildPanelFiltrosGlobal(String nombreEmpresa) {
    return OpcionesSuperioresMol(
      titulo: 'Filtros de operacion',
      contenido: Wrap(
        spacing: Espaciado.base,
        runSpacing: Espaciado.pequeno,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(width: 360, child: _buildSelectorEmpresa()),
          Container(
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.symmetric(
              horizontal: Espaciado.base,
              vertical: Espaciado.pequeno,
            ),
            decoration: BoxDecoration(
              color: ColoresApp.fondoPrimario,
              borderRadius: BorderRadius.circular(Radios.grande),
              border: Border.all(color: ColoresApp.borde),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const IconoAtomo(
                  icono: Iconos.empresa,
                  contexto: ContextoIcono.tenue,
                  tamano: 18,
                ),
                const SizedBox(width: Espaciado.pequeno),
                Flexible(
                  child: TextoAtomo(
                    texto: nombreEmpresa,
                    contexto: ContextoTexto.secundario,
                    maxLineas: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorEmpresa() {
    if (_empresasDashboard.isEmpty) {
      return const TextoAtomo(
        texto: 'Sin empresas disponibles',
        contexto: ContextoTexto.secundario,
      );
    }

    return DropdownButtonFormField<String>(
      key: ValueKey(_empresaSeleccionada),
      initialValue: _empresaSeleccionada,
      isExpanded: true,
      dropdownColor: ColoresApp.fondoPrimario,
      style: const TextStyle(
        color: ColoresApp.textoPrimario,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      decoration: const InputDecoration(
        labelText: 'Empresa',
        prefixIcon: Icon(Icons.apartment_rounded),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Espaciado.base,
          vertical: Espaciado.pequeno,
        ),
      ),
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
        });
      },
    );
  }

  Widget _crearMenuLateral(List<_DestinoNavegacion> destinos) {
    return MenuLateralOrg(
      encabezado: const SeccionSuperiorMol(
        titulo: 'TrackMAPE',
        subtitulo: 'Sistema operativo de flota',
      ),
      formularios: SeccionExpandibleMol(
        titulo: 'Formularios',
        icono: Iconos.formularios,
        items: _itemsPorSeccion(destinos, _SeccionMenu.formularios),
      ),
      informes: SeccionExpandibleMol(
        titulo: 'Informes',
        icono: Iconos.informes,
        items: _itemsPorSeccion(destinos, _SeccionMenu.informes),
      ),
      configuraciones: SeccionExpandibleMol(
        titulo: 'Configuraciones',
        icono: Iconos.configuraciones,
        items: _itemsPorSeccion(destinos, _SeccionMenu.configuraciones),
      ),
      sesion: SeccionUsuarioMol(
        nombre: 'Usuario',
        rol: 'Sesion activa',
        onCerrarSesion: () => Navigator.maybePop(context),
      ),
    );
  }

  List<Widget> _itemsPorSeccion(
    List<_DestinoNavegacion> destinos,
    _SeccionMenu seccion,
  ) {
    final items = <Widget>[];

    for (var indice = 0; indice < destinos.length; indice++) {
      final destino = destinos[indice];
      if (destino.seccion != seccion) continue;
      items.add(_itemMenu(destino, indice));
    }

    return items;
  }

  Widget _itemMenu(_DestinoNavegacion destino, int indice) {
    return ItemMenuAtomo(
      icono: destino.icono,
      etiqueta: destino.etiqueta,
      activo: _indiceActual == indice,
      onTap: () {
        setState(() {
          _indiceActual = indice;
        });

        Navigator.pop(context);
      },
    );
  }
}

enum _SeccionMenu { formularios, informes, configuraciones }

class _DestinoNavegacion {
  final String etiqueta;
  final String titulo;
  final IconData icono;
  final _SeccionMenu seccion;
  final Widget pagina;

  const _DestinoNavegacion({
    required this.etiqueta,
    required this.titulo,
    required this.icono,
    required this.seccion,
    required this.pagina,
  });
}
