# Ejecutar la app

La app arranca en la arquitectura nueva: menú (panel de navegación) con el tema
oscuro nuevo, abriendo **Equipos**. Los módulos aún no migrados muestran las
pantallas anteriores dentro del menú nuevo.

```bash
flutter run -d windows
```

## Menú

Declarado en `lib/app2/navegacion/modulos_menu.dart`; rutas en
`lib/app2/rutas/enrutador_app.dart`. Solo Equipos está decidido; el resto sigue
la propuesta de referencia de `planificacion_pestanas.md` (sección 4).

| Grupo | Módulo | Ruta | Muestra |
| --- | --- | --- | --- |
| Formularios | Equipos | `/equipos` | **Pestaña nueva** |
| Formularios | Elementos Operativos | `/elementos-operativos` | Configuración Operativa (anterior) |
| Herramientas | Monitoreo en Vivo | `/monitoreo-en-vivo` | Tracking en vivo (anterior) |
| Informes | Recorridos | `/recorridos` | Consulta histórica + Transcurso simulado (anteriores, en pestañas) |
| Informes | Ranking Operativo | `/ranking-operativo` | Ranking (anterior) |
| Informes | Análisis de Equipo | `/analisis-equipo` | Rendimiento, Validación, Rutas, Diagnóstico (anteriores, en pestañas) |
| Pie | Versión anterior | `/version-anterior` | La app de antes completa, con su menú |

- Las pantallas anteriores usan la **primera empresa habilitada** (Francisco 1)
  hasta que se decida el filtro de empresa. Para ver otra empresa: Versión
  anterior, que conserva su selector.
- El menú se amplía tocando el logo y se comprime tocando el logo o fuera de él.
  En pantalla angosta (menos de 720) se abre con el botón ≡.

## Abrir directo en una ruta

```bash
flutter run -d windows --dart-define=RUTA_INICIAL=recorridos
```

- `RUTA_INICIAL` se escribe **sin** la barra inicial. Git Bash convierte
  `/recorridos` en una ruta de Windows (`C:/Program Files/Git/recorridos`) y la
  app muestra "Page Not Found".
- Sin `--dart-define`, abre en Equipos.

## Qué revisar en Equipos

| Acción | Qué debe pasar |
| --- | --- |
| Abrir | Listado de equipos de las empresas habilitadas |
| Buscar, filtrar por Tipo o Estado | La tabla se reduce y la barra de estado lo dice |
| Tocar un equipo | Su detalle se abre a la derecha |
| Editar (lápiz) | Se abre el formulario con sus datos |
| Cerrar el formulario con cambios | Pregunta si se descartan |
| Guardar | Aviso "Equipo guardado"; listado y detalle se actualizan |
| Agregar (+) | Formulario vacío |
| Dar de baja | Pide confirmar; el equipo pasa a "Finalizado" (fecha final = hoy) |
| Ver en vivo | Abre el monitoreo anterior filtrado a ese equipo |
| Ventana de menos de 720 de ancho | Las hojas aparecen encima del listado |

**Cuidado:** Guardar y Dar de baja escriben en la base de datos real.

## Ver cambios sin cerrar la app

En la terminal donde corre `flutter run`:

| Tecla | Qué hace |
| --- | --- |
| `r` | Recarga rápida: aplica cambios y conserva el estado |
| `R` | Reinicio completo: vuelve a empezar desde la ruta inicial |
| `q` | Cierra la app |
