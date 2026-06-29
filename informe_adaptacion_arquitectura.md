# Informe de adaptacion de arquitectura

## 1. Objetivo

Adaptar `trackmape_fray` hacia la arquitectura de `arquitectura_modelo` sin romper la funcionalidad actual. La adaptacion se hizo como una capa paralela y compilable bajo `lib/`, sin reemplazar `main.dart`, navegacion, BLoC, paginas ni repositorios legacy.

## 2. Fuente de referencia

La estructura usada como contrato fue:

```text
arquitectura_modelo/
  documentacion/
    arquitectura.md
    reglas.md
    datos/
    modulos/
    widgets/
  lib/
    recursos/
    app/
    datos/
    widgets/
    modulos/
```

Reglas principales aplicadas:

- `recursos` no depende de ninguna capa del proyecto.
- `app` contiene configuracion global, conexion backend y tokens visuales.
- `datos` es espejo de la base de datos y solo importa `app` y `recursos`.
- `widgets` es UI pura y no accede a datos ni modulos.
- `modulos` integra `datos`, `widgets`, `app` y `recursos`.
- Las acciones de modulo no deben importar repositorios directamente; deben pasar por `[Modulo]Conexion`.
- Las tablas tienen 5 archivos por entidad: `modelo`, `deserializador`, `serializador`, `fuente`, `repositorio`.
- Las vistas tienen 4 archivos por entidad: `modelo`, `deserializador`, `fuente`, `repositorio`.
- Las RPC tienen `resultado`, `deserializador`, `validacion`, `fuente`, `repositorio`.

## 3. Adaptacion aplicada

### 3.1 `lib/app`

Se agrego:

```text
lib/app/conexion_backend/
  mensajero_intf.dart
  mensajero_activo.dart
  supabase/
    env_keys.dart
    env_loader.dart
    mensajero_supabase.dart
    supabase_client.dart
    supabase_init.dart
```

Funcion:

- Centralizar acceso a Supabase con `MensajeroIntf`.
- Evitar que la capa `datos` use `Supabase.instance.client` directamente.
- Mantener compatible el arranque actual, porque `main.dart` no fue modificado.

### 3.2 `lib/recursos`

Se agrego solo lo necesario para que `datos` compile:

```text
lib/recursos/
  errores/
    ejecutar_errores.dart
    repositorio_exception.dart
  utilidades/
    utilidades_fecha.dart
    utilidades_json.dart
```

Funcion:

- Envolver fallos de repositorio con contexto.
- Centralizar parseos de JSON, fechas y conversiones desde Supabase.

### 3.3 `lib/datos`

Se adapto la capa de datos desde `arquitectura_modelo/lib/datos`, con imports al paquete `trackmape_sup`.

Se conservaron las secciones:

```text
lib/datos/
  interfaces/
  postgresql/
  rpc/
  tablas/
  vistas/
```

Tablas copiadas/adaptadas desde el modelo:

- `carnets_plantillas_temp`
- `contrato`
- `credenciales_acceso`
- `documento_empresa_formato`
- `documentos_identidad`
- `documentos_identidad_formatos`
- `empresas`
- `idiomas`
- `monedas`
- `niveles_ubigeo`
- `paises`
- `persona_documentos`
- `personas`
- `sedes`
- `trabajadores`
- `ubigeo`
- `verificacion_empresas`

Tablas nuevas creadas porque el proyecto actual las usa y existen en `arquitectura_modelo/lib/datos/postgresql/tablas.sql`:

- `equipos_control`
- `posiciones`
- `posiciones_temp`

Vistas copiadas/adaptadas:

- `v_documento_persona_temp`
- `v_empresas`
- `v_persona_temp`
- `v_trabajador_contrato_temp`
- `v_trabajador_credenciales_temp`
- `v_trabajadores_temp`
- `v_trabajadores_temporal`

RPC copiadas/adaptadas:

- `DocsEmpresaPeruRUC_consultor`
- `DocsIdPeruDNI_consultor`

Nota tecnica:

- Los nombres de carpetas y archivos RPC conservan las mayusculas del SQL para mantener correspondencia exacta con funciones como `DocsEmpresaPeruRUC_consultor`. Se agrego `ignore_for_file: file_names` solo en esos archivos.

