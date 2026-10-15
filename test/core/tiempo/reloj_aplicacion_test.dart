import 'package:flutter_test/flutter_test.dart';
import 'package:trackmape_sup/core/tiempo/reloj_aplicacion.dart';

void main() {
  test('rango diario nunca sale del unico dia permitido', () {
    final solicitado = DateTime(2026, 8, 9, 9, 12);

    final rango = RelojAplicacion.rangoDelDia(solicitado);

    if (RelojAplicacion.modoHistorico) {
      expect(rango.inicio, DateTime(2026, 8, 10));
      expect(rango.fin, DateTime(2026, 8, 10, 14, 30));
    } else {
      expect(rango.inicio, DateTime(2026, 8, 9));
      expect(rango.fin, DateTime(2026, 8, 9, 23, 59, 59, 999));
    }
  });
}
