import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackmape_sup/app/tokens/tokens_sistema.dart';

void main() {
  test('TemaBase.oscuro expone un tema oscuro reutilizable', () {
    final tema = TemaBase.oscuro();

    expect(tema.brightness, Brightness.dark);
    expect(tema.scaffoldBackgroundColor, ColoresApp.fondoSecundario);
  });
}
