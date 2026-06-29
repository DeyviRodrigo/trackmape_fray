# trackmape_sup

Supervisor de flota para monitoreo, consulta historica, simulacion de transcurso y validacion de rutas/equipos.

## Proposito de este README

Este archivo sera nuestra bitacora de trabajo del proyecto.
Cada vez que avancemos en una conversacion, aqui dejaremos registro de:

- Cambios implementados.
- Archivos creados, modificados o eliminados.
- Errores encontrados.
- Conflictos o pendientes detectados.
- Decisiones funcionales importantes.

La idea es que este documento sirva como guia rapida para retomar el trabajo sin perder contexto.

## Regla de documentacion acordada

Desde esta conversacion:

- Todo cambio funcional relevante debe registrarse en este `README.md`.
- Si se crea un archivo, se debe anotar.
- Si se modifica un archivo importante, se debe anotar.
- Si se elimina un archivo, tambien se debe anotar explicitamente.
- Si aparece un error, timeout, conflicto o comportamiento inesperado, se debe dejar registro breve.

## Estado actual del proyecto

- Modulo de monitoreo en vivo con mapa y marcadores.
- Modulo de consulta historica por fecha.
- Modulo de transcurso simulado.
- Modulo de validacion y comparativo de rutas en desarrollo activo.

## Bitacora de sesiones

### 2026-06-28

#### Objetivo trabajado

Revisar la rama online `origin/main`, integrarla con la version local y dejar la app adaptada al formato de `arquitectura_modelo` sin perder funcionalidad.

#### Cambios realizados

1. Se confirmo que `main` local y `origin/main` tenian historiales sin base comun; por eso el `git push` era rechazado como `non-fast-forward`.
2. Se reviso el contenido de `origin/main`: base Flutter, paginas legacy de monitoreo/estadistica, `main.dart`, `pubspec`, `widget_test` y una pagina nueva `lib/funciones/monitoreo/presentacion/paginas/pagina_conductor.dart`.
3. Se preparo un merge de historiales conservando el arbol local como version final, porque la rama local ya contiene la arquitectura nueva de `app`, `datos`, `modulos`, `widgets`, tokens y navegacion principal.
4. No se adopto la pagina de conductor remota dentro de `monitoreo`, porque implementa Supabase, GPS e identificador de dispositivo directamente en la vista. El proyecto local ya tiene ese flujo mejor separado en `lib/funciones/conductor/` con repositorio, servicios e identificador.
5. No se adopto el `widget_test.dart` remoto, porque corresponde al contador inicial de Flutter y no aplica a `AplicacionTrackMAPE`.
6. Se mantiene `main.dart` local con `.env`, `publishableKey` y `TemaBase.oscuro()`, evitando volver a credenciales hardcodeadas y tema legacy.
7. La navegacion principal mantiene el menu forzado a cinco secciones del modelo:
   - Encabezado.
   - Formularios.
   - Informes.
   - Configuraciones.
   - Sesion.
8. Los filtros globales se mantienen fuera del encabezado, dentro del contenido superior reusable.

#### Archivos modificados

- `README.md`
- `informe_adaptacion_arquitectura.md`
- `test/widget_test.dart`

#### Errores o conflictos encontrados

- El rechazo de `git push` se debia a que `origin/main` tenia commits que no estaban en la rama local y ademas no habia base comun entre historiales.
- El merge se resolvio conservando la version local adaptada a arquitectura, sin forzar push ni sobrescribir la rama remota.
- `arquitectura_modelo` aparece como subrepositorio con cambios internos no relacionados; no se incluye en esta version.
- `flutter analyze --no-pub` reporta 160 avisos/infos legacy, sin errores de compilacion de la integracion.
- `flutter test --no-pub` ya no falla por `test/widget_test.dart`; queda fallando `test/servicio_metricas_operador_test.dart` porque espera conteos `1` y `3`, pero el servicio devuelve `0`.

#### Verificaciones realizadas

- `dart analyze lib\app\tokens lib\widgets lib\main.dart lib\funciones\navegacion\presentacion\contenedor_principal.dart test\widget_test.dart`: sin issues.
- `flutter build web --no-pub`: correcto.
- `flutter test --no-pub`: falla solo por los asserts pendientes de metricas de operador.

#### Pendientes

- Reparar las pruebas legacy antes de usar `flutter test` como bloqueo obligatorio.
- Continuar migrando pantallas legacy para que consuman tokens, widgets y conexiones de modulo en vez de colores o Supabase directo.

