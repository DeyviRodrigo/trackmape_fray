# Tokens de diseño

Sistema de tokens listo para crear widgets en Flutter (Material 3). Sin
dependencias externas: solo Flutter.

## Instalación

1. Repartir los archivos de `tokens/` en las capas del proyecto según
   [ARQUITECTURA.md](ARQUITECTURA.md). Para una prueba rápida también funciona
   copiar `tokens/` tal cual dentro de `lib/`.
2. Usar el tema en la app:

```dart
import 'package:flutter/material.dart';
import 'tokens/tokens.dart';

void main() => runApp(
  MaterialApp(
    theme: TemaApp.claro,
    darkTheme: TemaApp.oscuro,
    themeMode: ThemeMode.system,
    home: const Inicio(),
  ),
);
```

Con esto, los widgets de Material (botones, campos, cards, diálogos, tooltips,
snackbars, chips) ya salen con los tokens, sin configurar nada más.

## Las tres capas

```text
BASE            valores crudos, sin significado
  Paleta.azul600, Espaciado.base, Radios.pequeno, Duraciones.media…
    ↓  los temas asignan
SEMÁNTICOS      roles con significado, cambian según el tema
  context.colores.primario, context.colores.textoSecundario, context.textos.titulo…
    ↓  los contextos combinan
CONTEXTOS       variantes y estados por tipo de pieza
  VarianteBoton.peligro, TonoEstado.exito, EstadoCampo.foco, TonoTexto.terciario
```

**Regla principal:** un widget nunca usa `Paleta` ni escribe un color a mano.
Usa `context.colores` o un contexto. Así funciona igual en claro y oscuro, y
cambiar de marca es cambiar un archivo de tema.

Las medidas (espaciado, radios, tamaños, grosores, duraciones) no cambian con
el tema, así que se usan directamente: `Espaciado.base`, `RadiosBorde.medio`.

## Contenido

| Archivo | Qué define |
| --- | --- |
| `base/paleta.dart` | Colores crudos: pizarra (neutros), azul, celeste, violeta, verde, ámbar, rojo. |
| `base/espaciado.dart` | Escala de 2 a 64 sobre grilla de 4: `micro`, `minimo`, `pequeno`, `medio`, `base`, `comodo`, `amplio`, `holgado`, `extraHolgado`, `espacioso`, `maximo`. |
| `base/radios.dart` | Esquinas como número (`Radios`) y como `BorderRadius` (`RadiosBorde`). |
| `base/bordes.dart` | Grosores de borde, divisor y foco. |
| `base/opacidad.dart` | Capas de hover, foco, presionado, seleccionado, deshabilitado y velo. |
| `base/elevacion.dart` | Niveles de elevación y `Sombras.de(nivel, color)`. |
| `base/movimiento.dart` | `Duraciones` y `Curvas` de animación. |
| `base/tamanos.dart` | Iconos, alturas de control, avatares y anchos de superficie (navegación 76/296, diálogo 560). |
| `base/tipografia.dart` | Fuentes, pesos y escala: display, tituloGrande, titulo, subtitulo, cuerpoGrande, cuerpo, nota, etiqueta, etiquetaPequena, micro, codigo. |
| `semanticos/colores_app.dart` | Contrato de roles de color (`ColoresApp`) y los cuatro colores de cada estado (`ColoresEstado`). |
| `semanticos/textos_app.dart` | Nombres en español para el `TextTheme`: `context.textos.titulo`. |
| `temas/colores_claros.dart` | Asignación de la paleta a los roles en modo claro. |
| `temas/colores_oscuros.dart` | Asignación de la paleta a los roles en modo oscuro. |
| `temas/tema_app.dart` | `TemaApp.claro`, `TemaApp.oscuro` y `TemaApp.construir(colores)`: el `ThemeData` completo. |
| `contextos/variante_boton.dart` | Fondo, contenido y borde de primario, secundario, contorno, texto y peligro. |
| `contextos/tono_estado.dart` | Colores e icono de neutro, información, éxito, advertencia y error. |
| `contextos/tono_texto.dart` | Jerarquía de color de texto. |
| `contextos/estado_campo.dart` | Borde, grosor, fondo y texto de un campo según su estado. |
| `acceso.dart` | `context.colores` y `context.textos`. |
| `tokens.dart` | Punto de entrada: importar solo este archivo. |

