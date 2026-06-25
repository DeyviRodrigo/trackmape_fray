import 'package:flutter/material.dart';
import 'package:trackmape_sup/funciones/diagnostico/presentacion/paginas/pagina_diagnostico_operativo.dart';
import 'package:trackmape_sup/funciones/estadistica/presentacion/pagina/comparativo_rutas_page.dart';
import 'package:trackmape_sup/funciones/gis/presentacion/paginas/pagina_configuracion_operativa.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_historico.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_operadores.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_ranking.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_simulacion.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_stream.dart';
import 'package:trackmape_sup/funciones/validacion/presentacion/paginas/validacion_equipos_page.dart';

class ContenedorPrincipal extends StatefulWidget {
  const ContenedorPrincipal({super.key});

  @override
  State<ContenedorPrincipal> createState() => _ContenedorPrincipalState();
}

class _ContenedorPrincipalState extends State<ContenedorPrincipal> {
  static final bool _modoClienteSimple = false;
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

  List<Widget> get _paginas {
    final paginasCliente = [
      PaginaStream(
        key: ValueKey('stream_$_empresaSeleccionada'),
        empresaFiltro: _empresaSeleccionada,
      ),
      PaginaHistorico(
        key: ValueKey('historico_$_empresaSeleccionada'),
        empresaFiltro: _empresaSeleccionada,
      ),
      PaginaOperadores(
        key: ValueKey('operadores_$_empresaSeleccionada'),
        empresaFiltro: _empresaSeleccionada,
      ),
    ];

    if (_modoClienteSimple) return paginasCliente;

    return [
      ...paginasCliente,
      const PaginaRanking(),
      const HojaSimulacion(),
      const ValidacionEquiposPage(),
      const ComparativoRutasPage(),
      PaginaConfiguracionOperativa(
        key: ValueKey('config_operativa_$_empresaSeleccionada'),
        empresaInicial: _empresaSeleccionada,
      ),
      PaginaDiagnosticoOperativo(
        key: ValueKey('diagnostico_operativo_$_empresaSeleccionada'),
        empresaInicial: _empresaSeleccionada,
      ),
    ];
  }

