import 'package:flutter/material.dart';
import 'package:trackmape_sup/funciones/estadistica/presentacion/pagina/rendimiento_operador.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_historico.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_operadores.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_simulacion.dart';
import 'package:trackmape_sup/funciones/monitoreo/presentacion/paginas/pagina_stream.dart';
import 'package:trackmape_sup/funciones/validacion/presentacion/paginas/validacion_equipos_page.dart';

class ContenedorPrincipal extends StatefulWidget {
  const ContenedorPrincipal({super.key});

  @override
  State<ContenedorPrincipal> createState() => _ContenedorPrincipalState();
}

class _ContenedorPrincipalState extends State<ContenedorPrincipal> {
  int _indiceActual = 0;

  final List<Widget> _paginas = const [
    PaginaStream(),
    PaginaHistorico(),
    PaginaOperadores(),
    HojaSimulacion(),
    ValidacionEquiposPage(),
  ];

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
        tituloHeader = 'SIMULACION DE TRANSCURSO';
        break;
      case 4:
        tituloHeader = 'Rendimiento';
        break;
      default:
        tituloHeader = 'TrackMAPE';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          tituloHeader,
          style: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 4,
        shadowColor: Colors.orange.withOpacity(0.2),
        iconTheme: const IconThemeData(color: Colors.orange),
      ),
      drawer: _crearMenuLateral(),
      body: IndexedStack(
        index: _indiceActual,
        children: _paginas,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white10, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _indiceActual > 1 ? 0 : _indiceActual,
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
          items: const [
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
          ],
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
          _itemMenu(
            Icons.play_circle_fill,
            'Transcurso Simulado',
            3,
            color: Colors.greenAccent,
          ),
          const Divider(
            color: Colors.white10,
            indent: 20,
            endIndent: 20,
          ),
          _itemMenu(Icons.engineering, 'Base de Operadores', 2),
          _itemMenu(Icons.fact_check_rounded, 'Rendimiento de Operador', 4),
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
      leading: Icon(
        icono,
        color: seleccionado ? Colors.orange : color,
      ),
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
