# Organización de `widgets2`

Qué va en cada carpeta de `lib/widgets2/`, con ejemplos de la pestaña Equipos.
Se basa en el modelo de [composicion_pantallas.md](../composicion_pantallas.md)
(punto 9, clasificación de piezas).

## Decisiones (2026-10-21)

- Se usa el modelo de **posición y responsabilidad**, no el de átomos,
  moléculas y organismos. Motivos: el tamaño de una pieza es ambiguo (¿una tabla
  es molécula u organismo?), el modelo nuevo dice dónde va cada cosa en la
  pantalla y tiene una tabla para decidir, y trazmape ya lo reemplazó tras
  usarlo. Equivalencia: primitivas ≈ átomos, componentes ≈ moléculas; en lugar
  de organismos hay estructuras con nombre de posición.
- Solo se crea lo que pide Equipos. Las carpetas aparecen con su primer archivo.
- No hay esquema de autenticación: TrackMAPE no tiene inicio de sesión.
- Panel de navegación en horizontal: arranca **ampliado** y **empuja** el
  contenido, no lo tapa; se comprime y amplía con el logo. Se aparta del
  modelo ("se comprime al pulsar fuera del panel"), que ya no aplica en
  horizontal. En vertical sigue encima, con el botón ≡.
- Orden de construcción: primero las estructuras (esqueleto), luego primitivas y
  componentes según los pida Equipos. Cada pieza se presenta con su nombre antes
  de crearla.

## Estructura

```text
lib/widgets2/
├── primitivas/    acciones, contenido, entradas, disposicion, superficies
├── componentes/   acciones, contenido, encabezados, colecciones, formularios, identidad, estados
├── estructuras/   subzonas, secciones, zonas, paginas, paneles, esquemas
├── ventanas/      dialogos, menus, selectores, notificaciones
└── soporte/       acceso al tema, animaciones, foco, arrastre
```

## `primitivas/`: la pieza más chica con comportamiento propio

| Subcarpeta | Qué va | Ejemplo en Equipos |
| --- | --- | --- |
| `acciones` | Elementos que se pulsan | botón, botón de icono (cerrar, editar) |
| `contenido` | Elementos que solo muestran algo | texto, icono, insignia de estado ("activo") |
| `entradas` | Elementos donde se escribe o elige | campo de texto, casilla, interruptor |
| `disposicion` | Acomodo y separación | separador, espacio entre piezas |
| `superficies` | Fondo, borde y forma que contienen algo | tarjeta, contenedor con borde |

## `componentes/`: primitivas combinadas en un patrón reutilizable

| Subcarpeta | Qué va | Ejemplo en Equipos |
| --- | --- | --- |
| `acciones` | Grupos de acciones | grupo de iconos del detalle (editar, dar de baja, ver en vivo) |
| `contenido` | Información armada | fila "etiqueta: valor" del detalle (Placa: ABC-123) |
| `encabezados` | Título con acciones, reutilizable | título con botones a la derecha |
| `colecciones` | Formas de mostrar muchos registros | tabla de equipos, tarjetas |
| `formularios` | Campos ya armados | campo con etiqueta y error, selector de empresa |
| `identidad` | Quién o qué es | logo de la app, avatar |
| `estados` | Mensajes dentro de la página | "cargando", "sin resultados", "error al cargar" |

## `estructuras/`: posiciones de la pantalla

No se reutilizan fuera de su lugar.

| Subcarpeta | Qué va | Ejemplo en Equipos |
| --- | --- | --- |
| `esquemas` | La pantalla completa | esquema central (navegación + principal + secundario) |
| `paneles` | Regiones grandes del esquema | panel de navegación (menú), principal, secundario |
| `paginas` | Página con sus zonas | página de listado, de detalle y de formulario |
| `zonas` | Encabezado, contenido y pie | pie del formulario (Cancelar \| Guardar) |
| `subzonas` | Posiciones fijas dentro de una zona | acciones superiores (búsqueda, filtros), visualización, acciones flotantes (Agregar), barra de estado ("12 de 40 equipos") |
| `secciones` | Grupos de contenido relacionado | sección principal del formulario, "Datos generales" del detalle |

## `ventanas/`: aparecen encima y son temporales

| Subcarpeta | Qué va | Ejemplo en Equipos |
| --- | --- | --- |
| `dialogos` | Piden atención o respuesta | "¿Dar de baja este equipo?", "¿Descartar cambios?" |
| `menus` | Opciones contextuales | menú de preferencias |
| `selectores` | Elegir valores | selección de fecha, selección de empresa o sede |
| `notificaciones` | Avisos que desaparecen solos | "Equipo guardado" |

## `soporte/`: conductas visuales sin contenido propio

| Qué va | Ejemplo |
| --- | --- |
| Acceso al tema | `acceso_tema.dart` (ya existe) |
| Animaciones, foco, arrastre | transición al abrir una hoja, mover el foco al primer campo |

## Regla que lo une todo

Ninguna pieza visual consulta datos, guarda ni decide. Solo muestra y avisa lo
que pasó, por ejemplo "se seleccionó esta fila". La pestaña Equipos decide qué
hacer con ese aviso.

Una pieza nunca usa otra de un nivel superior:

```text
tokens y tema → primitivas → componentes → subzonas y secciones → zonas → páginas → paneles → esquemas
```
