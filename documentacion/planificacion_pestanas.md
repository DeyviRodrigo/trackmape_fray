# Planificación de pestañas — TrackMAPE

Registro de la planificación del traslado de las pantallas de TrackMAPE a la
arquitectura de módulos y pestañas de TrazMAPE. Incluye lo decidido, lo propuesto
y lo que sigue pendiente.

Modelo de composición de pantallas: ver [composicion_pantallas.md](composicion_pantallas.md).

Capturas (en [planificacion_capturas/](planificacion_capturas/); están en git de
forma temporal, se quitarán por su peso):

- `actuales/`: el menú (`00`) y las 12 pantallas actuales, numeradas como en el
  inventario de la sección 2.
- `stitch/`: los tres diseños de Equipos generados con Stitch (v1 sobrecargado,
  v2 simplificado, v3 con estado operativo).

Estado al 2026-10-21:

- **Decidido y construido:** módulo Equipos (`lib/pestanas/formularios/equipos/`),
  con listado, detalle (solo "Datos del equipo") y formulario. Falta en el
  detalle: Rendimiento del día y Recorrido del día; en el listado: Transmisión
  GPS (necesita `ultima_posicion`).
- **Propuesto, sin decidir:** el resto del mapa de módulos (sección 4). El menú
  nuevo ya lo usa como referencia (`lib/app2/navegacion/modulos_menu.dart`):
  esos módulos muestran las pantallas anteriores hasta migrarse.

---

## 1. Conceptos acordados

| Concepto | Qué es |
| --- | --- |
| **Módulo** | Opción del menú: un área de trabajo. Agrupa pestañas. Aparece en el grupo del tipo de su pestaña principal. |
| **Pestaña** | La unidad real. Vive una sola vez en el código y puede aparecer en varios módulos. |
| **Tipos de pestaña** | **Formularios**, **informes** y **herramientas**. |
| **Páginas** | Las de una pestaña de formularios son **data** (listado), **det** (detalle) y **form** (crear/editar). La página principal es **data**. Una pestaña de TrackMAPE no está obligada a tener las tres: se decide según lo que necesite. |
| **Composición** | El detalle de una pestaña puede mostrar otras pestañas (hijas) como secciones. La hija conserva su identidad, sus datos y sus acciones. |

Reglas de datos por tipo:

| Tipo | Regla |
| --- | --- |
| Formularios | 1 tabla principal + 1 vista principal. Otra entidad es otra pestaña (hija). |
| Informes | Solo vistas, sin tablas. **No hay excepciones.** |
| Herramientas | Sin definir. |

Informes y herramientas **no tienen definidas** sus páginas ni sus reglas en la
referencia de TrazMAPE; se definirán aquí.

Criterio para clasificar el tipo (**pendiente**):

- **Por los datos:** si escribe y cuántas tablas usa.
- **Por el uso:** "revisar lo que pasó" (informe) o "trabajar ahora" (herramienta).
- Propuesta: el tipo se define por el **uso**, y los datos ponen los límites.

Decisión técnica tomada: las pestañas usan **Riverpod** (estado) y **GoRouter**
(rutas), como la arquitectura. Reemplazan a `setState`/Cubit y a la navegación
por índice del contenedor principal.

---

## 2. Inventario de pantallas actuales

| # | Pantalla (menú actual) | Qué tiene | ¿Escribe? |
| --- | --- | --- | --- |
| 1 | Monitoreo en Tiempo Real | Mapa en vivo de equipos, capas áreas/rutas, alerta de equipos sin datos, panel "Diagnóstico de unidades", tarjetas por equipo (velocidad, km). Hoy pregunta cada 5 s (no usa escucha real). | No |
| 2 | Base de Operadores | Lista de equipos (trackers) con estado; Finalizar/Reactivar; abre el perfil. | Sí: `fecha_final` en `equipos_control` |
| 3 | Reporte de Turno | Tipo de reporte + descripción + "Enviar". | **No guarda nada** (no existe tabla) |
| 4 | Consulta Histórica | Calendario + mapa con los recorridos del día; capas. | No |
| 5 | Ranking Operativo | Por fecha: ranking de volquetes y cargadores con métricas. | No |
| 6 | Rendimiento de Operador | Fecha + equipo + "Calcular". Casi vacía. | No |
| 7 | Comparativo de Rutas | Equipo + fecha + filtro de análisis; ruta cruda vs reconstruida. | No |
| 8 | Diagnóstico Operativo | Mapa + panel: fecha, volquete, "Recalcular"; prueba rutas, áreas y saltos GPS. | No |
| 9 | Transcurso Simulado | Fecha + mapa + reproducción del día. | No |
| 10 | Validación de Equipos | Equipo + fecha; métricas; tramos coloreados; detalle de tramo. Su título interno dice "Rendimiento de Operador". | No |
| 11 | Configuración Operativa | Dibujar áreas/rutas/puntos en el mapa; importar KML; lista de elementos. | Sí: `pr_elementos_operativos` |
| 12 | Perfil de Operador (no está en el menú) | Detalle de un equipo: estado, velocidades, recorrido, ciclos, carga/descarga, geocercas, sobretiempo, costo de ineficiencia. Botón "Ver tracking de unidad". | No |

