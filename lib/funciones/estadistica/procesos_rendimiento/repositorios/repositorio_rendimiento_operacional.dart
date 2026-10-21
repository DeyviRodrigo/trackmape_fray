import 'package:supabase_flutter/supabase_flutter.dart';

import '../modelos/equipo_rendimiento.dart';
import '../modelos/punto_rendimiento.dart';

class RepositorioRendimientoOperacional {
  RepositorioRendimientoOperacional({
    SupabaseClient? supabase,
  }) : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const int _tamanoPagina = 1000;
  static const int _limiteMaximoRegistros = 60000;

  Future<List<EquipoRendimiento>> obtenerEquiposDisponibles() async {
    final respuesta = await _supabase
        .from('equipos_control')
        .select('id_equipo_control, codigo_equipo_control, nombre');

    final equipos = List<Map<String, dynamic>>.from(respuesta)
        .where((fila) {
          final codigo = fila['codigo_equipo_control']?.toString().trim() ?? '';
          return codigo.isNotEmpty;
        })
        .map(
          (fila) => EquipoRendimiento(
            idEquipoControl: fila['id_equipo_control']?.toString() ?? '',
            codigoEquipoControl:
                fila['codigo_equipo_control']?.toString().trim() ?? '',
            nombre: fila['nombre']?.toString().trim() ?? '',
          ),
        )
        .toList();

    equipos.sort((a, b) => a.etiquetaVisible.compareTo(b.etiquetaVisible));
    return equipos;
  }

  Future<List<PuntoRendimiento>> obtenerPuntosPorEquipoYFecha({
    required EquipoRendimiento equipo,
    required DateTime fecha,
  }) async {
    final inicioDia = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      0,
      0,
      0,
    ).toIso8601String();
    final finDia = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      23,
      59,
      59,
      999,
    ).toIso8601String();

    final codigoCanonico = _canonizarCodigo(equipo.codigoEquipoControl);
    final puntos = <PuntoRendimiento>[];
    var pagina = 0;

    while (puntos.length < _limiteMaximoRegistros) {
      final inicio = pagina * _tamanoPagina;
      final fin = inicio + _tamanoPagina - 1;

      final respuesta = await _supabase
          .from('posiciones_temp')
          .select('fk_emisor, lat_grados, lon_grados, tiempo')
          .gte('tiempo', inicioDia)
          .lte('tiempo', finDia)
          .order('tiempo', ascending: true)
          .range(inicio, fin);

      final bloque = List<Map<String, dynamic>>.from(respuesta);
      if (bloque.isEmpty) {
        break;
      }

      for (final fila in bloque) {
        final codigoFila = _canonizarCodigo(fila['fk_emisor']?.toString());
        if (codigoFila != codigoCanonico) {
          continue;
        }

        final latitud = (fila['lat_grados'] as num?)?.toDouble();
        final longitud = (fila['lon_grados'] as num?)?.toDouble();
        final tiempo = DateTime.tryParse(fila['tiempo']?.toString() ?? '');

        if (latitud == null || longitud == null || tiempo == null) {
          continue;
        }

        puntos.add(
          PuntoRendimiento(
            latitud: latitud,
            longitud: longitud,
            tiempo: tiempo,
          ),
        );
      }

      if (bloque.length < _tamanoPagina) {
        break;
      }

      pagina++;
    }

    return puntos;
  }

  String _canonizarCodigo(String? valor) {
    if (valor == null) {
      return '';
    }

    var limpio = valor.trim().toUpperCase();
    if (limpio.isEmpty) {
      return '';
    }

    limpio = limpio.replaceFirst(RegExp(r'^0X'), '');
    limpio = limpio.replaceFirst(RegExp(r'^[^A-Z0-9]+'), '');
    limpio = limpio.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return limpio;
  }
}