### 2026-06-06

#### Objetivo trabajado

Crear una hoja admin para dibujar y administrar configuracion operativa sin usar geojson.io ni pegar JSON manualmente.

#### Cambios realizados

1. El modulo GIS de Flutter se adapto al modelo de prueba de dos tablas:
   - `pr_geometrias_operativas`
   - `pr_elementos_operativos`
2. `Stream` e `Historico` siguen usando las mismas capas visuales, pero ahora las leen desde las tablas `pr_`.
3. Se agrego la pagina admin `Configuracion Operativa`.
4. La nueva pagina permite seleccionar empresa, sede opcional, categoria (`area`, `ruta`, `punto`), tipo operativo, nombre, descripcion, color, prioridad y estado activo.
5. El mapa permite dibujar por toques:
   - `area` genera `Polygon`.
   - `ruta` genera `LineString`.
   - `punto` genera `Point`.
6. Se agregaron acciones para crear, listar, activar/desactivar y eliminar elementos de prueba.
7. Se agrego la hoja al menu lateral admin sin agregarla a la barra inferior.

#### Archivos creados

- `database/pr_configuracion_operativa_supabase.sql`
- `lib/funciones/gis/presentacion/paginas/pagina_configuracion_operativa.dart`

#### Archivos modificados

- `lib/funciones/gis/datos/modelos/modelo_gis.dart`
- `lib/funciones/gis/datos/repositorios/repositorio_gis.dart`
- `lib/funciones/gis/presentacion/widgets/capas_gis_mapa.dart`
- `lib/funciones/navegacion/presentacion/contenedor_principal.dart`
- `README.md`

#### Pendientes

- Probar guardado real contra Supabase con permisos/RLS de las tablas `pr_`.
- Validar visualmente que las areas/rutas creadas aparezcan en `Stream` e `Historico`.
- La edicion fina de vertices queda para una fase posterior.

#### Ajuste posterior

Se retiraron las coordenadas operativas quemadas en codigo para `Carga` y `Chute`:

1. `Stream` ya no dibuja circulos ni etiquetas fijas de carga/chute desde codigo.
2. `Historico` ya no dibuja esas geocercas fijas.
3. `ConfiguracionMetricasOperador.porDefecto` quedo sin puntos de carga/descarga y con radios operativos en `0.0`.
4. Las areas/rutas/puntos operativos deben crearse manualmente desde la hoja `Configuracion Operativa` y cargarse desde Supabase.

#### Importacion KML

Se agrego importacion KML al dashboard `Configuracion Operativa`:

1. Se agregaron dependencias directas `file_picker` y `xml`.
2. Se creo un importador KML que lee `Placemark` y convierte `Point`, `LineString`, `Polygon` y `MultiGeometry` a GeoJSON.
3. La hoja permite seleccionar archivo `.kml` o pegar texto KML manualmente.
4. Antes de guardar se muestra una vista previa con nombre, categoria detectada, tipo operativo, color, prioridad, activo y seleccion individual.
5. El guardado reutiliza las tablas `pr_geometrias_operativas` y `pr_elementos_operativos`; no se agregaron tablas nuevas.
6. En v1 no se soporta `.kmz`; solo `.kml`.

### 2026-06-04

#### Objetivo trabajado

Implementar GIS v1 liviano para mostrar areas operativas y rutas configurables sin activar ciclos automaticos.

#### Cambios realizados

1. Se creo el script manual `database/gis_v1_supabase.sql` para Supabase SQL Editor.
2. El script define `tipos_area`, `areas_operativas` y `rutas_operativas` con GeoJSON en `jsonb`.
3. Se agregaron tipos base: Corte, Carga, Descarga, Chute, Desmonte y Estacionamiento.
4. Se agrego un modulo Flutter `gis` con modelos, repositorio Supabase y constructor de capas para `flutter_map`.
5. `Stream` ahora puede pintar poligonos y rutas por empresa sin alterar el tracking GPS.
6. `Historico` ahora puede pintar las mismas capas GIS junto con las rutas historicas.
7. Se agregaron toggles visuales `Areas` y `Rutas` en Stream e Historico.
8. Si las tablas GIS aun no existen o estan vacias, el repositorio devuelve capas vacias y no rompe el mapa.

#### Archivos creados

- `database/gis_v1_supabase.sql`
- `lib/funciones/gis/datos/modelos/modelo_gis.dart`
- `lib/funciones/gis/datos/repositorios/repositorio_gis.dart`
- `lib/funciones/gis/presentacion/widgets/capas_gis_mapa.dart`

