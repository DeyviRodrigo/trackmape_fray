# Planificación: tabla `ultima_posicion`

Tabla nueva en la base de datos para el mapa en vivo y para mostrar el estado de
cada equipo sin recorrer todo el historial de posiciones.

**Estado:** planeada, sin SQL todavía. Se hará como
`postgresql_cambios/002_...sql` y la aplica el usuario.

## Qué resuelve

Hoy, para saber dónde está cada equipo, la app consulta `posiciones_temp` cada
5 segundos y busca la última de cada uno. Esa tabla crece sin parar.

```text
SIN la tabla nueva                    CON la tabla nueva
escuchar('posiciones_temp')           escuchar('ultima_posicion')
  → crece sin parar                     → una fila por equipo, siempre las mismas
  → miles de filas                      → si hay 40 equipos, 40 filas
```

La usarían:

- **Monitoreo en vivo:** mover los iconos del mapa al instante.
- **Listado de Equipos:** la columna "Transmisión GPS" (envía GPS / sin señal),
  que no está en `equipos_control` y sale de la última posición.
- **Estado operativo** (si se agrega la columna, ver abajo).

## Por qué tabla y no vista

| Opción | Qué es | ¿Sirve? |
| --- | --- | --- |
| Vista normal | Consulta guardada; se calcula cada vez que se lee | ❌ recorre todo el historial en cada lectura, y el tiempo real no funciona sobre vistas |
| Vista materializada | Resultado guardado, se actualiza solo con `REFRESH` | ❌ muestra datos viejos entre actualizaciones, y el tiempo real tampoco la escucha |
| **Tabla + trigger** | Tabla real con una fila por equipo; un trigger la sobrescribe | ✅ siempre al día, pequeña, y el tiempo real sí la escucha |

## Cómo funciona

```text
llega una posición nueva
   ↓ (automático, dentro de la base)
trigger: "actualiza la fila de este equipo en ultima_posicion"
   ↓
la app, que escucha ultima_posicion, recibe el cambio y mueve el icono
```

- La mantiene **la base sola**, con un trigger. La app no la escribe.
- No se usa la alternativa de que la app haga dos escrituras (posición + última):
  son dos viajes por punto y, si uno falla, quedan desincronizadas.
- El mensajero no necesita nada nuevo: `escuchar` ya existe.
- Siguiendo la regla de datos (tablas = escritura y tiempo real, vistas =
  lectura), también tendrá su vista `ultima_posicion_vt` para las lecturas
  normales. La escucha en vivo va sobre la tabla.

## Columnas (propuesta, a confirmar)

| Columna | Tipo | Para qué |
| --- | --- | --- |
| `fk_emisor` | uuid, **clave primaria** | El equipo (`equipos_control`). Una fila por equipo. |
| `id_posicion` | uuid | La posición de origen. |
| `tiempo` | timestamp | Hora de la lectura. Sirve para "sin señal" y para descartar atrasadas. |
| `lat_grados`, `lon_grados` | double | Ubicación. |
| `fk_receptor` | uuid | Receptor que la recibió. |
| `estado_operativo` | texto | Opcional, ver abajo. |

## Estado operativo (columna opcional)

Se puede calcular comparando la posición con las áreas de Configuración
Operativa (`pr_elementos_operativos`), con la misma lógica que hoy usa
`servicio_metricas_operador`:

| Estado | Cómo se sabe |
| --- | --- |
| En carga | Dentro de un área de carga |
| En descarga | Dentro de un chute o botadero |
| En tránsito | Se mueve entre carga y descarga |
| Detenido | Velocidad casi cero fuera de esas áreas |
| Sin señal | Su última posición es antigua (mejor calcularlo al leer, porque depende de la hora actual) |
| En cola | Detenido dentro del área de carga (aproximado) |

Calcularlo en el trigger evita que la app lo recalcule en cada pantalla.
`posiciones` no tiene columna de velocidad: "detenido" habría que calcularlo
comparando con la posición anterior.

## Decisiones pendientes

1. **De dónde se alimenta:** `posiciones`, `posiciones_temp` o ambas.
2. **Posiciones atrasadas:** si llega una con `tiempo` anterior a la guardada, no
   debe sobrescribirla.
3. **Estado operativo:** si se agrega ahora o después, y si "sin señal" se guarda o
   se calcula al leer.
4. **Tiempo real en un informe:** Monitoreo es un informe, y los informes solo
   leen vistas. La escucha en vivo no funciona sobre vistas. Opciones:
   - aceptar la excepción "un informe puede **escuchar** tablas, sin escribirlas";
   - preguntar a la vista cada pocos segundos, como hoy;
   - usar Broadcast (ver abajo).
5. **Permisos:** activar el tiempo real en la tabla y definir RLS (hoy las tablas
   no tienen RLS).

## Mejora futura: Broadcast

Un canal de difusión de Supabase en vez de escuchar la tabla: un trigger publica
cada cambio en el canal y las pantallas lo reciben.

- **Cuándo:** muchas pantallas mirando el mapa a la vez, la flota crece mucho, o
  el mapa en vivo se vuelve lento.
- **Por qué no ahora:** `ultima_posicion` ya reduce el volumen a una fila por
  equipo, y Broadcast agrega un trigger, el diseño de canales y sus permisos. Si
  los permisos se configuran mal, una empresa podría ver equipos de otra.
- **Impacto en el código:** solo dentro del mensajero de Supabase (`escuchar`).
  `datos2` y las pestañas no cambian.

## Cuándo se hace

Al migrar Monitoreo en vivo, o antes si el listado de Equipos necesita la columna
"Transmisión GPS".