## Roles de color

| Grupo | Roles |
| --- | --- |
| Marca | `primario`, `sobrePrimario`, `primarioContenedor`, `sobrePrimarioContenedor`, `secundario`, `sobreSecundario`, `acento`, `sobreAcento` |
| Textos | `textoPrimario`, `textoSecundario`, `textoTerciario`, `textoDeshabilitado`, `textoInverso`, `enlace` |
| Fondos | `fondoLienzo` (página), `superficie` (cards, paneles), `superficieBaja` (zonas hundidas), `superficieElevada` (diálogos, menús), `superficieInversa` (tooltips), `velo`, `sombra` |
| Bordes | `borde`, `bordeSutil` (divisores), `bordeFuerte`, `foco` |
| Interacciones | `hover`, `presionado`, `seleccionado`, `fondoDeshabilitado` |
| Estados | `neutro`, `informacion`, `exito`, `advertencia`, `error`; cada uno con `base`, `sobreBase`, `contenedor`, `sobreContenedor` |

La convención `sobreX` es el color de texto o icono que va encima de `X`.

## Ejemplo: un widget con tokens

```dart
class MensajeEstado extends StatelessWidget {
  const MensajeEstado({super.key, required this.texto, this.tono = TonoEstado.informacion});

  final String texto;
  final TonoEstado tono;

  @override
  Widget build(BuildContext context) {
    final colores = tono.colores(context.colores);
    return Container(
      padding: const EdgeInsets.all(Espaciado.medio),
      decoration: BoxDecoration(
        color: colores.contenedor,
        borderRadius: RadiosBorde.pequeno,
      ),
      child: Row(
        children: [
          Icon(tono.icono, size: TamanosIcono.medio, color: colores.sobreContenedor),
          const SizedBox(width: Espaciado.pequeno),
          Expanded(
            child: Text(
              texto,
              style: context.textos.cuerpo.copyWith(color: colores.sobreContenedor),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Cómo extender

- **Otro tema (por ejemplo, otra marca):** crear `temas/colores_<nombre>.dart`
  con un `ColoresApp` y usar `TemaApp.construir(coloresNombre)`.
- **Ajustar un color puntual:** `coloresClaros.copyWith(primario: Paleta.violeta600)`.
- **Un rol nuevo:** agregarlo a `ColoresApp` (campo, constructor, `copyWith` y
  `lerp`) y asignarlo en **todos** los temas. El compilador avisa si falta.
- **Una fuente propia:** declararla en `pubspec.yaml` y poner su nombre en
  `Fuentes.base`.
- **Un contexto nuevo** (por ejemplo, para opciones de navegación): copiar el
  patrón de `contextos/`: un `enum` y una extensión que resuelve colores desde
  `ColoresApp`.

## Decisiones

- **Sin gestor de estado.** El tema activo lo decide el `MaterialApp`
  (`themeMode`). Si luego se quiere elegir tema desde la app, basta un
  `ValueNotifier<ThemeMode>` en la raíz.
- **Sin breakpoints globales.** `TamanosSuperficie.umbralHorizontal` (720) es
  solo un valor de partida; cada pieza decide su propio umbral con el ancho
  real de su contenedor.
- **Transición animada.** `ColoresApp` interpola entre temas, así que cambiar
  de claro a oscuro se anima sin saltos.

## Origen

Combina dos versiones de TrazMAPE 2.2:

- de `moises/refactorizacion` y sus sucesoras: el vocabulario semántico (tres
  niveles de texto, interacciones, foco, fondo lienzo), la escala de espaciado
  con nombres y los contextos por pieza;
- del modelo generado en `arthas`: la separación entre paleta base y temas, la
  paleta nombrada por familia y escala, las categorías de opacidad, elevación y
  movimiento, y la publicación como `ThemeExtension`.

Se eliminaron los duplicados de transición (`colores_intf`, `iconos_app`,
`temas_prov`), los proveedores y las constantes de editor.
