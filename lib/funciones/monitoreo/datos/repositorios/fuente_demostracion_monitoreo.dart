/// Datos locales temporales para presentar el monitoreo mientras la base de
/// datos no esta disponible. Las coordenadas provienen de
/// `posiciones_temp_rows.csv` (23-07-2026).
class FuenteDemostracionMonitoreo {
  static final DateTime fecha = DateTime(2026, 7, 23);
  static const String idEquipo = '3ce7cb85-680a-4ed6-af54-f3170ca6c668';
  static const String idReceptor = 'a07bb038-dcb9-466e-98c2-b0558a4363ea';

  static const Map<String, dynamic> equipo = {
    'id_equipo_control': idEquipo,
    'fk_empresa': 'c6a59aec-29ea-4e42-8ece-581df5e4459d',
    'tipo_equipo_control': 'SEEED WIO TRACKER L1',
    'codigo_equipo_control': 'VOL-001',
    'nombre': 'Volquete 1',
    'id_equipo_fabrica': idEquipo,
    'activo': true,
    'fecha_final': null,
  };

  // Los 100 pares latitud:longitud del CSV, ordenados cronologicamente.
  static const String _coordenadas =
      '-14.6790875:-69.486441,-14.6790868:-69.4864406,-14.6790866:-69.4864406,-14.679086:-69.4864406,-14.6790858:-69.4864403,-14.6790861:-69.4864403,-14.6790858:-69.4864403,-14.679086:-69.4864413,-14.6790863:-69.4864421,-14.6790873:-69.4864433,-14.679087:-69.4864436,-14.6790866:-69.4864438,-14.679086:-69.486444,-14.6790848:-69.4864448,-14.6790843:-69.4864466,-14.679084:-69.4864481,-14.6790831:-69.486449,-14.6790825:-69.4864496,-14.6790816:-69.4864503,-14.6790815:-69.4864498,-14.6790813:-69.4864495,-14.679081:-69.4864491,-14.6790806:-69.4864486,-14.6790798:-69.4864483,-14.6790795:-69.486448,-14.6790793:-69.4864471,-14.6790793:-69.4864463,-14.6790791:-69.4864455,-14.679079:-69.4864445,-14.6790793:-69.4864426,-14.6790793:-69.4864413,-14.6790793:-69.4864403,-14.6790791:-69.4864391,-14.679079:-69.4864386,-14.6790786:-69.4864385,-14.6790781:-69.486438,-14.6790785:-69.4864375,-14.6790788:-69.4864378,-14.679079:-69.4864381,-14.6790788:-69.4864388,-14.6790786:-69.4864391,-14.6790785:-69.4864395,-14.6790785:-69.486439,-14.6790783:-69.4864391,-14.6790781:-69.4864395,-14.6790775:-69.486439,-14.6790771:-69.4864381,-14.6790768:-69.486438,-14.6790763:-69.4864386,-14.679076:-69.4864391,-14.6790756:-69.4864393,-14.6790753:-69.4864398,-14.6790751:-69.4864403,-14.6790746:-69.4864408,-14.6790743:-69.4864413,-14.6790741:-69.4864418,-14.679074:-69.486442,-14.6790738:-69.4864421,-14.6790733:-69.486442,-14.679073:-69.4864423,-14.6790718:-69.4864443,-14.6790716:-69.4864445,-14.6790715:-69.486445,-14.6790713:-69.4864453,-14.679071:-69.4864458,-14.6790705:-69.4864461,-14.6790698:-69.4864463,-14.679069:-69.4864466,-14.6790685:-69.4864468,-14.6790678:-69.4864468,-14.6790668:-69.4864466,-14.6790658:-69.4864463,-14.6790651:-69.4864465,-14.6790646:-69.4864465,-14.6790641:-69.4864468,-14.6790638:-69.486447,-14.6790633:-69.486447,-14.6790631:-69.4864468,-14.679063:-69.4864468,-14.6790628:-69.4864466,-14.6790628:-69.4864465,-14.6790626:-69.4864465,-14.6790626:-69.4864465,-14.6790625:-69.4864466,-14.679062:-69.4864471,-14.6790616:-69.4864471,-14.6790611:-69.4864478,-14.679061:-69.4864488,-14.6790666:-69.4864466,-14.6790641:-69.4864446,-14.67906:-69.4864468,-14.6790551:-69.4864501,-14.6790541:-69.4864515,-14.6790536:-69.4864553,-14.6790525:-69.4864575,-14.6790516:-69.4864601,-14.6790518:-69.486462,-14.679051:-69.4864643,-14.6790506:-69.4864668,-14.6790513:-69.4864686';

  static List<Map<String, dynamic>>? _posicionesCargadas;
  static String? nombreArchivoCargado;

  static List<Map<String, dynamic>> get posicionesActivas =>
      _posicionesCargadas ?? posiciones();

