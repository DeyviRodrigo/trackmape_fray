# Composición de pantallas

Modelo teórico para planificar cómo se arma una pantalla: qué niveles existen,
qué contiene cada uno, cómo se adapta a horizontal y vertical, y quién decide
cada cosa. No describe código ni tecnología concreta.

> Origen: TrazMAPE 2.2, documentación de widgets y pestañas de la rama
> `desarrollador/formularios-sincronizar` (versión remota, octubre 2026).
> Reemplaza al modelo anterior basado en átomos, moléculas y organismos.

---

## 1. Idea central

Una pantalla se organiza **por posición y responsabilidad**, no por el tamaño
de sus piezas. Hay una sola jerarquía posicional:

```text
esquema → panel → página → zona → subzona
```

Fuera de esa cadena hay tres conceptos complementarios:

- **Sección**: agrupa contenido relacionado; no es un nivel de posición.
- **Ventana**: superficie temporal encima de la pantalla.
- **Piezas reutilizables** (primitivas y componentes): los ladrillos que se
  colocan dentro de las posiciones.

---

## 2. Vocabulario

| Concepto | Qué es | Ejemplo |
| --- | --- | --- |
| **Esquema** | La experiencia completa que ocupa la pantalla. | Esquema de autenticación, esquema central. |
| **Panel** | Región mayor de un esquema que presenta una página o una hoja. | Panel de navegación, principal, secundario. |
| **Página** | Contenido organizado en zonas que ocupa un panel o una hoja. | Listado, detalle, formulario. |
| **Zona** | Solo existen tres: **encabezado**, **contenido** y **pie**. | El pie de un formulario. |
| **Subzona** | Posición fija con nombre dentro de una zona. | Título, acciones del encabezado, barra de estado. |
| **Sección** | Agrupación semántica dentro del contenido. | Datos del padre, datos principales, tabla hija. |
| **Ventana** | Interacción temporal superpuesta. | Diálogo, menú, selector, notificación. |
| **Hoja** | Página contextual que se apila sobre otra. | El detalle abierto sobre el listado. |
| **Primitiva** | Menor unidad visual con comportamiento propio. | Botón, campo de texto, icono. |
| **Componente** | Combinación reutilizable de primitivas que resuelve un patrón. | Tabla, campo de contraseña, grupo de acciones. |
| **Soporte** | Capacidad visual transversal, sin contenido propio. | Animación, foco, arrastre. |

**Términos retirados:** *división* pasa a ser **panel**; *subdivisión* pasa a
ser **subzona**; *marco* pasa a ser **esquema**. *Superficie* solo nombra una
pieza contenedora (fondo, borde, forma), nunca un nivel de la arquitectura.

---

## 3. Esquemas

Un esquema decide qué experiencia completa se muestra. Hay dos.

### 3.1 Esquema de autenticación

- Se muestra mientras no hay sesión.
- La aplicación no se construye ni queda oculta detrás.
- No es un diálogo ni una ventana encima de la aplicación.
- Sus partes son **identidad**, **acceso** e **información**, más la
  recuperación de acceso.
- El formulario de acceso solo muestra valores, errores y acciones; no
  autentica.

### 3.2 Esquema central

Es la experiencia después de iniciar sesión. Tiene hasta **tres paneles**:

| Panel | Responsabilidad |
| --- | --- |
| **Navegación** | Orientación global: módulos, pestañas, sesión. |
| **Principal** | El contenido funcional activo (normalmente el listado). |
| **Secundario** | La hoja abierta (detalle o formulario). **Solo en horizontal.** |

Todos los paneles ordenan su contenido internamente en vertical. Esa dirección
interna no tiene relación con la distribución global (horizontal o vertical).

---

## 4. Distribución horizontal y vertical

Son **variantes explícitas** de la misma pantalla. No se deducen del nombre del
dispositivo.

### Horizontal (pantalla ancha)

```text
┌──────┬──────────────────────────┬────────────────────┐
│ Nav  │  PRINCIPAL               │  SECUNDARIO        │
│      │  página de listado       │  hoja activa       │
│      │                          │  (detalle/form.)   │
└──────┴──────────────────────────┴────────────────────┘
                                  ↑ línea divisoria
```

