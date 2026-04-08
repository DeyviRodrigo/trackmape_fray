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
