class VehiculoChecklist {
  final String idVehiculo;
  final String placa;
  final String? marca;
  final String? modelo;

  const VehiculoChecklist({
    required this.idVehiculo,
    required this.placa,
    this.marca,
    this.modelo,
  });

  factory VehiculoChecklist.fromJson(Map<String, dynamic> json) {
    return VehiculoChecklist(
      idVehiculo: json['id_vehiculo']?.toString() ?? '',
      placa: json['placa']?.toString() ?? 'S/N',
      marca: _asString(json['marca']),
      modelo: _asString(json['modelo']),
    );
  }

  String get nombreMostrar {
    final detalle = [
      marca,
      modelo,
    ].where((valor) => valor != null && valor.trim().isNotEmpty).join(' ');
    return detalle.isEmpty ? placa : '$placa - $detalle';
  }
}

class CampoChecklist {
  final String columna;
  final String titulo;

  const CampoChecklist({required this.columna, required this.titulo});
}

class SeccionChecklist {
  final String titulo;
  final List<CampoChecklist> campos;

  const SeccionChecklist({required this.titulo, required this.campos});
}

class ResultadoChecklist {
  final String idChecklist;
  final DateTime? fechaHora;
  final int estadoGeneral;

  const ResultadoChecklist({
    required this.idChecklist,
    required this.estadoGeneral,
    this.fechaHora,
  });

  factory ResultadoChecklist.fromJson(Map<String, dynamic> json) {
    return ResultadoChecklist(
      idChecklist: json['id_checklist']?.toString() ?? '',
      fechaHora: _asDate(json['fecha_hora']),
      estadoGeneral: (json['estado_general'] as num?)?.toInt() ?? 0,
    );
  }
}

const int checklistObservado = 0;
const int checklistOk = 1;
const int checklistNoAplica = 2;

const List<SeccionChecklist> seccionesChecklistPreoperacional = [
  SeccionChecklist(
    titulo: 'Documentacion',
    campos: [
      CampoChecklist(columna: 'soat', titulo: 'SOAT'),
      CampoChecklist(columna: 'licencia_conductor', titulo: 'Licencia'),
    ],
  ),
  SeccionChecklist(
    titulo: 'Exterior',
    campos: [
      CampoChecklist(columna: 'carroceria', titulo: 'Carroceria'),
      CampoChecklist(columna: 'parabrisas', titulo: 'Parabrisas'),
      CampoChecklist(columna: 'espejos', titulo: 'Espejos'),
      CampoChecklist(columna: 'limpiaparabrisas', titulo: 'Limpiaparabrisas'),
    ],
  ),
  SeccionChecklist(
    titulo: 'Neumaticos',
    campos: [
      CampoChecklist(columna: 'presion_neumaticos', titulo: 'Presion'),
      CampoChecklist(columna: 'desgaste_neumaticos', titulo: 'Desgaste'),
    ],
  ),
  SeccionChecklist(
    titulo: 'Luces',
    campos: [
      CampoChecklist(columna: 'luces_bajas', titulo: 'Bajas'),
      CampoChecklist(columna: 'luces_altas', titulo: 'Altas'),
      CampoChecklist(columna: 'luces_freno', titulo: 'Freno'),
      CampoChecklist(columna: 'direccionales', titulo: 'Direccionales'),
      CampoChecklist(columna: 'luces_emergencia', titulo: 'Emergencia'),
    ],
  ),
  SeccionChecklist(
    titulo: 'Motor',
    campos: [
      CampoChecklist(columna: 'aceite', titulo: 'Aceite'),
      CampoChecklist(columna: 'refrigerante', titulo: 'Refrigerante'),
      CampoChecklist(columna: 'bateria', titulo: 'Bateria'),
      CampoChecklist(columna: 'fugas', titulo: 'Fugas'),
    ],
  ),
  SeccionChecklist(
    titulo: 'Frenos',
    campos: [
      CampoChecklist(columna: 'freno_servicio', titulo: 'Servicio'),
      CampoChecklist(
        columna: 'freno_estacionamiento',
        titulo: 'Estacionamiento',
      ),
    ],
  ),
  SeccionChecklist(
    titulo: 'Cabina',
    campos: [
      CampoChecklist(columna: 'bocina', titulo: 'Bocina'),
      CampoChecklist(columna: 'tablero', titulo: 'Tablero'),
      CampoChecklist(columna: 'cinturon', titulo: 'Cinturon'),
    ],
  ),
  SeccionChecklist(
    titulo: 'Equipos',
    campos: [
      CampoChecklist(columna: 'gps', titulo: 'GPS'),
      CampoChecklist(columna: 'camara', titulo: 'Camara'),
    ],
  ),
  SeccionChecklist(
    titulo: 'Seguridad',
    campos: [
      CampoChecklist(columna: 'extintor', titulo: 'Extintor'),
      CampoChecklist(columna: 'botiquin', titulo: 'Botiquin'),
      CampoChecklist(columna: 'triangulos', titulo: 'Triangulos'),
      CampoChecklist(
        columna: 'martillo_emergencia',
        titulo: 'Martillo emergencia',
      ),
    ],
  ),
  SeccionChecklist(
    titulo: 'Limpieza',
    campos: [
      CampoChecklist(columna: 'limpieza_interior', titulo: 'Interior'),
      CampoChecklist(columna: 'limpieza_exterior', titulo: 'Exterior'),
    ],
  ),
];

String? _asString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

DateTime? _asDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