#### Archivos modificados

- `lib/funciones/monitoreo/presentacion/paginas/pagina_stream.dart`
- `lib/funciones/monitoreo/presentacion/paginas/pagina_historico.dart`
- `README.md`

#### Verificaciones y resultados

- `git diff --check` no reporto errores.
- `dart format` quedo en timeout.
- `flutter analyze` quedo en timeout.
- El script SQL no se ejecuto desde Codex; debe pegarse manualmente en Supabase SQL Editor.

#### Pendientes

- Ejecutar `database/gis_v1_supabase.sql` en Supabase.
- Insertar GeoJSON reales por empresa.
- Probar visualmente `Stream` e `Historico` con areas y rutas activas.
- Dejar eventos de entrada/salida y ciclos para GIS v2.

### 2026-05-23

#### Objetivo trabajado

Revisar por que la hoja `Stream` mostraba equipos, pero no pintaba marcadores GPS en vivo como una version anterior.

#### Cambios realizados

1. Se identifico que `Stream` si estaba cargando equipos filtrados, pero las posiciones dependian estrictamente de `fk_receptor`.
2. Se revisaron los CSV `empresas_rows.csv` y `equipos_control_rows.csv`; se encontro que Francisco 1 y Francisco 2 tienen receptores LoRA distintos.
3. Se agrego seleccion de receptor por empresa:
   - Francisco 1 usa `cb988466-ef79-401a-b4e9-6889f18d5466` (`HELTEC001`).
   - Francisco 2 usa `a07bb038-dcb9-466e-98c2-b0558a4363ea` (`HELTEC002`).
4. Se agrego un fallback para `posiciones_temp`: primero consulta con el receptor de la empresa seleccionada y, si no obtiene coordenadas operativas normalizadas para los equipos filtrados, vuelve a consultar sin ese filtro.
5. El fallback mantiene la validacion por empresa, tipo de equipo y match contra `equipos_control`, para evitar mostrar unidades fuera del filtro seleccionado.
6. El diagnostico de Stream usa la misma consulta con fallback para reflejar mejor si hay dato, match o coordenada invalida.

#### Archivos modificados en esta conversacion

- `lib/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart`
  - Se agrego `_obtenerPosicionesTempNormalizadas` para centralizar la consulta con fallback.
  - Se agrego `_consultarPosicionesTempRecientes` para consultar `posiciones_temp` con o sin receptor.
  - Se agrego validacion de coordenada operativa antes de decidir si se usa el fallback.

- `README.md`
  - Se registro esta revision y el ajuste aplicado.

#### Verificaciones y resultados

- Se reviso por codigo que las tarjetas de Stream provienen de `equipos_control`, mientras que los marcadores dependen de posiciones normalizadas desde `posiciones_temp`.
- `dart format` y `dart analyze` no terminaron dentro del tiempo del entorno; quedaron en timeout.

#### Errores o conflictos encontrados

- La consulta externa directa a Supabase desde PowerShell fue inestable en este entorno, aunque confirmo que el problema estaba en la etapa de filtrado/normalizacion de posiciones y no en la carga visual de equipos.

#### Ajuste temporal para APP de cliente

Se dejo la aplicacion en modo cliente simple para una entrega visual reducida:

1. La empresa por defecto ahora es Francisco 1 (`c6a59aec-29ea-4e42-8ece-581df5e4459d`).
2. La lista visible de empresas deja comentada a Francisco 2, sin eliminar sus constantes ni su receptor.
3. En `ContenedorPrincipal` se agrego `_modoClienteSimple = true`.
4. Con ese modo activo solo aparecen estas tres hojas:
   - Monitoreo en Tiempo Real
   - Consulta Historica
   - Base de Operadores
5. Las paginas Ranking, Simulacion, Rendimiento y Comparativo siguen importadas y disponibles en codigo, pero ocultas de la navegacion.
6. El selector de empresa se reemplazo visualmente por una etiqueta fija `Francisco 1`.

Para revertir este modo, cambiar `_modoClienteSimple` a `false` y volver a habilitar Francisco 2 en `empresasDashboardFrancisco`.

#### Ajuste de cola visual en Stream

Se corrigio el rastro naranja del monitoreo en vivo para que no pinte el recorrido acumulado del dia:

