import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:trackmape_sup/funciones/gis/datos/repositorios/repositorio_gis.dart';

class CapasGisMapa {
  const CapasGisMapa({
    required this.poligonos,
    required this.rutas,
    required this.marcadores,
  });

  final List<Polygon> poligonos;
  final List<Polyline> rutas;
  final List<Marker> marcadores;

  static const vacias = CapasGisMapa(poligonos: [], rutas: [], marcadores: []);
}

CapasGisMapa construirCapasGisMapa(
  DatosGisOperativos datos, {
  required bool mostrarAreas,
  required bool mostrarRutas,
  bool mostrarEtiquetas = true,
}) {
  final poligonos = <Polygon>[];
  final rutas = <Polyline>[];
  final marcadores = <Marker>[];

  if (mostrarAreas) {
    for (final area in datos.areas) {
      final color = colorDesdeHex(area.color, fallback: Colors.orangeAccent);
      poligonos.add(
        Polygon(
          points: area.puntosPoligono,
          color: color.withOpacity(0.16),
          borderColor: color.withOpacity(0.9),
          borderStrokeWidth: 2,
        ),
      );

      final centro = area.centro;
      if (mostrarEtiquetas && centro != null) {
        marcadores.add(
          Marker(
            point: centro,
            width: 120,
            height: 30,
            child: _EtiquetaGis(texto: area.nombre, color: color),
          ),
        );
      }
    }
  }

  if (mostrarRutas) {
    for (final ruta in datos.rutas) {
      final color = colorDesdeHex(ruta.color, fallback: Colors.cyanAccent);
      rutas.add(
        Polyline(
          points: ruta.puntosLinea,
          color: color.withOpacity(0.72),
          strokeWidth: 3,
        ),
      );
    }
  }

  if (mostrarEtiquetas) {
    for (final punto in datos.puntos) {
      final posicion = punto.punto;
      if (posicion == null) continue;
      final color = colorDesdeHex(punto.color, fallback: Colors.lightGreenAccent);
      marcadores.add(
        Marker(
          point: posicion,
          width: 120,
          height: 42,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.place, color: color, size: 18),
              _EtiquetaGis(texto: punto.nombre, color: color),
            ],
          ),
        ),
      );
    }
  }

  return CapasGisMapa(
    poligonos: poligonos,
    rutas: rutas,
    marcadores: marcadores,
  );
}

Color colorDesdeHex(String? hex, {required Color fallback}) {
  final raw = hex?.trim();
  if (raw == null || raw.isEmpty) return fallback;

  var normalizado = raw.replaceFirst('#', '');
  if (normalizado.length == 6) normalizado = 'ff$normalizado';
  final valor = int.tryParse(normalizado, radix: 16);
  if (valor == null) return fallback;
  return Color(valor);
}

class _EtiquetaGis extends StatelessWidget {
  const _EtiquetaGis({required this.texto, required this.color});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.78),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.9)),
      ),
      child: Text(
        texto,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