  List<BottomNavigationBarItem> get _itemsNavegacionInferior {
    final itemsCliente = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.sensors),
        activeIcon: Icon(Icons.sensors, color: Colors.orange),
        label: 'En Vivo',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.history),
        activeIcon: Icon(Icons.history, color: Colors.orange),
        label: 'Historico',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.engineering),
        activeIcon: Icon(Icons.engineering, color: Colors.orange),
        label: 'Operadores',
      ),
    ];

    if (_modoClienteSimple) return itemsCliente;

    return itemsCliente;
  }

  @override
  Widget build(BuildContext context) {
    String tituloHeader;

    switch (_indiceActual) {
      case 0:
        tituloHeader = 'TRACKING EN VIVO';
        break;
      case 1:
        tituloHeader = 'HISTORIAL DE RUTAS';
        break;
      case 2:
        tituloHeader = 'GESTION DE OPERADORES';
        break;
      case 3:
        tituloHeader = 'RANKING OPERATIVO';
        break;
      case 4:
        tituloHeader = 'SIMULACION DE TRANSCURSO';
        break;
      case 5:
        tituloHeader = 'Rendimiento';
        break;
      case 6:
        tituloHeader = 'COMPARATIVO DE RUTAS';
        break;
      case 7:
        tituloHeader = 'CONFIGURACION OPERATIVA';
        break;
      case 8:
        tituloHeader = 'DIAGNOSTICO OPERATIVO';
        break;
      default:
        tituloHeader = 'TrackMAPE';
    }

    final paginas = _paginas;
    final itemsNavegacion = _itemsNavegacionInferior;
    final indicePagina = _indiceActual < paginas.length ? _indiceActual : 0;
    final indiceNavegacion = _indiceActual < itemsNavegacion.length
        ? _indiceActual
        : 0;
    final nombreEmpresa = _nombreEmpresaSeleccionada();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        toolbarHeight: _modoClienteSimple ? 74 : null,
        title: _buildTituloHeader(tituloHeader, nombreEmpresa),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 4,
        shadowColor: Colors.orange.withOpacity(0.2),
        iconTheme: const IconThemeData(color: Colors.orange),
        actions: [
          if (!_modoClienteSimple) ...[
            _buildSelectorEmpresa(),
            const SizedBox(width: 10),
          ],
        ],
      ),
      drawer: _crearMenuLateral(),
      body: IndexedStack(index: indicePagina, children: paginas),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: indiceNavegacion,
          onTap: (indice) {
            setState(() {
              _indiceActual = indice;
            });
          },
          backgroundColor: const Color(0xFF1A1A1A),
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.white54,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          items: itemsNavegacion,
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

  Widget _buildTituloHeader(String tituloHeader, String nombreEmpresa) {
    if (!_modoClienteSimple) {
      return Text(
        tituloHeader,
        style: const TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 1.2,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          tituloHeader,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          nombreEmpresa,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w700,
            fontSize: 10.5,
            height: 1.05,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorEmpresa() {
    return Center(
      child: Container(
        height: 38,
        width: MediaQuery.sizeOf(context).width < 760 ? 170 : 280,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.65)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _empresaSeleccionada,
            isExpanded: true,
            dropdownColor: const Color(0xFF151515),
            iconEnabledColor: Colors.orange,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            items: _empresasDashboard
                .map(
                  (empresa) => DropdownMenuItem<String>(
                    value: empresa.id,
                    child: Text(
                      empresa.nombre,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            selectedItemBuilder: (context) {
              return _empresasDashboard
                  .map(
                    (empresa) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        empresa.nombre,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList();
            },
            onChanged: (valor) {
              if (valor == null || valor == _empresaSeleccionada) return;
              setState(() {
                _empresaSeleccionada = valor;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _crearMenuLateral() {
    return Drawer(
      backgroundColor: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black,
              border: Border(
                bottom: BorderSide(color: Colors.orange, width: 2),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map, color: Colors.orange, size: 40),
                  const SizedBox(height: 10),
                  const Text(
                    'TrackMAPE',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Sistema de Supervision',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _itemMenu(Icons.sensors, 'Monitoreo en Tiempo Real', 0),
          _itemMenu(Icons.history, 'Consulta Historica', 1),
          const Divider(color: Colors.white10, indent: 20, endIndent: 20),
          _itemMenu(Icons.engineering, 'Base de Operadores', 2),
          if (!_modoClienteSimple) ...[
            _itemMenu(Icons.leaderboard_rounded, 'Ranking Operativo', 3),
            _itemMenu(
              Icons.play_circle_fill,
              'Transcurso Simulado',
              4,
              color: Colors.greenAccent,
            ),
            _itemMenu(Icons.fact_check_rounded, 'Rendimiento de Operador', 5),
            _itemMenu(Icons.compare_arrows_rounded, 'Comparativo de Rutas', 6),
            _itemMenu(
              Icons.edit_location_alt_rounded,
              'Configuracion Operativa',
              7,
              color: Colors.cyanAccent,
            ),
            _itemMenu(
              Icons.route_rounded,
              'Diagnostico Operativo',
              8,
              color: Colors.amberAccent,
            ),
          ],
          const Spacer(),
          const Divider(color: Colors.white24),
          _itemMenu(Icons.logout, 'Cerrar Sesion', -1, color: Colors.redAccent),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _itemMenu(
    IconData icono,
    String titulo,
    int indice, {
    Color color = Colors.white,
  }) {
    final bool seleccionado = _indiceActual == indice;

    return ListTile(
      leading: Icon(icono, color: seleccionado ? Colors.orange : color),
      title: Text(
        titulo,
        style: TextStyle(
          color: seleccionado ? Colors.orange : color,
          fontWeight: seleccionado ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      selected: seleccionado,
      onTap: () {
        if (indice == -1) {
          return;
        }

        setState(() {
          _indiceActual = indice;
        });

        Navigator.pop(context);
      },
    );
  }
}
