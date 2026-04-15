import 'package:flutter_test/flutter_test.dart';
import 'package:trackmape_sup/funciones/monitoreo/datos/modelos/modelo_equipo.dart';
import 'package:trackmape_sup/funciones/monitoreo/dominio/servicios/servicio_metricas_operador.dart';

void main() {
  const servicio = ServicioMetricasOperador();

  group('ServicioMetricasOperador', () {
    test('cuenta una sola llegada mientras la unidad sigue dentro del chute', () {
      final equipo = ModeloEquipo(
        id: '1',
        nombre: 'VOLQUETE01',
        tipoEquipo: 'VOLQUETE',
      );

      final puntos = [
        _punto('2026-04-15T08:00:00', -14.667833, -69.465853),
        _punto('2026-04-15T08:00:05', -14.667833, -69.465853),
        _punto('2026-04-15T08:10:00', -14.670000, -69.470000),
        _punto('2026-04-15T08:20:00', -14.667749, -69.466246),
        _punto('2026-04-15T08:20:05', -14.667749, -69.466246),
      ];

      final metricas = servicio.calcularMetricasDiarias(
        equipo: equipo,
        puntosCrudos: puntos,
      );

      expect(metricas.ciclos, 1);
      expect(metricas.tieneMuestraSuficiente, isFalse);
      expect(metricas.promedioCicloMin, isNull);
    });

    test('calcula media, moda, sobretiempo permitido y pago por tipo de unidad', () {
      final equipo = ModeloEquipo(
        id: '2',
        nombre: 'CARGADOR01',
        tipoEquipo: 'CARGADOR FRONTAL',
      );

      final puntos = [
        _punto('2026-04-15T08:00:00', -14.667833, -69.465853),
        _punto('2026-04-15T08:05:00', -14.670000, -69.470000),
        _punto('2026-04-15T08:10:00', -14.667749, -69.466246),
        _punto('2026-04-15T08:12:00', -14.670100, -69.470100),
        _punto('2026-04-15T08:15:00', -14.670200, -69.470200),
        _punto('2026-04-15T08:16:00', -14.670200, -69.470200),
        _punto('2026-04-15T08:17:00', -14.670200, -69.470200),
        _punto('2026-04-15T08:18:00', -14.670200, -69.470200),
        _punto('2026-04-15T08:19:00', -14.670200, -69.470200),
        _punto('2026-04-15T08:20:00', -14.670200, -69.470200),
        _punto('2026-04-15T08:21:00', -14.670200, -69.470200),
        _punto('2026-04-15T08:25:00', -14.668641, -69.466983),
        _punto('2026-04-15T08:30:00', -14.670300, -69.470300),
        _punto('2026-04-15T08:40:00', -14.668801, -69.466919),
      ];

      final metricas = servicio.calcularMetricasDiarias(
        equipo: equipo,
        puntosCrudos: puntos,
      );

      expect(metricas.ciclos, 3);
      expect(metricas.tieneMuestraSuficiente, isTrue);
      expect(metricas.mediaCicloMin, closeTo(13.33, 0.05));
      expect(metricas.modaCicloMin, 15);
      expect(metricas.sobretiempoPermitidoMin, closeTo(6, 0.01));
      expect(metricas.sobretiempoTotalMin, closeTo(1.66, 0.1));
      expect(metricas.pagoIneficiencia, closeTo(5.55, 0.3));
      expect(metricas.costoIneficiencia, closeTo(5.55, 0.3));
    });
  });
}

Map<String, dynamic> _punto(String tiempo, double lat, double lon) {
  return {
    'fk_emisor': 'test',
    'tiempo': tiempo,
    'lat_grados': lat,
    'lon_grados': lon,
  };
}
