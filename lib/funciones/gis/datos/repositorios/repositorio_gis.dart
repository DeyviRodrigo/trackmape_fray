import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trackmape_sup/funciones/gis/datos/modelos/modelo_gis.dart';

class DatosGisOperativos {
  const DatosGisOperativos({required this.elementos});

  final List<ElementoOperativo> elementos;

  static const vacio = DatosGisOperativos(elementos: []);

  List<ElementoOperativo> get areas => elementos
      .where((elemento) => elemento.esArea && elemento.tieneGeometriaValida)
      .toList();

  List<ElementoOperativo> get rutas => elementos
      .where((elemento) => elemento.esRuta && elemento.tieneGeometriaValida)
      .toList();

  List<ElementoOperativo> get puntos => elementos
      .where((elemento) => elemento.esPunto && elemento.tieneGeometriaValida)
      .toList();
}

class RepositorioGis {
  RepositorioGis({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  static const Duration _ttlCache = Duration(minutes: 3);
  static final Map<String, _CacheDatosGis> _cache = {};

  Future<DatosGisOperativos> obtenerDatosOperativos({
    required String fkEmpresa,
    String? fkSede,
    bool soloActivos = true,
  }) async {
    final empresa = fkEmpresa.trim();
    final sede = fkSede?.trim();
    final cacheKey = 'pr_operativo::$empresa::${sede ?? ''}::$soloActivos';
    final cache = _cache[cacheKey];
    if (cache != null && !cache.expirado) return cache.data;

    if (empresa.isEmpty) return DatosGisOperativos.vacio;

    try {
      final elementos = await _consultarElementos(
        fkEmpresa: empresa,
        fkSede: sede,
        soloActivos: soloActivos,
      );
      final datos = DatosGisOperativos(elementos: elementos);
      _cache[cacheKey] = _CacheDatosGis(datos);
      return datos;
    } catch (e) {
      debugPrint('Configuracion operativa no disponible: $e');
      return DatosGisOperativos.vacio;
    }
  }

  Future<List<ElementoOperativo>> _consultarElementos({
    required String fkEmpresa,
    String? fkSede,
    required bool soloActivos,
  }) async {
    dynamic query = _supabase
        .from('pr_elementos_operativos')
        .select()
        .eq('fk_empresa', fkEmpresa);

    if (soloActivos) {
      query = query.eq('activo', true);
    }

    if (fkSede != null && fkSede.isNotEmpty) {
      query = query.or('fk_sede.is.null,fk_sede.eq.$fkSede');
    }

    final respuesta = await query
        .order('prioridad', ascending: true)
        .order('fecha_creacion', ascending: true);

    return List<Map<String, dynamic>>.from(
      respuesta,
    ).map(ElementoOperativo.fromJson).toList();
  }

  Future<List<SedeOperativa>> obtenerSedesPorEmpresa(String fkEmpresa) async {
    final empresa = fkEmpresa.trim();
    if (empresa.isEmpty) return const [];

    try {
      final respuesta = await _supabase
          .from('sedes')
          .select()
          .eq('fk_empresa', empresa)
          .timeout(const Duration(seconds: 10));

      return List<Map<String, dynamic>>.from(respuesta)
          .map(SedeOperativa.fromJson)
          .where((sede) => sede.id.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('No se pudieron cargar sedes: $e');
      return const [];
    }
  }

  Future<void> crearElementoOperativo({
    required String fkEmpresa,
    required String? fkSede,
    required String categoria,
    required String tipoOperativo,
    required String nombre,
    required String descripcion,
    required String color,
    required int prioridad,
    required bool activo,
    required Map<String, dynamic> geojson,
  }) async {
    final categoriaNormalizada = categoria.toLowerCase().trim();
    final tipoGeometria = tipoGeometriaParaCategoria(categoriaNormalizada);
    if (tipoGeometria.isEmpty) {
      throw ArgumentError('Categoria no soportada: $categoria');
    }

    final datosElemento = <String, dynamic>{
      'fk_empresa': fkEmpresa.trim(),
      'categoria': categoriaNormalizada,
      'tipo_operativo': tipoOperativo.trim(),
      'nombre': nombre.trim(),
      'descripcion': descripcion.trim(),
      'geojson': geojson,
      'color': color.trim(),
      'prioridad': prioridad,
      'activo': activo,
    };

    final sede = fkSede?.trim();
    if (sede != null && sede.isNotEmpty) {
      datosElemento['fk_sede'] = sede;
    }

    await _supabase.from('pr_elementos_operativos').insert(datosElemento);
    limpiarCache();
  }

  Future<void> actualizarActivoElemento({
    required String idElemento,
    required bool activo,
  }) async {
    await _supabase
        .from('pr_elementos_operativos')
        .update({'activo': activo})
        .eq('id_elemento', idElemento);
    limpiarCache();
  }

  Future<void> actualizarElementoOperativo({
    required String idElemento,
    required String fkEmpresa,
    required String? fkSede,
    required String categoria,
    required String tipoOperativo,
    required String nombre,
    required String descripcion,
    required String color,
    required int prioridad,
    required bool activo,
    required Map<String, dynamic> geojson,
  }) async {
    final categoriaNormalizada = categoria.toLowerCase().trim();
    final tipoGeometria = tipoGeometriaParaCategoria(categoriaNormalizada);
    if (tipoGeometria.isEmpty) {
      throw ArgumentError('Categoria no soportada: $categoria');
    }

    await _supabase
        .from('pr_elementos_operativos')
        .update({
          'fk_empresa': fkEmpresa.trim(),
          'fk_sede': fkSede?.trim().isEmpty == true ? null : fkSede?.trim(),
          'categoria': categoriaNormalizada,
          'tipo_operativo': tipoOperativo.trim(),
          'nombre': nombre.trim(),
          'descripcion': descripcion.trim(),
          'geojson': geojson,
          'color': color.trim(),
          'prioridad': prioridad,
          'activo': activo,
        })
        .eq('id_elemento', idElemento);
    limpiarCache();
  }

  Future<void> eliminarElemento({required String idElemento}) async {
    await _supabase
        .from('pr_elementos_operativos')
        .delete()
        .eq('id_elemento', idElemento);
    limpiarCache();
  }

  void limpiarCache() {
    _cache.clear();
  }
}

class _CacheDatosGis {
  _CacheDatosGis(this.data) : creadoEn = DateTime.now();

  final DatosGisOperativos data;
  final DateTime creadoEn;

  bool get expirado {
    return DateTime.now().difference(creadoEn) > RepositorioGis._ttlCache;
  }
}
