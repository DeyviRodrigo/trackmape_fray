Rutas operativas locales

Esta carpeta sirve para dibujar y mantener corredores sin depender de base de datos.

Archivos recomendados:
- rutas_principales.geojson: lineas de circulacion
- zonas_operativas.geojson: polygons para chute, carga, descarga, espera, taller

Uso sugerido:
- cada ruta se dibuja como LineString
- cada zona se dibuja como Polygon
- luego el sistema puede comparar una coordenada contra la ruta o zona mas cercana

Pasos para construirlas:
1. Abrir Google Earth Pro o QGIS.
2. Dibujar las rutas reales de operacion sobre la imagen satelital.
3. Exportar como KML o GeoJSON.
4. Guardar el resultado en esta carpeta.
5. Si sale en KML, convertirlo a GeoJSON para usarlo mas facil en Flutter.