Fuera de esta app: la **pantalla del conductor** (registro del teléfono y envío
de GPS) es otra app guardada en el mismo proyecto; nada la abre desde aquí.

Observaciones:

- Casi todas comparten filtro de empresa, mapa, fecha y selector de equipo.
- 6, 7, 8 y 10 analizan "un equipo en un día".
- 4 y 9 muestran lo mismo (recorridos del día); 9 agrega reproducción.
- Solo 2 y 11 escriben datos.

---

## 3. Módulo Equipos — DECIDIDO

Módulo en el grupo **Formularios**. Pestaña principal **Equipos** (formulario:
tabla `equipos_control` + vista `equipos_control_vt`). Reúne lo que hoy son
"Base de Operadores" y "Perfil de Operador".

### Páginas

**data — listado de equipos**

- Acciones superiores: búsqueda (nombre o código), filtros Tipo y Estado.
- Visualización: tabla con tipo (icono + texto, una sola columna), nombre,
  código, sede, transmisión GPS (envía / sin señal) y estado (vigente /
  finalizado), si se muestran todos.
- Acción flotante: **Agregar** (solo icono).
- Barra de estado: "22 equipos · 3 sin datos".
- Tocar una fila abre el **det**. Sin botones por fila.

**det — perfil del equipo**

- Encabezado: nombre y código; acciones como iconos: **editar**, **dar de baja**
  (hoy "Finalizar"), **ver en vivo**, **cerrar**.
- Secciones:
  - Datos del equipo: código, tipo, empresa, sede, en servicio desde.
  - Rendimiento del día: velocidad actual, máxima y promedio; recorrido; ciclos
    y tiempo de ciclo (promedio, mínimo, máximo); sobretiempo, tiempo perdido,
    costo de ineficiencia.
  - Recorrido del día: mapa con su ruta.
- Posible composición (pendiente): las secciones de rendimiento y recorrido
  serían las pestañas **Rendimiento** y **Recorridos**, filtradas a este equipo.

**form — registrar / editar equipo** (nuevo: hoy solo lo hace el conductor)

- Empresa, sede, nombre, código, tipo, id de fábrica, MAC, observaciones,
  fecha de inicio. Acciones: Cancelar, Guardar.

### Navegación

| Desde | Acción | Lleva a |
| --- | --- | --- |
| Menú | Equipos | data |
| data | tocar fila | det |
| data | Agregar | form (alta) |
| det | editar | form (edición) |
| det | **ver en vivo** | Monitoreo en Vivo **filtrado a ese equipo** |
| Monitoreo en Vivo | tocar un equipo | det de Equipos |

"Ver en vivo" va en el **detalle** (icono del encabezado), no en el listado:
el modelo no permite botones por fila. Se mantienen dos entradas al mapa en
vivo: el menú (toda la flota) y el detalle (un equipo).

### Datos: qué se puede mostrar

| Dato | ¿Soportado? |
| --- | --- |
| Nombre, código, tipo, sede, empresa, fechas | Sí (base) |
| Transmisión GPS (envía / sin señal) | Sí, calculado de la última posición |
| Sobretiempo, tiempo perdido, costo de ineficiencia | Sí, ya lo calcula el perfil actual |
| Estado operativo (en carga, descarga, tránsito, detenido, sin señal) | Calculable: posición vs áreas de carga/chute (lógica de `servicio_metricas_operador`). En cola: aproximado |
| Carga en toneladas | No (no hay sensor) |
| Operador asignado | No (requiere tabla nueva) |
| Modelo, capacidad, horómetro, turno | No están en la base |