- Principal y secundario conviven, separados por una línea vertical.
- La navegación comprimida se muestra como una cinta con opciones y avatar.
- **No hay pie** en las páginas.
- No hay accesos directos.

### Vertical (pantalla angosta)

```text
┌────────────────────────────┐
│ ≡                          │ ← control de apertura, superpuesto
│  PRINCIPAL                 │
│  página de listado         │ ← ocupa todo el ancho
│  ┌──────────────────────┐  │
│  │ hoja activa encima   │  │ ← superpuesta, sin divisor
│  └──────────────────────┘  │
│ PIE: accesos directos      │
└────────────────────────────┘
```

- Solo existe el panel principal. **No hay panel secundario.**
- La hoja activa se superpone dentro del mismo panel principal; no se
  convierte en panel secundario ni en ventana.
- El listado no reserva una columna para la navegación: el control de
  apertura (tres líneas) se superpone en el borde inicial.
- Al abrir una hoja, esta se superpone también sobre ese control.
- El pie de las páginas de listado y detalle muestra los **accesos directos**.

### Panel de navegación

- **Comprimido:** en vertical solo queda el control de apertura; en horizontal
  queda la cinta de opciones y el avatar.
- **Ampliado:** muestra el logo y el nombre de la aplicación; las opciones
  agrupadas (por ejemplo Formularios, Informes, Herramientas); y un pie con
  identidad del usuario, preferencias (tres puntos) y cierre de sesión aparte.
- Se comprime al pulsar el logo o fuera del panel.
- Su ancho es el menor entre el espacio disponible y el ancho del menú
  ampliado: no ocupa toda una pantalla vertical si sobra espacio.
- Cada grupo puede ofrecer acciones para mostrar u ocultar sus opciones y
  crear carpetas.

---

## 5. Pila de hojas

El detalle y el formulario son **hojas** que se apilan sobre el listado.

```text
listado  →  abre detalle  →  abre formulario
            (hoja 1)         (hoja 2, arriba)
```

- **Abrir** apila una hoja nueva.
- **Cerrar** quita solo la hoja superior y vuelve a la anterior (o al listado)
  **conservando su estado**.
- No existe acción de "regresar": las hojas se cierran desde su encabezado.
- Si un formulario tiene cambios sin guardar, al salir se pregunta:
  **descartar** (sale) o **seguir editando** (se queda).
- Las ventanas no forman parte de la pila.

---

## 6. Zonas de una página

Toda página tiene como máximo tres zonas:

```text
┌─────────────────────────────────────────┐
│ ENCABEZADO   título   |   acciones      │
├─────────────────────────────────────────┤
│ CONTENIDO                               │
│                                         │
├─────────────────────────────────────────┤
│ PIE                                     │
└─────────────────────────────────────────┘
```

### Encabezado

- Contiene **únicamente** dos subzonas: **título** y **acciones del
  encabezado**.
- El icono de menú y los controles de navegación **no** van aquí.
- El cierre de detalle y formulario va en las acciones del encabezado.

### Contenido

- Es la zona principal; su organización depende del tipo de página.
- Información sobre el estado de lo mostrado (conteo, filtros, orden) va aquí,
  no en el pie.

### Pie

| Página | Pie en vertical | Pie en horizontal |
| --- | --- | --- |
| Listado | Accesos directos | No existe |
| Detalle | Accesos directos | No existe |
| Formulario | **Cancelar \| Guardar**, en dos mitades iguales | Acciones del formulario |

El formulario no tiene accesos directos. El pie nunca mezcla accesos directos
con información de estado.

---

## 7. Páginas de una pestaña de formularios

Una pestaña de formularios tiene tres páginas internas: **listado (data)**,
**detalle** y **formulario**. Las tres pertenecen a la misma unidad y se diseñan
juntas.

### 7.1 Listado (data)

El contenido tiene **exactamente cuatro subzonas, en este orden**:

