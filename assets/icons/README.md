## Iconos personalizados

Este proyecto puede usar iconos propios como si fueran `Icons.algo`.

### Flujo recomendado

1. Diseña tu icono en SVG.
2. Súbelo a IcoMoon o FlutterIcon.
3. Exporta la fuente `.ttf`.
4. Guarda el archivo como `assets/icons/track_icons.ttf`.
5. Descomenta la sección `fonts:` en `pubspec.yaml`.
6. Actualiza los codepoints en `lib/core/ui/track_custom_icons.dart`.
7. Ejecuta `flutter pub get`.

### Recomendaciones para que salga bien

- Usa un SVG simple, preferiblemente monocromático.
- Convierte trazos a rellenos antes de exportar si el editor lo permite.
- Mantén el lienzo cuadrado, por ejemplo `24x24` o `32x32`.
- Si el icono debe comportarse como un `Icon`, la opción más compatible es una fuente de iconos.

### Ejemplo de uso

```dart
const Icon(TrackCustomIcons.camionTolva, color: Colors.orange, size: 24)
```