### Revisión de los diseños de Stitch

- Mantener: menú agrupado por tipo, paleta azul marino, tabla limpia con
  búsqueda y filtros, estado como etiqueta de color, detalle en panel secundario.
- Quitar: datos inventados (modelo, VIN, RTK, carga, turno, red, sincronización,
  versión), barra superior con reloj/notificaciones, tarjetas de números (los
  conteos van a la barra de estado), varios colores de acento, fuente tipo
  terminal, columna "Tipo" duplicada, botón "Filtros" del encabezado (repite los
  filtros de arriba), "Exportar" (nadie lo pidió).
- Falta: acción "ver en vivo" en el detalle.
- El usuario del menú (nombre, cargo) requiere inicio de sesión, que TrackMAPE
  no tiene hoy.

---

## 4. Propuesta de separación — REFERENCIA (no decidida)

Primera propuesta, para retomar después de Equipos.

```text
FORMULARIOS
 ├── Equipos                  ← DECIDIDO (sección 3)
 ├── Elementos Operativos     ← hoy "Configuración Operativa" (va al final)
 │     └── pestaña ELEMENTOS — formulario (pr_elementos_operativos)
 │           ├── data: mapa con áreas, rutas y puntos + lista
 │           ├── det:  un elemento
 │           ├── form: dibujar en el mapa + sus datos
 │           └── ventana: importar KML
 └── (Reporte de Turno)       ← en duda

HERRAMIENTAS (o INFORMES, según el criterio)
 └── Monitoreo en Vivo
       └── pestaña MONITOREO — una página: mapa en vivo + tarjetas de equipos
             ├── tocar un equipo → det de Equipos
             └── Estado de unidades (hoy panel "Diagnóstico" + alerta "sin datos")

INFORMES
 ├── Recorridos               ← une "Consulta Histórica" + "Transcurso Simulado"
 │     └── una página: fecha + mapa + reproducción
 ├── Ranking Operativo
 │     └── una página: fecha + ranking; tocar un equipo → su análisis
 └── Análisis de Equipo       ← une las 4 de "un equipo en un día"
       ├── selector común: equipo + fecha
       ├── pestaña RENDIMIENTO   ← "Validación de Equipos" + "Rendimiento de Operador"
       ├── pestaña RUTAS         ← "Comparativo de Rutas"
       └── pestaña DIAGNÓSTICO   ← "Diagnóstico Operativo"
```

### Antes → después

| Menú actual | Qué pasa | Dónde queda |
| --- | --- | --- |
| Monitoreo en Tiempo Real | se queda | módulo Monitoreo en Vivo |
| Base de Operadores | se renombra | módulo Equipos (data) |
| Perfil de Operador | pasa a página | det de Equipos |
| Reporte de Turno | en duda | — |
| Consulta Histórica | se une | módulo Recorridos |
| Transcurso Simulado | se une | módulo Recorridos (reproducción) |
| Ranking Operativo | se queda | módulo Ranking Operativo |
| Rendimiento de Operador | se une | Análisis de Equipo → Rendimiento |
| Validación de Equipos | se une | Análisis de Equipo → Rendimiento |
| Comparativo de Rutas | se mueve | Análisis de Equipo → Rutas |
| Diagnóstico Operativo | se mueve | Análisis de Equipo → Diagnóstico |
| Configuración Operativa | se renombra | módulo Elementos Operativos |

De 11 opciones a 6 (7 con Reporte de Turno), sin perder funciones.

### Alternativa evaluada para Monitoreo

Que el mapa en vivo sea una **visualización** del listado de la pestaña Equipos
(lista o mapa), y que el menú tenga dos módulos (Monitoreo en Vivo y Equipos)
abriendo la misma pestaña con distinta visualización. Se dejó de lado por ahora
para que el cliente encuentre fácil la transmisión en vivo; se eligió un módulo
propio que comparte el det de Equipos.

### Notas

- Configuración Operativa queda **al final**: no bloquea nada (las áreas y rutas
  ya existen en la base), es compleja y se usa poco.