| # | Subzona | Contiene |
| --- | --- | --- |
| 1 | **Acciones superiores** | Búsqueda y filtros. |
| 2 | **Visualización** | La colección: tabla, tarjetas, calendario, galería o mapa. |
| 3 | **Acciones flotantes** | Superpuestas a la visualización; por ejemplo **Agregar** (solo icono con ayuda). |
| 4 | **Barra de estado** | Registros mostrados, total, filtros activos y orden. |

- La barra de estado pertenece al contenido aunque se vea en el borde inferior;
  no es el pie.
- La visualización **no cambia sola** de tabla a tarjetas según el ancho: cada
  forma de mostrar es una variante con diseño propio.
- No hay botón **Editar** por fila: seleccionar una fila abre su detalle.
- **Agregar** solo aparece si el usuario tiene permiso de crear.

### 7.2 Detalle

- Se abre al seleccionar un registro.
- **Editar** y **Eliminar** son iconos con ayuda dentro del contenido, no
  botones anchos abajo.
- *Eliminar* es el nombre visible; la operación real inactiva el registro.
- Las **pestañas hijas** aparecen como secciones (ver 7.4).

### 7.3 Formulario

Se abre con Agregar o Editar. Su contenido es una subzona de **secciones**:

```text
formulario
├── sección padre       0 o más   resumen del registro padre; no se edita aquí
├── sección principal   exactamente 1   siempre visible, expandida, no colapsable
└── sección hija        0 o más   encabezado + "agregar" + tabla de la hija
```

- Todas son secciones hermanas; no existen "subsecciones".
- Si el padre es obligatorio, la sección principal queda **bloqueada** hasta
  resolverlo.
- El padre se crea o edita en el formulario de su propia pestaña, nunca aquí.
- Se pueden agregar hijos antes de guardar el principal: quedan como
  borradores locales con identificador temporal.
- Al guardar: primero el principal, luego cada hijo; los que fallan se
  conservan para reintentar.
- No se puede cerrar normalmente con pendientes; descartarlos pide
  confirmación.
- Padres resueltos e hijas solo se colapsan si está permitido; errores,
  pendientes o resultados inciertos los fuerzan visibles y expandidos.

### 7.4 Pestañas hijas dentro del padre

```text
Personal
  └── detalle y formulario de persona
        └── compone "Documentos de identidad"
```

- El detalle del padre tiene una subzona de **secciones**; cada relación hija
  ocupa una sección con su tabla.
- La hija **conserva su identidad**: sus datos, columnas, permisos, acciones y
  pruebas son suyos, aunque se vea dentro del padre.
- El padre decide **dónde** y **en qué orden** se muestra; la hija decide
  **qué** muestra y cómo se comporta.
- Seleccionar una fila de la hija abre el **detalle propio de la hija**, apilado
  como hoja.

### 7.5 Ventana previa al formulario

- Ventana temporal **fuera de la pila** para resolver el padre antes de abrir
  el formulario (por ejemplo, buscar si la persona ya existe).
- Estados: entrada, consultando, resultado, no encontrado, error.
- Se cierra **antes** de abrir el formulario.
- Nombre correcto: *ventana previa al formulario* (no "ventana padre").

---

## 8. Ventanas

Superficies temporales encima de la pantalla. Controlan su presentación, foco y
cierre; el significado lo aporta quien las usa.

| Tipo | Uso | Ejemplo |
| --- | --- | --- |
| **Diálogos** | Requieren atención o respuesta. | Confirmación de cambios pendientes. |
| **Menús** | Opciones o acciones contextuales. | Menú de opciones, menú de preferencias. |
| **Selectores** | Escoger uno o varios valores. | Selección de fecha, de opciones. |
| **Notificaciones** | Avisos transitorios. | Aviso temporal. |

Un mensaje **integrado** en la página es un componente de estado; un aviso
**superpuesto** es una ventana de notificación.

---

## 9. Clasificación de piezas