1. El rastro de cada unidad ahora guarda puntos con hora de lectura, no solo coordenadas.
2. La polilinea naranja se recorta contra una ventana movil de 40 segundos.
3. Si una unidad deja de enviar datos, el rastro se limpia en los refrescos de UI aunque no llegue una nueva posicion.
4. Se dejo un limite maximo de 9 puntos por unidad para representar hasta 8 tramos de 5 segundos.
5. La linea se hizo mas delgada y menos opaca para que funcione como cola reciente y no como ruta historica.
6. La cola ahora se dibuja como tramos independientes entre lecturas consecutivas; si hay un salto mayor a 8 segundos o un salto GPS demasiado largo, ese tramo no se pinta para evitar una linea recta atravesando el mapa.

Archivo modificado:

- `lib/funciones/monitoreo/presentacion/paginas/pagina_stream.dart`

Verificacion:

- `git diff --check` no reporto errores de espacios.
- `dart format`, `dart analyze` y `dart --version` quedaron en timeout en este entorno.

#### Cambio temporal de cliente a Francisco 2

Se preparo la misma version simple de cliente para la segunda empresa:

1. La empresa por defecto ahora es `EMPRESA MINERA AMS-6 SOCIEDAD ANONIMA` (`63a9ae71-8881-4333-8927-41c48b35d104`).
2. Francisco 1 quedo comentado en la lista visible, sin borrar sus constantes ni receptor.
3. El modo cliente simple sigue activo con solo tres hojas:
   - Monitoreo en Tiempo Real
   - Consulta Historica
   - Base de Operadores
4. El titulo de la cabecera ahora muestra el nombre legal de la empresa debajo del nombre de la hoja, para diferenciar la APP de cliente.
5. El receptor usado por Stream/Historico/Operadores pasa automaticamente a `a07bb038-dcb9-466e-98c2-b0558a4363ea` por el mapeo de Francisco 2.

Para volver a Francisco 1, cambiar `empresaMonitoreoFija` a `empresaFrancisco1` y volver a dejar Francisco 1 activo en `empresasDashboardFrancisco`.

#### Reactivacion de modo admin

Se devolvio la aplicacion a modo administrador para revisar ambas empresas:

1. `_modoClienteSimple` quedo en `false`.
2. El selector superior de empresa vuelve a estar visible.
3. `empresasDashboardFrancisco` vuelve a incluir:
   - Francisco 1.
   - `EMPRESA MINERA AMS-6 SOCIEDAD ANONIMA`.
4. La empresa inicial vuelve a ser Francisco 1, pero el selector permite cambiar a AMS-6.
5. Se reactivan las paginas ocultas en modo cliente: Ranking Operativo, Transcurso Simulado, Rendimiento de Operador y Comparativo de Rutas.
6. El selector se ajusto con ancho fijo y texto recortado para que el nombre largo de AMS-6 no rompa la cabecera.

### 2026-04-24

#### Objetivo trabajado

Restringir el monitoreo a una empresa y sede fijas para los trackers, y separar claramente la fuente en vivo de la fuente historica.

#### Cambios realizados

1. Se agrego soporte de filtro opcional por `fk_empresa`, `fk_sede` y `tipo_equipo_control` en el repositorio de monitoreo.
2. La vista `Base de Operadores` ahora solo consume trackers `SEEED WIO TRACKER L1` de:
   - empresa `c6a59aec-29ea-4e42-8ece-581df5e4459d`
   - sede `3821dbd6-5c29-49ca-b6b0-8c4201d55ffe`
3. La vista `Stream` ahora usa ese mismo filtro fijo para cargar equipos y validar posiciones en vivo provenientes de `posiciones_temp`.
4. La vista `Historico / Datos anteriores` dejo de depender de `posiciones_temp` y ahora consulta `posiciones`.
5. `Historico` ya no mezcla datos en vivo del dia actual; el seguimiento del dia de hoy queda en `Stream`.
6. Los equipos de otros tipos dentro de la misma sede, como `ESP_LORA`, `NFC`, `Biometrico` o `Vision Computacional`, quedan fuera de `Operadores`, `Stream` e `Historico` por el filtro de tipo.

#### Archivos modificados en esta conversacion

- `lib/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart`
  - Se agregaron filtros opcionales por empresa, sede y tipo de equipo.
  - `obtenerTrayectoriaPorFecha` ahora usa `posiciones` como fuente historica.
  - Se separo la normalizacion de datos en vivo (`posiciones_temp`) y datos historicos (`posiciones`).

