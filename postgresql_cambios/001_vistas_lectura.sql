-- =============================================================================
-- 001 - VISTAS DE LECTURA - TrackMAPE
-- =============================================================================
--
-- Regla: las tablas son para escribir (y para el tiempo real); toda la demas
-- lectura pasa por estas vistas.
--
-- Forma de cada vista (basica, sufijo _vt):
--   - Espejo de su tabla: todas sus columnas, sin calculos.
--   - Por cada relacion, una columna con el nombre legible (LEFT JOIN, para que
--     el registro aparezca aunque la relacion este vacia).
--   - Las de posiciones no agregan nombres: son tablas enormes y el JOIN por
--     fila haria lentas las consultas del historico.
--   - security_invoker: la vista respeta los permisos de la tabla de origen.
--
-- Permisos:
--   - Solo lectura. Supabase concede por defecto todos los permisos sobre los
--     objetos nuevos de public; se revocan y se concede unicamente SELECT. Sin
--     esto, una vista simple como posiciones_vt admitiria escrituras a traves
--     de ella.
--   - SELECT tambien para anon: TrackMAPE no tiene inicio de sesion.
--
-- Como aplicarlo: Supabase > SQL Editor > pegar todo > Run. Va en una sola
-- transaccion: si algo falla, no se crea ninguna vista.
-- No modifica tablas ni vistas existentes (v_empresas queda intacta).
-- =============================================================================

BEGIN;

-- EMPRESAS
CREATE VIEW public.empresas_vt WITH (security_invoker = true) AS
SELECT
    base.id_empresa, base.fk_pais, base.fk_tipo_doc, base.numero_documento,
    base.razon_social, base.nombre_comercial, base.estado, base.condicion,
    base.fk_ubigeo, base.direccion, base.columnas_extras, base.fk_responsable,
    base.celular, base.email, base.pagina_web, base.logo_url, base.activo
FROM public.empresas base;

COMMENT ON VIEW public.empresas_vt IS
    'Creada para TrackMAPE. Lectura basica de empresas.';

-- SEDES
CREATE VIEW public.sedes_vt WITH (security_invoker = true) AS
SELECT
    base.id_sede, base.fk_empresa, empresa.razon_social AS empresa,
    base.nombre, base.tipo_sede, base.fk_responsable, base.celular, base.email,
    base.pagina_web, base.logo_url, base.fk_ubigeo, base.direccion,
    base.columnas_extras, base.activo, base.zona_horaria
FROM public.sedes base
LEFT JOIN public.empresas empresa ON empresa.id_empresa = base.fk_empresa;

COMMENT ON VIEW public.sedes_vt IS
    'Creada para TrackMAPE. Lectura basica de sedes, con el nombre de su empresa.';

-- EQUIPOS DE CONTROL
CREATE VIEW public.equipos_control_vt WITH (security_invoker = true) AS
SELECT
    base.id_equipo_control, base.fk_empresa, empresa.razon_social AS empresa,
    base.fk_sede, sede.nombre AS sede, base.nombre, base.ubicacion,
    base.id_equipo_fabrica, base.tipo_equipo_control, base.codigo_equipo_control,
    base.direccion_mac, base.observaciones, base.fk_area_asociada,
    base.fk_equipo_asociado, base.fecha_inicio, base.fecha_final
FROM public.equipos_control base
LEFT JOIN public.empresas empresa ON empresa.id_empresa = base.fk_empresa
LEFT JOIN public.sedes sede ON sede.id_sede = base.fk_sede;

COMMENT ON VIEW public.equipos_control_vt IS
    'Creada para TrackMAPE. Lectura basica de equipos de control, con el nombre de su empresa y sede.';

-- ELEMENTOS OPERATIVOS (GIS)
CREATE VIEW public.pr_elementos_operativos_vt WITH (security_invoker = true) AS
SELECT
    base.id_elemento, base.fk_empresa, empresa.razon_social AS empresa,
    base.fk_sede, sede.nombre AS sede, base.categoria, base.tipo_operativo,
    base.nombre, base.descripcion, base.geojson, base.color, base.prioridad,
    base.activo, base.fecha_creacion, base.fecha_actualizacion
FROM public.pr_elementos_operativos base
LEFT JOIN public.empresas empresa ON empresa.id_empresa = base.fk_empresa
LEFT JOIN public.sedes sede ON sede.id_sede = base.fk_sede;

COMMENT ON VIEW public.pr_elementos_operativos_vt IS
    'Creada para TrackMAPE. Lectura basica de elementos operativos GIS, con el nombre de su empresa y sede.';

-- POSICIONES (historial)
CREATE VIEW public.posiciones_vt WITH (security_invoker = true) AS
SELECT
    base.id_posicion, base.tiempo, base.fk_receptor, base.fk_emisor,
    base.epoca_rx, base.lat_grados, base.lon_grados, base.alt_msnm_m,
    base.hae_m, base.geo_m, base.pdop, base.hdop, base.vdop, base.largo_payload
FROM public.posiciones base;

COMMENT ON VIEW public.posiciones_vt IS
    'Creada para TrackMAPE. Lectura basica del historial de posiciones GPS.';

-- POSICIONES TEMPORALES (recientes)
CREATE VIEW public.posiciones_temp_vt WITH (security_invoker = true) AS
SELECT
    base.id_posicion, base.tiempo, base.fk_receptor, base.fk_emisor,
    base.epoca_rx, base.lat_grados, base.lon_grados, base.alt_msnm_m,
    base.hae_m, base.geo_m, base.pdop, base.hdop, base.vdop, base.largo_payload
FROM public.posiciones_temp base;

COMMENT ON VIEW public.posiciones_temp_vt IS
    'Creada para TrackMAPE. Lectura basica de posiciones GPS recientes.';

-- PERMISOS: solo lectura
REVOKE ALL ON
    public.empresas_vt, public.sedes_vt, public.equipos_control_vt,
    public.pr_elementos_operativos_vt, public.posiciones_vt, public.posiciones_temp_vt
FROM anon, authenticated, service_role;

GRANT SELECT ON
    public.empresas_vt, public.sedes_vt, public.equipos_control_vt,
    public.pr_elementos_operativos_vt, public.posiciones_vt, public.posiciones_temp_vt
TO anon, authenticated, service_role;

COMMIT;