- Por la regla de datos es **formulario**, no herramienta (escribe una sola
  tabla). Importar KML crea varios elementos en esa misma tabla.

---

## 5. Decisiones pendientes

1. Criterio para el tipo de pestaña: por uso o por datos.
2. Monitoreo en Vivo: herramienta o informe.
3. Unir Consulta Histórica + Transcurso Simulado en "Recorridos".
4. Unir las 4 pantallas de análisis en "Análisis de Equipo" con 3 pestañas.
5. Reporte de Turno: se queda (requiere tabla nueva) o se quita.
6. Filtro de empresa: global para toda la app o dentro de cada pestaña.
7. Estado de Unidades como pestaña propia.
8. Composición en el det de Equipos (Rendimiento y Recorridos como hijas).
9. Páginas y reglas de los tipos **informe** y **herramienta**.
10. Tiempo real sin excepciones en informes: preguntar cada pocos segundos a la
    vista, o canal Broadcast.

---

## 6. Cambios de base de datos considerados

| Cambio | Para qué | Estado |
| --- | --- | --- |
| 6 vistas `_vt` de lectura | Leer por vistas | **Aplicado** (`postgresql_cambios/001_vistas_lectura.sql`) |
| Tabla `ultima_posicion` + trigger + Realtime | Mapa en vivo con una fila por equipo | Planeado. Definir si se alimenta de `posiciones`, `posiciones_temp` o ambas; ignorar posiciones atrasadas |
| Columna `estado_operativo` (calculada por el trigger) | Mostrar en carga / descarga / tránsito sin recalcular en la app | Propuesto |
| Columna `activo` en `equipos_control` | Dar de baja como el resto de tablas (hoy usa `fecha_final`) | Pendiente de decisión |
| Tabla de asignaciones equipo–trabajador | Mostrar el operador asignado | Idea |
| Tabla de reportes de turno | Que Reporte de Turno guarde | Si se mantiene |
| RLS en las tablas | Hoy aparecen "unrestricted" | Pendiente |
| Índices en `posiciones` / `posiciones_temp` | Consultas por equipo y fecha | Verificar |

Si una pantalla necesita otra tabla, se propone y se consulta antes.

---

## 7. Prompt para Stitch

Prompt usado para generar los diseños (todas las pantallas en uno). Correcciones
posteriores: ver la revisión de diseños en la sección 3.