- `lib/funciones/monitoreo/presentacion/paginas/pagina_operadores.dart`
  - Se fijo el consumo de operadores y ultimas conexiones al filtro de empresa, sede y tipo tracker.

- `lib/funciones/monitoreo/presentacion/paginas/pagina_stream.dart`
  - Se fijo el filtro de empresa, sede y tipo tracker para stream en vivo, equipos iniciales y ultimas posiciones.

- `lib/funciones/monitoreo/presentacion/paginas/pagina_historico.dart`
  - Se fijo el filtro de empresa, sede y tipo tracker para historico.
  - Se elimino la mezcla con conexiones recientes del dia actual.

#### Archivos eliminados en esta conversacion

- Ninguno.

#### Verificaciones y resultados

- Se verifico por busqueda que `pagina_operadores`, `pagina_stream` y `pagina_historico` ya consumen el filtro fijo requerido.
- Se verifico por lectura que `obtenerTrayectoriaPorFecha` ya no consulta `posiciones_temp`.

#### Errores o conflictos encontrados

- No se ejecuto `dart analyze` aun en esta conversacion al momento de registrar esta entrada.

#### Pendientes detectados

- Validar en entorno real que `posiciones.fk_emisor` llegue como `id_equipo_control` para todas las filas historicas esperadas.
- Revisar si otras vistas como `ranking`, `mapa` o `simulacion` tambien deben heredar el mismo filtro organizacional en una siguiente pasada.

### 2026-04-08

#### Objetivo trabajado

Corregir la vista `Historico` para que muestre el nombre del volquete como las otras vistas, y actualizar el punto por defecto de consulta historica, transcurso simulado y vista previa al nuevo punto de trabajo.

#### Cambios realizados

1. Se actualizo el nombre visible en historico para que priorice el `nombre` del equipo/volquete y use el codigo solo como respaldo.
2. Se cambio la coordenada por defecto al punto de trabajo:
   - Latitud: `-14.665728`
   - Longitud: `-69.465525`
3. Se unifico esa coordenada en una constante compartida para evitar seguir dejando valores hardcodeados distintos entre pantallas.

#### Archivos creados

- `lib/core/mapas/coordenadas_operacion.dart`
  - Se creo para centralizar la coordenada del punto de trabajo:
    - `puntoTrabajoLatitud`
    - `puntoTrabajoLongitud`
    - `puntoTrabajoLatLng`

#### Archivos modificados en esta conversacion

- `lib/funciones/monitoreo/presentacion/paginas/pagina_historico.dart`
  - Se cambio el centro inicial del mapa al nuevo punto de trabajo.
  - Se cambio la etiqueta de unidad para mostrar el nombre del volquete como en las otras vistas.
  - Se reutilizo la nueva constante compartida de coordenadas.

- `lib/funciones/monitoreo/presentacion/paginas/pagina_simulacion.dart`
  - Se cambio el centro inicial por defecto al nuevo punto de trabajo.
  - Se actualizo el fallback de centro inicial para usar la nueva coordenada.

- `lib/funciones/monitoreo/presentacion/paginas/pagina_stream.dart`
  - Se cambio la coordenada por defecto de vista previa cuando no hay ultima posicion valida.

#### Archivos eliminados en esta conversacion

- Ninguno.

#### Verificaciones y resultados

- Se confirmo por busqueda que en las pantallas de monitoreo ajustadas ya no quedo la coordenada anterior `(-15.488405, -70.150497)`.
- Se verifico por diff que historico ahora usa la etiqueta del volquete y que stream/simulacion usan el nuevo punto de trabajo.

#### Errores o conflictos encontrados

- `dart format` no termino dentro del tiempo disponible del entorno.
- `dart analyze` tampoco termino dentro del tiempo disponible del entorno.
- Existen otros cambios previos en el repositorio que no fueron tocados en esta conversacion y no se mezclaron con este ajuste.

#### Pendientes detectados

- Revisar si otras pantallas fuera de monitoreo tambien deben migrar al nuevo punto de trabajo, por ejemplo:
  - validacion
  - comparativo de rutas
- Ejecutar formateo y analisis completos cuando el entorno permita mas tiempo o cuando hagamos una pasada de limpieza.

#### Ajuste adicional en la misma fecha

Se actualizo la pantalla `Base de Operadores` para que solo muestre equipos cuyo campo `tipo_equipo_control` sea exactamente `SEEED WIO TRACKER L1`.

#### Archivos modificados por este ajuste adicional

