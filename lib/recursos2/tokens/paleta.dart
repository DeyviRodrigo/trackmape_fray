/// Responsabilidad: Definir la paleta neutral de colores crudos. No tiene
/// significado: los temas asignan estos valores a roles semánticos.
///
/// Los widgets NO deben usar esta clase directamente; usan `context.colores`.
library;

import 'package:flutter/material.dart';

abstract final class Paleta {
  // ABSOLUTOS
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color negro = Color(0xFF000000);
  static const Color transparente = Color(0x00000000);

  // PIZARRA - Neutros con matiz azulado (textos, fondos, bordes)
  static const Color pizarra50 = Color(0xFFF8FAFC);
  static const Color pizarra100 = Color(0xFFF1F5F9);
  static const Color pizarra200 = Color(0xFFE2E8F0);
  static const Color pizarra300 = Color(0xFFCBD5E1);
  static const Color pizarra400 = Color(0xFF94A3B8);
  static const Color pizarra500 = Color(0xFF64748B);
  static const Color pizarra600 = Color(0xFF475569);
  static const Color pizarra700 = Color(0xFF334155);
  static const Color pizarra800 = Color(0xFF1E293B);
  static const Color pizarra900 = Color(0xFF0F172A);
  static const Color pizarra950 = Color(0xFF020617);

  // AZUL - Marca principal
  static const Color azul50 = Color(0xFFEFF6FF);
  static const Color azul100 = Color(0xFFDBEAFE);
  static const Color azul200 = Color(0xFFBFDBFE);
  static const Color azul300 = Color(0xFF93C5FD);
  static const Color azul400 = Color(0xFF60A5FA);
  static const Color azul500 = Color(0xFF3B82F6);
  static const Color azul600 = Color(0xFF2563EB);
  static const Color azul700 = Color(0xFF1D4ED8);
  static const Color azul800 = Color(0xFF1E40AF);
  static const Color azul900 = Color(0xFF1E3A8A);
  static const Color azul950 = Color(0xFF172554);

  // CELESTE - Marca secundaria e información
  static const Color celeste50 = Color(0xFFF0F9FF);
  static const Color celeste100 = Color(0xFFE0F2FE);
  static const Color celeste400 = Color(0xFF38BDF8);
  static const Color celeste600 = Color(0xFF0284C7);
  static const Color celeste700 = Color(0xFF0369A1);
  static const Color celeste900 = Color(0xFF0C4A6E);
  static const Color celeste950 = Color(0xFF082F49);

  // VIOLETA - Acento
  static const Color violeta100 = Color(0xFFEDE9FE);
  static const Color violeta400 = Color(0xFFA78BFA);
  static const Color violeta500 = Color(0xFF8B5CF6);
  static const Color violeta600 = Color(0xFF7C3AED);
  static const Color violeta700 = Color(0xFF6D28D9);
  static const Color violeta900 = Color(0xFF4C1D95);

  // VERDE - Éxito
  static const Color verde50 = Color(0xFFF0FDF4);
  static const Color verde100 = Color(0xFFDCFCE7);
  static const Color verde400 = Color(0xFF4ADE80);
  static const Color verde600 = Color(0xFF16A34A);
  static const Color verde700 = Color(0xFF15803D);
  static const Color verde900 = Color(0xFF14532D);
  static const Color verde950 = Color(0xFF052E16);

  // ÁMBAR - Advertencia
  static const Color ambar50 = Color(0xFFFFFBEB);
  static const Color ambar100 = Color(0xFFFEF3C7);
  static const Color ambar400 = Color(0xFFFBBF24);
  static const Color ambar600 = Color(0xFFD97706);
  static const Color ambar700 = Color(0xFFB45309);
  static const Color ambar900 = Color(0xFF78350F);
  static const Color ambar950 = Color(0xFF451A03);

  // ROJO - Error
  static const Color rojo50 = Color(0xFFFEF2F2);
  static const Color rojo100 = Color(0xFFFEE2E2);
  static const Color rojo400 = Color(0xFFF87171);
  static const Color rojo600 = Color(0xFFDC2626);
  static const Color rojo700 = Color(0xFFB91C1C);
  static const Color rojo900 = Color(0xFF7F1D1D);
  static const Color rojo950 = Color(0xFF450A0A);
}
