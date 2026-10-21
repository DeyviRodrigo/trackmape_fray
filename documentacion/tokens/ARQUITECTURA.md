# Ubicación de los tokens en la arquitectura

Dónde vive cada parte del sistema de tokens dentro del proyecto y por qué.
Complementa al [README](README.md), que explica qué contiene cada archivo y
cómo usarlo.

> **Adaptación en TrackMAPE (2026-10-21).** Se aplicó este documento con tres
> diferencias acordadas:
>
> 1. Las capas van en paralelo a las actuales: `lib/recursos2/` y
>    `lib/widgets2/` en lugar de `lib/recursos/` y `lib/widgets/`.
> 2. **Sin archivo de entrada** (`recursos.dart`): imports directos desde el
>    inicio, como en el resto del proyecto. No se usa la excepción de abajo.
> 3. `variante_boton` y `estado_campo` van en **archivos propios** (una
>    responsabilidad por archivo), junto a su widget cuando existe:
>    `variante_boton` ya está en `lib/widgets2/primitivas/acciones/`, al lado
>    del botón. `estado_campo` sigue en `recursos2/temas/` porque los campos
>    actuales usan `InputDecoration` del tema y no lo necesitan.
>
> El tema oscuro nuevo está activo en las rutas de la arquitectura nueva (menú
> y pestañas). Las pantallas anteriores mantienen su tema hasta migrarse.

## Decisión

Los tokens **no viven en `app`**. Se reparten así:

```text
lib/
├── recursos/
│   ├── tokens/    valores fijos                       ┐ sin estado,
│   └── temas/     significados y ThemeData            ┘ sin BuildContext
├── app/           qué tema está activo
└── widgets/       acceso con context.colores y lo exclusivo de cada widget
```

Dirección de dependencias:

```text
recursos/tokens  ←  recursos/temas  ←  app
                                    ←  widgets
```

- `temas` usa `tokens`; `tokens` nunca usa `temas`.
- `app` y `widgets` usan `recursos`; `recursos` nunca usa `app` ni `widgets`.
- `recursos` no construye widgets ni lee `BuildContext`.

## Por qué no dejarlos en `app`

En una versión anterior todo estaba en `app/tokens`: valores, temas,
proveedores del tema activo y constantes de un editor. Eso produjo tres
problemas:

1. **Valores mezclados con estado.** Los colores quedaron junto a los
   proveedores que deciden el tema activo. Cualquier widget que solo necesitaba
   un color terminaba dependiendo de toda la capa `app`.
2. **Duplicados al cambiar.** Al rediseñar los colores convivieron el sistema
   viejo y el nuevo (`colores_intf` / `colores_interfaz`, `temas_prov` /
   `temas_proveedor`), con puentes "temporales" que tardan en quitarse.
3. **Sin dueño claro.** Una carpeta que lo contiene todo acumula piezas que nadie
   sabe si se pueden borrar.

Separar desde el inicio cuesta poco porque todavía no hay widgets que dependan
de los tokens. Hacerlo después obliga a migrar todos los imports.

## Qué va en cada capa

| Responsabilidad | Capa | Motivo |
| --- | --- | --- |
| Valores fijos: paleta, espaciado, radios, bordes, opacidad, elevación, movimiento, tamaños, tipografía | `recursos/tokens` | Son datos constantes, iguales en cualquier tema. |
| Roles de color, temas claro y oscuro, construcción del `ThemeData` | `recursos/temas` | Asignan significado a los valores; tampoco tienen estado. |
| Elegir el tema activo y recordarlo | `app` | Cambia mientras la aplicación corre: es estado. |
| Acceso corto `context.colores` / `context.textos` | `widgets` | Usa `BuildContext`, que `recursos` no puede usar; sus consumidores son los widgets. |
| Variantes o estados que usa **un solo** widget | El archivo de ese widget | Quedan junto a su único dueño y se borran con él. |
| Variantes o estados que usan **muchos** widgets | `recursos/temas` | Solo traducen roles a colores; no construyen interfaz. |