| Familia | Subtipos |
| --- | --- |
| **Primitivas** | acciones, contenido, entradas, disposición, superficies |
| **Componentes** | acciones, contenido, encabezados, colecciones, formularios, identidad, estados |
| **Estructuras** | subzonas, secciones, zonas, páginas, paneles, esquemas |
| **Ventanas** | diálogos, menús, selectores, notificaciones |
| **Soporte** | animaciones, imágenes, foco, arrastre, dimensiones heredadas |

Diferencia clave: un **componente de encabezado** (por ejemplo, título con
acciones) es reutilizable en cualquier lugar; una **zona de encabezado** define
una posición concreta dentro de una página.

### Dirección de dependencias

```text
tokens y tema
   ↓
primitivas
   ↓
componentes
   ↓
subzonas y secciones → zonas → páginas → paneles
   ↓
esquemas
```

Una pieza nunca usa otra que esté por encima de ella. Ventanas y soporte pueden
usarse desde cualquier nivel superior, pero nunca adquieren lógica de negocio.

### Cómo decidir en qué nivel va algo

| Pregunta | Va como |
| --- | --- |
| ¿Se reutiliza en distintos lugares sin conocer la pantalla? | Primitiva o componente |
| ¿Nombra una posición estable dentro de una zona? | Subzona |
| ¿Agrupa contenido funcional relacionado? | Sección |
| ¿Es encabezado, contenido o pie de una página? | Zona |
| ¿Ocupa un panel o una hoja con sus zonas? | Página |
| ¿Presenta una página en una región mayor? | Panel |
| ¿Define la experiencia completa? | Esquema |
| ¿Es temporal y aparece encima? | Ventana |
| ¿Es una conducta visual sin contenido propio? | Soporte |

Regla: elegir **el nivel más bajo** que mantenga la pieza coherente.

---

## 10. Reglas de adaptación

1. **El tipo de equipo decide qué existe; el ancho decide cómo se acomoda.**
   - Equipo (pc, tablet, celular): lo indica quien usa la pieza; decide qué
     regiones aparecen. Nunca se deduce del ancho.
   - Ancho real del contenedor: decide si las regiones van en fila o apiladas,
     según un umbral propio de cada pieza (no un punto de quiebre global).
2. Una región vacía o no admitida **desaparece sin dejar hueco**.
3. Una superficie de tamaño fijo (diálogo, panel lateral) puede declarar ancho,
   alto, relleno, separación y radio. Las regiones que deben ocupar el espacio
   sobrante crecen y se desplazan por dentro; encabezado y pie quedan fijos.

---

## 11. Quién decide qué

| Capa | Responsabilidad |
| --- | --- |
| **Aplicación** | Arranque, sesión, qué esquema se muestra, tema activo, rutas. |
| **Piezas visuales** (esquemas, paneles, páginas, zonas, componentes, primitivas, ventanas) | Acomodar y mostrar. Reciben contenido, valores y acciones. **No** consultan datos, **no** guardan, **no** deciden permisos ni navegación. |
| **Pestaña** (funcionalidad) | Decide qué contenido va en cada lugar, maneja la pila de hojas, conecta cada evento con su acción, controla estado y permisos. |
| **Datos** | Contratos y acceso a datos; no compone interfaz. |

- Las piezas visuales **emiten intenciones** (por ejemplo, "se seleccionó esta
  fila"); la pestaña decide qué hacer.
- Ocultar algo en la interfaz **nunca** sustituye un permiso real.

---

## 12. Tipos de pestaña

| Tipo | Contenido | Estado del modelo |
| --- | --- | --- |
| **Formularios** | Listado, detalle y formulario sobre una entidad principal. | Definido (este documento). |
| **Informes** | Consultas y vistas, sin edición. | Páginas y accesos directos **sin definir**. |
| **Herramientas** | Operaciones sobre varias entidades. | Páginas y accesos directos **sin definir**. |

Las reglas de formularios **no se extienden** automáticamente a informes ni
herramientas.

---

## 13. Pendientes del modelo

- Definir páginas, zonas y accesos directos para **informes** y
  **herramientas**.
- Decidir la configuración de los accesos directos.
- Algunos nombres de los prototipos antiguos (los que empiezan por "Zona…"
  para cosas que en realidad son subzonas) deben reconciliarse con este
  vocabulario.