### 3.4 `lib/modulos`

Se agregaron conexiones de modulo:

```text
lib/modulos/
  empresas/conexion/
  personal/conexion/
  global/conexion/
  operacion/conexion/
```

`empresas`, `personal` y `global` siguen el patron de `arquitectura_modelo`.

`operacion` se agrego como adaptacion propia de este proyecto, porque `trackmape_fray` usa empresas, sedes, equipos y posiciones para monitoreo/conduccion:

```text
lib/modulos/operacion/conexion/
  operacion_conexion.dart
  operacion_conexion_activa.dart
```

Repositorios expuestos por `OperacionConexion`:

- `EmpresasRepositorio`
- `SedesRepositorio`
- `EquiposControlRepositorio`
- `PosicionesRepositorio`
- `PosicionesTempRepositorio`

### 3.5 `lib/app/tokens` y `lib/widgets`

Se agrego una base reutilizable de tokens y widgets sin introducir Riverpod ni GoRouter en este proyecto:

```text
lib/app/tokens/
  colores/
  dimensiones/
  iconos/
  integracion/
  tokens_sistema.dart

lib/widgets/
  atomos/
  moleculas/
  organismos/
```

Widgets usados ya por la navegacion principal:

- `EncabezadoOrg`
- `ContenidoOrg`
- `MenuLateralOrg`
- `SeccionSuperiorMol`
- `SeccionExpandibleMol`
- `SeccionUsuarioMol`
- `OpcionesSuperioresMol`
- `IconoAtomo`
- `TextoAtomo`
- `ItemMenuAtomo`

### 3.6 Navegacion principal

Se reemplazo el `AppBar`/`Drawer` legacy de `lib/funciones/navegacion/presentacion/contenedor_principal.dart` por organismos compartidos.

El menu queda forzado a 5 secciones:

- Encabezado
- Formularios
- Informes
- Configuraciones
- Sesion

Los filtros globales de empresa ya no viven en el encabezado. Ahora se muestran en `ContenidoOrg` como `opcionesSuperiores`, debajo del encabezado.

Tambien se corrigio la matriz de navegacion: `Rendimiento de Operador` ahora apunta a `RendimientoOperador` y no al indice de `ValidacionEquiposPage`.

## 4. Estado de funcionalidades actuales

No se reemplazaron los flujos existentes bajo:

```text
lib/core/
lib/funciones/
```

Esto evita romper:

- Conductor
- Monitoreo
- GIS
- Estadistica
- Validacion
- Navegacion principal

La nueva arquitectura queda lista para migrar esos flujos por partes. En esta fase, los repositorios legacy que llaman Supabase directamente siguen funcionando igual que antes.

## 5. Brechas detectadas

### 5.1 Tabla `pr_elementos_operativos`

El proyecto actual usa `pr_elementos_operativos` en `lib/funciones/gis/datos/repositorios/repositorio_gis.dart`, pero esa tabla no existe en `arquitectura_modelo/lib/datos/postgresql/tablas.sql`.

Decision tomada:

- No se creo capa `datos/tablas/pr_elementos_operativos` porque el pedido indica basarse en ese SQL.

Adaptacion necesaria:

- Agregar la definicion real de `pr_elementos_operativos` al SQL fuente de arquitectura, o declarar una excepcion documentada para GIS.
- Despues crear sus 5 archivos en `lib/datos/tablas/pr_elementos_operativos/`.

### 5.2 UI y visualizacion

Ya existe una base inicial de `widgets` y `app/tokens` inspirada en `arquitectura_modelo`.

Alcance actual:

- `main.dart` usa `TemaBase.oscuro()`.
- La navegacion principal usa tokens y organismos compartidos.
- El menu ya respeta las secciones del modelo.
- Los filtros globales salieron del encabezado.

Adaptacion necesaria:

- Completar los atomos/moleculas/organismos que todavia no fueron necesarios para la navegacion.
- Migrar cada pantalla legacy para que deje de usar colores hardcodeados y consuma tokens.
- Extraer filtros especificos de pagina a componentes reutilizables dentro de `modulos/global/ui/filtros` o `widgets`, segun su alcance.

### 5.3 Modulos `empresas` y `personal`

Ya existen conexiones y datos para ambos dominios, pero no se reemplazaron paginas/controladores.

