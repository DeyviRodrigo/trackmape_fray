import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/modelos/equipo_rendimiento.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/modelos/punto_rendimiento.dart';
import 'package:trackmape_sup/funciones/estadistica/procesos_rendimiento/modelos/resumen_rendimiento.dart';

enum ValidationStatus { initial, loading, success, failure }

class SegmentoTrayectoria extends Equatable {
  final PuntoRendimiento inicio;
  final PuntoRendimiento fin;
  final Color color;
  final double velocidadKmh;
  final double distanciaMetros;

  const SegmentoTrayectoria({
    required this.inicio,
    required this.fin,
    required this.color,
    required this.velocidadKmh,
    required this.distanciaMetros,
  });

  @override
  List<Object?> get props => [
        inicio,
        fin,
        color,
        velocidadKmh,
        distanciaMetros,
      ];
}

class PuntoRendimientoDetallado extends Equatable {
  final PuntoRendimiento punto;
  final double velocidadKmh;
  final double distanciaMetros;
  final Color color;
  final String estado;

  const PuntoRendimientoDetallado({
    required this.punto,
    required this.velocidadKmh,
    required this.distanciaMetros,
    required this.color,
    required this.estado,
  });

  @override
  List<Object?> get props => [
        punto,
        velocidadKmh,
        distanciaMetros,
        color,
        estado,
      ];
}

class ValidationState extends Equatable {
  final ValidationStatus status;
  final List<EquipoRendimiento> equipos;
  final String? equipoSeleccionadoId;
  final DateTime fechaSeleccionada;
  final List<PuntoRendimiento> puntos;
  final List<SegmentoTrayectoria> segmentos;
  final List<PuntoRendimientoDetallado> detalles;
  final ResumenRendimiento? resumen;
  final String? error;
  final int totalRegistrosBrutos;
  final int totalRegistrosValidos;
  final bool cargandoEquipo;

  const ValidationState({
    this.status = ValidationStatus.initial,
    this.equipos = const [],
    this.equipoSeleccionadoId,
    required this.fechaSeleccionada,
    this.puntos = const [],
    this.segmentos = const [],
    this.detalles = const [],
    this.resumen,
    this.error,
    this.totalRegistrosBrutos = 0,
    this.totalRegistrosValidos = 0,
    this.cargandoEquipo = false,
  });

  factory ValidationState.initial() {
    return ValidationState(
      fechaSeleccionada: DateTime.now(),
    );
  }

  EquipoRendimiento? get equipoSeleccionado {
    final id = equipoSeleccionadoId;
    if (id == null) {
      return null;
    }
    for (final equipo in equipos) {
      if (equipo.idEquipoControl == id) {
        return equipo;
      }
    }
    return null;
  }

  ValidationState copyWith({
    ValidationStatus? status,
    List<EquipoRendimiento>? equipos,
    String? equipoSeleccionadoId,
    DateTime? fechaSeleccionada,
    List<PuntoRendimiento>? puntos,
    List<SegmentoTrayectoria>? segmentos,
    List<PuntoRendimientoDetallado>? detalles,
    ResumenRendimiento? resumen,
    String? error,
    int? totalRegistrosBrutos,
    int? totalRegistrosValidos,
    bool? cargandoEquipo,
    bool clearError = false,
    bool clearResumen = false,
  }) {
    return ValidationState(
      status: status ?? this.status,
      equipos: equipos ?? this.equipos,
      equipoSeleccionadoId: equipoSeleccionadoId ?? this.equipoSeleccionadoId,
      fechaSeleccionada: fechaSeleccionada ?? this.fechaSeleccionada,
      puntos: puntos ?? this.puntos,
      segmentos: segmentos ?? this.segmentos,
      detalles: detalles ?? this.detalles,
      resumen: clearResumen ? null : (resumen ?? this.resumen),
      error: clearError ? null : error ?? this.error,
      totalRegistrosBrutos: totalRegistrosBrutos ?? this.totalRegistrosBrutos,
      totalRegistrosValidos: totalRegistrosValidos ?? this.totalRegistrosValidos,
      cargandoEquipo: cargandoEquipo ?? this.cargandoEquipo,
    );
  }

  @override
  List<Object?> get props => [
        status,
        equipos,
        equipoSeleccionadoId,
        fechaSeleccionada,
        puntos,
        segmentos,
        detalles,
        resumen,
        error,
        totalRegistrosBrutos,
        totalRegistrosValidos,
        cargandoEquipo,
      ];
}
