/// Responsabilidad: Declarar la instancia activa del mensajero BaaS utilizado
/// por toda la aplicacion. Es el unico archivo a tocar al cambiar de backend.
library;

import 'package:trackmape_sup/app2/conexion_backend/contratos/mensajero_interfaz.dart';
import 'package:trackmape_sup/app2/conexion_backend/supabase/mensajero/mensajero_supabase.dart';

// INSTANCIA MENSAJERO ACTIVO - Mensajero global de Supabase
final MensajeroInterfaz mensajero = MensajeroSupabase();