Adaptacion necesaria:

- Crear o migrar paginas con el patron:
  - `[modulo]_data_pag`
  - `[modulo]_det_pag`
  - `[modulo]_form_pag`
- Crear controladores `Pure Dart` por pagina.
- Crear proveedores solo si se adopta Riverpod como en el modelo.
- Mantener UI generica en `widgets` y componentes especificos en `modulos/[modulo]/componentes`.

### 5.4 Acceso directo a Supabase en legacy

Quedan accesos directos a Supabase en:

- `lib/funciones/conductor/datos/repositorio_conductor.dart`
- `lib/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart`
- `lib/funciones/gis/datos/repositorios/repositorio_gis.dart`
- `lib/funciones/estadistica/procesos_rendimiento/repositorios/repositorio_rendimiento_operacional.dart`

Adaptacion necesaria:

- Reemplazar esos accesos progresivamente por conexiones de modulo.
- Para monitoreo/conductor/estadistica, usar `operacionConexion`.
- Para GIS, crear primero la capa de `pr_elementos_operativos`.

### 5.5 Analisis y pruebas existentes

Validacion realizada:

- `dart analyze lib/datos lib/app lib/recursos lib/modulos`: sin issues.
- `dart analyze lib/app/tokens lib/widgets lib/main.dart lib/funciones/navegacion/presentacion/contenedor_principal.dart`: sin issues.
- `flutter analyze --no-pub`: no mostro errores de compilacion, pero reporta avisos/infos existentes en `core`, `funciones` y codigo legacy.
- `flutter test --no-pub`: falla por pruebas existentes.
- `flutter build web --no-pub`: correcto.

Fallos de pruebas observados:

- `test/widget_test.dart` no tiene `main`.
- `test/servicio_metricas_operador_test.dart` espera conteos `1` y `3`, pero obtiene `0`.

## 6. Plan recomendado de migracion

### Fase 1 - Consolidar datos

- Mantener la nueva capa `lib/datos` como unica capa nueva de persistencia.
- Agregar `pr_elementos_operativos` al SQL fuente y a `lib/datos/tablas`.
- Definir si `posiciones` y `posiciones_temp` requieren metodos filtrados especificos en repositorios o si esos filtros viviran en servicios de modulo.

### Fase 2 - Migrar repositorios legacy a conexiones

- Reemplazar llamadas directas a Supabase en conductor y monitoreo por `OperacionConexion`.
- Extraer consultas complejas a servicios dentro de `lib/modulos/operacion/funciones/servicios`.
- Mantener transformadores puros para pasar de modelos de datos a modelos de vista.

### Fase 3 - Adaptar visualizacion

- Completar `widgets` por niveles:
  - `atomos/nivel3`
  - moleculas faltantes de formularios y filtros
  - organismos faltantes de pantallas operativas
- Migrar una pantalla piloto, preferiblemente empresas o personal, antes de tocar monitoreo completo.
- Reemplazar colores hardcodeados en pantallas legacy por `ColoresApp`, `Espaciado`, `Radios`, `Grosores` e `Iconos`.

### Fase 4 - Modulos empresas y personal

- Implementar paginas `data`, `det` y `form`.
- Crear controladores, validaciones, filtros, servicios y transformadores.
- Conectar feedback de operaciones al slot `barraEstado` de `ContenidoOrg`, no a Snackbars dispersos.

### Fase 5 - Limpieza de proyecto

- Excluir carpetas de referencia del analizador si `arquitectura_modelo` queda dentro del repo como insumo y no como codigo productivo.
- Reparar pruebas existentes antes de usar `flutter test` como bloqueo de calidad.
- Documentar en `documentacion/arquitectura.md` que `core/` y `funciones/` son legacy durante la migracion.

## 7. Juicio tecnico

La adaptacion inicial queda lista para que nuevos desarrollos usen la arquitectura de `arquitectura_modelo` sin romper la app actual. Todavia no conviene borrar ni reemplazar `lib/funciones` porque contiene flujos productivos de conductor, monitoreo, GIS y estadistica.

El siguiente paso de mayor impacto es migrar acceso a datos en conductor/monitoreo hacia `OperacionConexion` y luego llevar empresas/personal a paginas, controladores y componentes completos del modelo.