```text
Diseña el conjunto completo de pantallas de TrackMAPE, una aplicación web y de tablet
para supervisar una flota minera (volquetes y cargadores) con GPS. Todo el texto de la
interfaz en español. Todas las pantallas deben compartir el mismo estilo y la misma
estructura.

ESTILO
- Propón una identidad visual nueva y moderna. No uses fondo negro con acento naranja.
- Profesional y confiable, para supervisores de mina que la usan muchas horas al día:
  alto contraste, datos grandes y legibles, poco ruido visual.
- Una sola paleta, con variante clara y oscura.
- Los mapas son satelitales de una zona minera; lo que va encima (equipos, áreas, rutas)
  debe destacar sin tapar el mapa. Áreas y rutas se dibujan con su color y una etiqueta
  pequeña con su nombre.

ESTRUCTURA COMÚN (vista horizontal, pantalla ancha)
- Panel de navegación a la izquierda. Comprimido: una cinta angosta con iconos y el
  avatar abajo. Ampliado: logo y nombre "TrackMAPE", las opciones agrupadas y abajo el
  usuario con sus preferencias y el cierre de sesión. Grupos y opciones:
    Formularios: Equipos, Elementos Operativos
    Herramientas: Monitoreo en Vivo
    Informes: Recorridos, Ranking Operativo, Análisis de Equipo
- Panel principal en el centro.
- Panel secundario a la derecha, solo cuando hay un detalle o un formulario abierto,
  separado del principal por una línea vertical.
- Toda página tiene encabezado (título a la izquierda, acciones a la derecha) y
  contenido. En horizontal las páginas no tienen pie.
- Los listados tienen, en este orden: acciones superiores (búsqueda y filtros), la
  visualización (tabla, tarjetas o mapa), un botón flotante "Agregar" (solo icono) y una
  barra de estado abajo (registros mostrados, filtros activos, orden).
- No hay botón "Editar" por fila: tocar una fila abre su detalle.
- Detalle y formulario se cierran con una X en su encabezado. En el detalle, "Editar" y
  "Dar de baja" son iconos con ayuda, no botones anchos.

PANTALLAS

1. Equipos — listado con detalle abierto
   Panel principal: listado de equipos (Volquete01, Volquete02, Cargador01...). Cada
   fila: icono por tipo, nombre, código, estado (Vigente / Finalizado) e indicador de si
   envía GPS. Filtros: búsqueda, tipo de equipo, estado. Barra de estado:
   "22 equipos · 3 sin datos".
   Panel secundario: detalle de "VOLQUETE06". Acciones del encabezado: editar, dar de
   baja, ver en vivo, cerrar. Contenido en secciones:
   - Datos del equipo: código, tipo, empresa, sede, en servicio desde.
   - Rendimiento del día: velocidad actual, máxima y promedio; recorrido en km; ciclos,
     tiempo de ciclo promedio, mínimo y máximo; sobretiempo, tiempo perdido y costo de
     ineficiencia.
   - Recorrido del día: mapa pequeño con su ruta.

2. Equipos — formulario
   Panel secundario: "Registrar equipo" con empresa, sede, nombre, código, tipo de
   equipo, id de fábrica, dirección MAC, observaciones y fecha de inicio. Acciones:
   Cancelar y Guardar. Detrás, el listado de equipos.

3. Monitoreo en Vivo
   Mapa satelital ocupando todo el panel principal, con los equipos en tiempo real
   (icono por tipo y su nombre) y su rastro reciente. Arriba a la derecha:
   interruptores de capas "Áreas" y "Rutas" y botón "Estado de unidades". Aviso
   integrado: "3 equipos sin datos". Abajo, una fila horizontal desplazable de tarjetas,
   una por equipo, con nombre, velocidad y km recorridos. Tocar un equipo abre su
   detalle (el de la pantalla 1) en el panel secundario.

4. Recorridos
   Arriba: selector de fecha y de equipos. Mapa satelital con los recorridos del día,
   un color por equipo. Abajo, controles de reproducción: retroceder, reproducir,
   avanzar, velocidad (1x, 2x, 5x), hora actual y línea de tiempo de 00:00 a 23:59.
   Barra de estado: registros reproducidos.

5. Ranking Operativo
   Arriba: fecha y tipo (Volquetes / Cargadores). Resumen: "Ranking del 21/10/2026 ·
   12 volquetes · 4 cargadores". Lista ordenada con posición, nombre del equipo, número
   de ciclos destacado y métricas en chips: recorrido, velocidad promedio y máxima,
   tramos, ciclo promedio, mínimo, máximo y sobretiempo. El primer lugar resaltado.

6. Análisis de Equipo
   Arriba: selector de equipo y de fecha, comunes a toda la pantalla. Debajo, tres
   pestañas: "Rendimiento", "Rutas" y "Diagnóstico".
   - Rendimiento (activa): chips de métricas (registros válidos, km, velocidad promedio
     y corregida, paradas, tramos, tramos descartados); mapa con los tramos coloreados
     (normal, atención, crítico, descartado) y su leyenda; al lado, el detalle del tramo
     seleccionado.
   - Rutas: filtro de análisis (Nevada, Normal, Camino libre, Personalizado) y velocidad
     máxima; chips de estadísticas; dos mapas lado a lado: "Ruta cruda" y "Ruta
     reconstruida".
   - Diagnóstico: mapa con las rutas y áreas; panel con fecha, selector de volquete y
     botón "Recalcular"; resultado del diagnóstico por unidad.

7. Elementos Operativos
   Mapa satelital con las áreas, rutas y puntos de la mina. Listado lateral de
   elementos (nombre, categoría área/ruta/punto, color, activo). Botón flotante
   "Agregar" y acción "Importar KML". Panel secundario con el formulario: categoría,
   nombre, tipo operativo, descripción, prioridad, sede, color (paleta) y activo;
   instrucción "Toca el mapa para dibujar"; acciones Deshacer punto, Limpiar, Cancelar y
   Guardar.

VERSIÓN VERTICAL (celular)
Para Equipos y Monitoreo en Vivo, genera también su versión vertical: no hay panel
secundario; el detalle se superpone encima del listado; el menú es un botón de tres
líneas superpuesto en la esquina; y el listado y el detalle tienen un pie con accesos
directos.
```