## Correspondencia con los archivos de esta carpeta

| Archivo de `tokens/` | Destino en el proyecto |
| --- | --- |
| `base/paleta.dart` | `lib/recursos/tokens/paleta.dart` |
| `base/espaciado.dart` | `lib/recursos/tokens/espaciado.dart` |
| `base/radios.dart` | `lib/recursos/tokens/radios.dart` |
| `base/bordes.dart` | `lib/recursos/tokens/bordes.dart` |
| `base/opacidad.dart` | `lib/recursos/tokens/opacidad.dart` |
| `base/elevacion.dart` | `lib/recursos/tokens/elevacion.dart` |
| `base/movimiento.dart` | `lib/recursos/tokens/movimiento.dart` |
| `base/tamanos.dart` | `lib/recursos/tokens/tamanos.dart` |
| `base/tipografia.dart` | `lib/recursos/tokens/tipografia.dart` |
| `semanticos/colores_app.dart` | `lib/recursos/temas/colores_app.dart` |
| `semanticos/textos_app.dart` | `lib/recursos/temas/textos_app.dart` |
| `temas/colores_claros.dart` | `lib/recursos/temas/colores_claros.dart` |
| `temas/colores_oscuros.dart` | `lib/recursos/temas/colores_oscuros.dart` |
| `temas/tema_app.dart` | `lib/recursos/temas/tema_app.dart` |
| `contextos/tono_estado.dart` | `lib/recursos/temas/tono_estado.dart` (lo usan mensajes, badges, alertas) |
| `contextos/tono_texto.dart` | `lib/recursos/temas/tono_texto.dart` (lo usan muchos widgets) |
| `contextos/variante_boton.dart` | Dentro del archivo del widget botón |
| `contextos/estado_campo.dart` | Dentro del archivo del widget campo, o de un componente de campos compartido |
| `acceso.dart` | `lib/widgets/soporte/acceso_tema.dart` |
| `tokens.dart` | Ver la excepción de abajo |

Al moverlos, los imports relativos entre archivos deben corregirse a las
nuevas rutas.

El tema activo se elige en `app`. Para empezar basta con el `MaterialApp`:

```dart
MaterialApp(
  theme: TemaApp.claro,
  darkTheme: TemaApp.oscuro,
  themeMode: ThemeMode.system,
)
```

Si luego se quiere cambiar el tema desde la aplicación, `app` guarda un
`ValueNotifier<ThemeMode>` y lo pasa a `themeMode`. Ni `recursos` ni `widgets`
necesitan cambiar.

## Excepción para ir rápido

Una arquitectura estricta prohíbe los archivos que reexportan todo (`export`),
para que cada archivo muestre de dónde viene lo que usa. Para un prototipo se
admite **una sola** excepción: un archivo de entrada para `recursos` (por
ejemplo `lib/recursos/recursos.dart`) que exporte `tokens` y `temas`.

- Ahorra imports mientras se crean los primeros widgets.
- No debe exportar `app` ni `widgets`.
- Cuando el proyecto se estabilice, se reemplaza por imports directos.

## Lo que no hace falta en un prototipo

- Listas cerradas de archivos permitidos por capa.
- Aprobación previa para agregar un archivo de tokens.
- Pruebas automáticas de arquitectura.

Son controles útiles en un equipo grande o con generadores de código. Las reglas
de esta página sí se mantienen: son las que evitan los problemas descritos
arriba.

## Resumen para quien crea widgets

1. Importar `recursos` (o el archivo de entrada) y el acceso de `widgets`.
2. Colores: siempre `context.colores.<rol>`, nunca `Paleta` ni un `Color(...)`
   escrito a mano.
3. Textos: `context.textos.<estilo>`.
4. Medidas: directamente `Espaciado.base`, `RadiosBorde.medio`,
   `TamanosIcono.base`, etc.
5. Si el widget necesita variantes propias (por ejemplo, tipos de botón),
   declararlas en su mismo archivo. Solo cuando varios widgets las usan pasan a
   `recursos/temas`.
