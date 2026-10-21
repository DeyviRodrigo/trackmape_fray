/// Responsabilidad: Armar el comando que da de baja un equipo: fecha_final =
/// hoy. No se borra nada (eliminar esta prohibido).
library;

import 'package:trackmape_sup/datos2/contratos/tablas/campo_escritura.dart';
import 'package:trackmape_sup/datos2/tablas/equipos_control/equipos_control_comandos.dart';

class EquipoBajaComandoTransformador {
  static EquiposControlActualizar darBaja(DateTime ahora) =>
      EquiposControlActualizar(
        fechaFinal: CampoEscritura.valor(
          DateTime(ahora.year, ahora.month, ahora.day),
        ),
      );
}