  static DateTime get fechaActiva {
    final tiempo = posicionesActivas.first['tiempo']?.toString();
    return DateTime.tryParse(tiempo ?? '') ?? fecha;
  }

  static List<Map<String, dynamic>> get equiposActivos {
    final equipos = <String, Map<String, dynamic>>{};
    for (final posicion in posicionesActivas) {
      final id = posicion['fk_emisor']?.toString().trim() ?? '';
      if (id.isEmpty) continue;
      equipos.putIfAbsent(id, () => _equipoPara(id, equipos.length + 1));
    }
    return equipos.values.toList();
  }

  static int cargarDesdeCsv(String contenido, {String? nombreArchivo}) {
    final lineas = contenido
        .replaceFirst('\uFEFF', '')
        .split(RegExp(r'\r?\n'))
        .where((linea) => linea.trim().isNotEmpty)
        .toList();
    if (lineas.length < 2) {
      throw const FormatException('El CSV no contiene registros.');
    }

    final encabezados = lineas.first
        .split(',')
        .map((valor) => valor.trim())
        .toList();
    const requeridos = {'tiempo', 'fk_emisor', 'lat_grados', 'lon_grados'};
    if (!requeridos.every(encabezados.contains)) {
      throw const FormatException(
        'El CSV debe incluir: tiempo, fk_emisor, lat_grados y lon_grados.',
      );
    }

    final posiciones = <Map<String, dynamic>>[];
    for (var indice = 1; indice < lineas.length; indice++) {
      final valores = lineas[indice].split(',');
      if (valores.length < encabezados.length) continue;
      final fila = <String, String>{
        for (var i = 0; i < encabezados.length; i++)
          encabezados[i]: valores[i].trim(),
      };
      final latitud = double.tryParse(fila['lat_grados'] ?? '');
      final longitud = double.tryParse(fila['lon_grados'] ?? '');
      final emisor = fila['fk_emisor'] ?? '';
      final tiempo = DateTime.tryParse(
        (fila['tiempo'] ?? '').replaceFirst(' ', 'T'),
      );
      if (latitud == null ||
          longitud == null ||
          emisor.isEmpty ||
          tiempo == null) {
        continue;
      }
      if (latitud == 0 || longitud == 0) continue;
      posiciones.add({
        ...fila,
        'id_posicion': fila['id_posicion']?.isNotEmpty == true
            ? fila['id_posicion']
            : 'csv-$indice',
        'tiempo': tiempo.toIso8601String(),
        'fk_emisor': emisor,
        'lat_grados': latitud,
        'lon_grados': longitud,
      });
    }
    if (posiciones.isEmpty) {
      throw const FormatException(
        'No se encontraron coordenadas y fechas validas.',
      );
    }

    final ordenEquipos = <String, int>{};
    for (final posicion in posiciones) {
      final id = posicion['fk_emisor'].toString();
      final orden = ordenEquipos.putIfAbsent(id, () => ordenEquipos.length + 1);
      posicion.addAll(_equipoPara(id, orden));
    }
    posiciones.sort(
      (a, b) => a['tiempo'].toString().compareTo(b['tiempo'].toString()),
    );
    _posicionesCargadas = posiciones;
    nombreArchivoCargado = nombreArchivo;
    return posiciones.length;
  }

  static Map<String, dynamic> _equipoPara(String id, int orden) => {
    'id_equipo_control': id,
    'fk_empresa': equipo['fk_empresa'],
    'tipo_equipo_control': equipo['tipo_equipo_control'],
    'codigo_equipo_control': 'VOL-${orden.toString().padLeft(3, '0')}',
    'nombre': 'Volquete $orden',
    'id_equipo_fabrica': id,
    'activo': true,
    'fecha_final': null,
  };

  static List<Map<String, dynamic>> posiciones() {
    final inicio = DateTime(2026, 7, 23, 19, 7, 28);
    return _coordenadas.split(',').indexed.map((entrada) {
      final valores = entrada.$2.split(':');
      // El CSV tiene dos intervalos no uniformes (6 s y 15 s); se preservan
      // para que el transcurso simulado mantenga su horario real.
      final ajusteSegundos = entrada.$1 >= 60
          ? 12
          : entrada.$1 >= 54
          ? 1
          : 0;
      final tiempo = inicio.add(
        Duration(seconds: entrada.$1 * 5 + ajusteSegundos),
      );
      return <String, dynamic>{
        'id_posicion': 'demo-${entrada.$1}',
        'tiempo': tiempo.toIso8601String(),
        'fk_receptor': idReceptor,
        'fk_emisor': idEquipo,
        'epoca_rx': 1784851648 + entrada.$1 * 5 + ajusteSegundos,
        'lat_grados': double.parse(valores[0]),
        'lon_grados': double.parse(valores[1]),
        'alt_msnm_m': 4813,
        ...equipo,
      };
    }).toList();
  }
}
