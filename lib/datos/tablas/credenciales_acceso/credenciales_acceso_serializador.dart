import 'package:trackmape_sup/datos/interfaces/serializador_contrato.dart';
import 'package:trackmape_sup/datos/tablas/credenciales_acceso/credenciales_acceso_modelo.dart';

class CredencialesAccesoSerializador
    implements SerializadorContrato<CredencialesAccesoModelo> {
  @override
  Map<String, dynamic> aJson(CredencialesAccesoModelo modelo) {
    return {
      if (modelo.id_credencial.isNotEmpty)
        'id_credencial': modelo.id_credencial,
      'fk_trabajador': modelo.fk_trabajador,
      'tecnologia': modelo.tecnologia,
      'valor': modelo.valor,
      'clave': modelo.clave,
      'activo': modelo.activo,
    };
  }
}