- `lib/funciones/monitoreo/datos/repositorios/repositorio_monitoreo.dart`
  - Se agrego soporte de filtro opcional por `tipo_equipo_control` en `streamEquipos`.
  - Se definio la constante `SEEED WIO TRACKER L1` para reutilizarla sin hardcodearla en la vista.

- `lib/funciones/monitoreo/presentacion/paginas/pagina_operadores.dart`
  - La vista `Base de Operadores` ahora consume `streamEquipos` filtrando solo `SEEED WIO TRACKER L1`.

#### Mejora de perfil de operador

Se inicio la evolucion de la vista de perfil para que deje de ser solo un formulario basico y pase a mostrar estadisticas reales de la unidad seleccionada.

#### Archivos modificados por la mejora de perfil

- `lib/funciones/monitoreo/presentacion/paginas/perfil_equipo.dart`
  - Se reemplazo la vista basica de edicion por una vista tipo dashboard.
  - Ahora muestra estado activo/inactivo basado en el ultimo GPS.
  - Muestra `conectado desde`, velocidad actual, velocidad maxima, velocidad promedio y recorrido del dia.
  - Se agregaron accesos para abrir tracking en vivo o historico solo de la unidad seleccionada.

- `lib/funciones/monitoreo/presentacion/paginas/pagina_stream.dart`
  - Se agrego soporte para abrir la vista filtrada por una sola unidad.

- `lib/funciones/monitoreo/presentacion/paginas/pagina_historico.dart`
  - Se agrego soporte para abrir la vista filtrada por una sola unidad.

#### Ajuste de estructura visual del perfil

Se adapto la pantalla de perfil a una estructura vertical tipo dashboard movil, siguiendo la referencia funcional definida para tarjetas apiladas y bloques grandes/pequenos.

#### Cambios visuales aplicados

- `lib/funciones/monitoreo/presentacion/paginas/perfil_equipo.dart`
  - El layout ahora sigue una estructura movil responsiva por bloques.
  - Los datos no implementados aun se muestran como `Sin dato`.
  - Se conservaron los accesos filtrados por unidad para historial y tracking en vivo.

#### Refinamiento de layout movil del perfil

Se corrigio la composicion para que la pantalla se comporte como una vista completa de celular:

- columna centrada con ancho controlado,
- bloques grandes con dos tarjetas pequenas al costado,
- un solo boton final,
- y selector inferior con las dos opciones de consulta por unidad.

#### Mejora de navegacion en vistas filtradas

Se agrego navegacion de retorno visible cuando se abre una vista filtrada desde el perfil del operador.

- `lib/funciones/monitoreo/presentacion/paginas/pagina_stream.dart`
  - Ahora muestra boton flotante de retroceso cuando se abre el tracking en vivo de una sola unidad.

- `lib/funciones/monitoreo/presentacion/paginas/pagina_historico.dart`
  - Ahora muestra boton flotante de retroceso cuando se abre el historial filtrado de una sola unidad.

#### Ajuste fino de composicion del dashboard movil

Se corrigio la proporcion general del perfil para que el layout siga mejor la maqueta de referencia:

- ancho centrado tipo celular aun en pantallas grandes,
- bloques apilados tomando una mitad visual clara,
- bloque grande principal con dos bloques pequenos al costado,
- y tarjetas laterales compactas para evitar desbordes.

#### Refinamiento visual de paleta del perfil

Se mejoro la combinacion de colores del dashboard del perfil para alinearlo mejor con el sistema visual:

- base neutra oscura,
- acentos naranjas y amarillos para metricas prioritarias,
- verde para estados positivos,
- y superficies contrastadas para que no todos los recuadros se vean iguales.

#### Correccion de navegacion desde el perfil

Se corrigio un problema de interaccion al abrir vistas filtradas desde el selector inferior del perfil:

- `lib/funciones/monitoreo/presentacion/paginas/perfil_equipo.dart`
  - Antes se navegaba mientras el modal inferior aun se estaba cerrando.
  - Ahora primero se cierra el `bottom sheet` y luego se navega a `tracking en vivo` o `datos anteriores`.
  - Esto evita que en web quede una capa modal bloqueando los toques en la pantalla siguiente.

## Proximo uso de este documento

En las siguientes conversaciones se debe agregar una nueva entrada a la seccion `Bitacora de sesiones` con:

1. Fecha.
2. Objetivo.
3. Cambios realizados.
4. Archivos creados/modificados/eliminados.
5. Errores o conflictos.
6. Pendientes.
