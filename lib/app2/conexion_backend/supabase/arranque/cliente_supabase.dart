/// Responsabilidad: Exponer el cliente Supabase activo de la aplicacion.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

// CLIENTE SUPABASE - Cliente unico para lecturas, escrituras, RPC y tiempo real
SupabaseClient get clienteSupabase => Supabase.instance.client;
