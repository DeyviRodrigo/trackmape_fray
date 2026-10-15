import 'package:flutter/material.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/modelos/modelo_equipo.dart';
import 'perfil_equipo.dart';

class PaginaOperadores extends StatefulWidget {
  const PaginaOperadores({super.key});

  @override
  State<PaginaOperadores> createState() => _PaginaOperadoresState();
}

class _PaginaOperadoresState extends State<PaginaOperadores> {
  final RepositorioMonitoreo _repositorio = RepositorioMonitoreo();
  Map<String, DateTime> ultimosReportes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: const Text(
          "OPERADORES TRACKER",
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // Semáforo de conexión basado en las últimas posiciones
        stream: _repositorio.streamUltimasConexiones(),
        builder: (context, snapshotPos) {
          if (snapshotPos.hasData) {
            for (var p in snapshotPos.data!) {
              ultimosReportes[p['fk_emisor'].toString()] = DateTime.parse(p['tiempo']);
            }
          }

          return StreamBuilder<List<ModeloEquipo>>(
            // Lista de equipos filtrada por TRACKER
            stream: _repositorio.streamEquipos(),
            builder: (context, snapshotEquipos) {
              if (snapshotEquipos.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.orange));
              }

              if (!snapshotEquipos.hasData || snapshotEquipos.data!.isEmpty) {
                return const Center(
                  child: Text("No se encontraron operadores Tracker",
                      style: TextStyle(color: Colors.white54)),
                );
              }

              final equipos = snapshotEquipos.data!;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: equipos.length,
                itemBuilder: (context, index) {
                  final equipo = equipos[index];

                  // Lógica del Semáforo (Wifi)
                  Color colorWifi = Colors.grey;
                  if (equipo.activo) {
                    colorWifi = Colors.orange;
                    if (ultimosReportes.containsKey(equipo.id)) {
                      final diff = DateTime.now().difference(ultimosReportes[equipo.id]!).inSeconds;
                      if (diff <= 15) colorWifi = Colors.green;
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        // 1. INDICADOR DE CONEXIÓN
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PaginaPerfilEquipo(equipo: equipo))
                          ),
                          child: CircleAvatar(
                            backgroundColor: colorWifi.withOpacity(0.1),
                            child: Icon(Icons.wifi, color: colorWifi, size: 20),
                          ),
                        ),

                        const SizedBox(width: 15),

                        // 2. INFORMACIÓN DEL OPERADOR (CENTRO)
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PaginaPerfilEquipo(equipo: equipo))
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  equipo.nombreMostrar,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  equipo.activo ? "Estado: Activo" : "Estado: Inactivo",
                                  style: TextStyle(
                                      color: equipo.activo ? Colors.green : Colors.red,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 3. BOTONES DE ACCIÓN (LATERAL DERECHO)
                        _buildSeccionBotones(equipo),

                        const SizedBox(width: 10),
                        const Icon(Icons.edit, color: Colors.white10, size: 18),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Lógica de visualización de botones a la derecha
  Widget _buildSeccionBotones(ModeloEquipo equipo) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!equipo.activo)
          _buildBotonCompacto(
            label: "ACTIVAR",
            color: Colors.green,
            onPressed: () => _repositorio.actualizarEquipo(equipo.id, {'activo': true}),
          ),
        if (equipo.activo)
          _buildBotonCompacto(
            label: "DESACTIVAR",
            color: Colors.red,
            onPressed: () => _repositorio.actualizarEquipo(equipo.id, {'activo': false}),
          ),
      ],
    );
  }

  // Botón estilizado y compacto para el lateral
  Widget _buildBotonCompacto({required String label, required Color color, required VoidCallback onPressed}) {
    return SizedBox(
      height: 32,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: color.withOpacity(0.05),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}