/// Responsabilidad: Unir las paginas de Equipos en el esquema central y
/// manejar la pila de hojas: el listado abajo, y encima el detalle o el
/// formulario que esten abiertos.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trackmape_sup/widgets2/estructuras/esquemas/esquema_central.dart';
import 'package:trackmape_sup/widgets2/ventanas/notificaciones/aviso.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/proveedores/equipos_datos_proveedor.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/proveedores/equipos_detalle_proveedor.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/funciones/proveedores/equipos_formulario_proveedor.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/paginas/equipos_datos_pagina.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/paginas/equipos_detalle_pagina.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/paginas/equipos_formulario_pagina.dart';
import 'package:trackmape_sup/pestanas/formularios/equipos/ventanas/equipos_descartar_ventana.dart';

class EquiposPestana extends ConsumerStatefulWidget {
  const EquiposPestana({super.key});

  @override
  ConsumerState<EquiposPestana> createState() => _EquiposPestanaState();
}

// HOJAS - Lo que se apila sobre el listado
sealed class _Hoja {
  const _Hoja();
}

final class _HojaDetalle extends _Hoja {
  const _HojaDetalle(this.id);
  final String id;
}

final class _HojaFormulario extends _Hoja {
  const _HojaFormulario(this.id);

  /// Nulo = alta.
  final String? id;
}

class _EquiposPestanaState extends ConsumerState<EquiposPestana> {
  List<_Hoja> _pila = const [];

  String? get _detalleAbierto {
    for (final hoja in _pila.reversed) {
      if (hoja is _HojaDetalle) return hoja.id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return EsquemaCentral(
      principal: EquiposDatosPagina(
        seleccionadoId: _detalleAbierto,
        alSeleccionar: _abrirDetalle,
        alAgregar: () => _abrirFormulario(null),
      ),
      hoja: _pila.isEmpty ? null : _construirHoja(_pila.last),
    );
  }

  Widget _construirHoja(_Hoja hoja) => switch (hoja) {
    _HojaDetalle(:final id) => EquiposDetallePagina(
      key: ValueKey('detalle-$id'),
      id: id,
      alCerrar: _cerrarHoja,
      alEditar: () => _abrirFormulario(id),
      alDarDeBaja: () => ref.invalidate(equiposDatosProveedor),
    ),
    _HojaFormulario(:final id) => EquiposFormularioPagina(
      key: ValueKey('formulario-$id'),
      id: id,
      alCerrar: _cerrarHoja,
      alGuardar: () => _alGuardar(id),
    ),
  };

  // ABRIR DETALLE - Reemplaza la pila: se cambia de equipo, no se apila otro.
  Future<void> _abrirDetalle(String id) async {
    if (!await _puedeSalirDelFormulario()) return;
    setState(() => _pila = [_HojaDetalle(id)]);
  }

  Future<void> _abrirFormulario(String? id) async {
    if (!await _puedeSalirDelFormulario()) return;
    setState(() {
      // Agregar desde el listado no se apila sobre un detalle ajeno.
      final base = id == null ? const <_Hoja>[] : _pila;
      _pila = [...base, _HojaFormulario(id)];
    });
  }

  // CERRAR - Quita solo la hoja de arriba; la de abajo vuelve como estaba.
  Future<void> _cerrarHoja() async {
    if (!await _puedeSalirDelFormulario()) return;
    setState(() => _pila = _pila.sublist(0, _pila.length - 1));
  }

  void _alGuardar(String? id) {
    ref.invalidate(equiposDatosProveedor);
    if (id != null) ref.invalidate(equiposDetalleProveedor(id));
    Aviso.mostrar(context, id == null ? 'Equipo creado' : 'Equipo guardado');
    setState(() => _pila = _pila.sublist(0, _pila.length - 1));
  }

  /// Si arriba hay un formulario con cambios sin guardar, pregunta.
  Future<bool> _puedeSalirDelFormulario() async {
    final arriba = _pila.isEmpty ? null : _pila.last;
    if (arriba is! _HojaFormulario) return true;
    final formulario = ref.read(equiposFormularioProveedor(arriba.id));
    if (!formulario.tieneCambiosPendientes) return true;
    return EquiposDescartarVentana.mostrar(context);
  }
}
