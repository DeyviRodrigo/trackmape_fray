CREATE VIEW public.v_documentos_identidad_temporal AS
SELECT
    NULL::uuid AS id_doc,
    NULL::character varying(20) AS codigo,
    NULL::text AS nombre_documento,
    NULL::uuid AS fk_pais_aplicacion,
    NULL::boolean AS activo,
    NULL::text AS categoria_doc_id,
    NULL::smallint AS orden_doc_id,
    NULL::jsonb AS formatos;
CREATE VIEW public.v_empresas AS
 WITH RECURSIVE ancestros AS (
         SELECT u.id_ubigeo,
            u.fk_padre,
            u.fk_nivel,
            u.nombre,
            u.id_ubigeo AS origen
           FROM public.ubigeo u
        UNION ALL
         SELECT p1.id_ubigeo,
            p1.fk_padre,
            p1.fk_nivel,
            p1.nombre,
            a.origen
           FROM (ancestros a
             JOIN public.ubigeo p1 ON ((p1.id_ubigeo = a.fk_padre)))
        ), ubigeo_armado AS (
         SELECT a.origen AS id_ubigeo,
            json_agg(json_build_object(COALESCE(n.nombre_nivel, ('Nivel '::text || (n.nivel)::text)), a.nombre) ORDER BY n.nivel) AS ubigeo
           FROM (ancestros a
             JOIN public.niveles_ubigeo n ON ((n.id_nivel_ubigeo = a.fk_nivel)))
          GROUP BY a.origen
        ), sedes_agg AS (
         SELECT s.fk_empresa,
            count(*) AS total_sedes,
            count(*) FILTER (WHERE COALESCE(s.activo, true)) AS total_sedes_activas
           FROM public.sedes s
          GROUP BY s.fk_empresa
        ), trabajadores_agg AS (
         SELECT t.fk_empresa,
            count(*) AS total_trabajadores,
            count(*) FILTER (WHERE COALESCE(t.activo, true)) AS total_trabajadores_activos
           FROM public.trabajadores t
          GROUP BY t.fk_empresa
        ), verificacion_ult AS (
         SELECT DISTINCT ON (v.fk_empresa) v.fk_empresa,
            v.verificado,
            v.fuente_verificacion,
            v.fecha_verificacion
           FROM public.verificacion_empresas v
          ORDER BY v.fk_empresa, v.fecha_verificacion DESC NULLS LAST, v.id_verificacion_empresa DESC
        )
 SELECT e.id_empresa,
    p.nombre_pais AS pais,
    def.codigo AS tipo_documento,
    e.numero_documento,
    e.razon_social,
    e.nombre_comercial,
    e.estado,
    e.condicion,
    ua.ubigeo,
    e.direccion,
    e.celular,
    e.email,
    e.pagina_web,
    e.logo_url,
    COALESCE(sa.total_sedes, (0)::bigint) AS total_sedes,
    COALESCE(sa.total_sedes_activas, (0)::bigint) AS total_sedes_activas,
    COALESCE(ta.total_trabajadores, (0)::bigint) AS total_trabajadores,
    COALESCE(ta.total_trabajadores_activos, (0)::bigint) AS total_trabajadores_activos,
    vu.verificado AS empresa_verificada,
    vu.fuente_verificacion,
    vu.fecha_verificacion,
    e.activo AS empresa_activa,
    e.columnas_extras
   FROM ((((((public.empresas e
     LEFT JOIN public.paises p ON ((p.id_pais = e.fk_pais)))
     LEFT JOIN public.documento_empresa_formato def ON ((def.id_doc_empresa = e.fk_tipo_doc)))
     LEFT JOIN ubigeo_armado ua ON ((ua.id_ubigeo = e.fk_ubigeo)))
     LEFT JOIN sedes_agg sa ON ((sa.fk_empresa = e.id_empresa)))
     LEFT JOIN trabajadores_agg ta ON ((ta.fk_empresa = e.id_empresa)))
     LEFT JOIN verificacion_ult vu ON ((vu.fk_empresa = e.id_empresa)))
  ORDER BY p.nombre_pais, e.razon_social;
CREATE VIEW public.v_persona_documentos_temporal AS
 SELECT pd.id_persona_doc,
    pd.fk_persona,
    pd.fk_pais_emisor,
    pd.fk_tipo_doc,
    pd.num_documento,
    pd.cod_verificacion,
    pd.activo,
    di.codigo AS doc_codigo,
    di.nombre_documento AS doc_nombre,
    COALESCE(( SELECT true
           FROM public.verificacion_docs_id v
          WHERE ((v.fk_persona_doc = pd.id_persona_doc) AND (v.verificado = true))
         LIMIT 1), false) AS verificado,
    ( SELECT max(v.fecha_verificacion) AS max
           FROM public.verificacion_docs_id v
          WHERE ((v.fk_persona_doc = pd.id_persona_doc) AND (v.verificado = true))) AS fecha_verificacion_reciente
   FROM (public.persona_documentos pd
     LEFT JOIN public.documentos_identidad di ON ((di.id_doc = pd.fk_tipo_doc)));
CREATE VIEW public.v_personal_asistencia AS
 SELECT e.razon_social AS empresa,
    s.nombre AS sede,
    a.fecha_hora,
    a.orden,
    a.metodo,
    t.id_trabajador,
    p.apellido_paterno,
    p.apellido_materno,
    p.nombres,
    COALESCE(docs.documentos_identidad, '[]'::jsonb) AS documentos_identidad,
    c.cargo,
    p.id_persona,
    e.id_empresa,
    s.id_sede,
    a.id_asistencia,
    a.fk_credencial,
    a.fk_equipo_control
   FROM ((((((public.asistencia a
     JOIN public.trabajadores t ON ((t.id_trabajador = a.fk_trabajador)))
     JOIN public.personas p ON ((p.id_persona = t.fk_persona)))
     JOIN public.sedes s ON ((s.id_sede = t.fk_sede)))
     JOIN public.empresas e ON ((e.id_empresa = t.fk_empresa)))
     LEFT JOIN LATERAL ( SELECT c1.cargo
           FROM public.contrato c1
          WHERE (c1.fk_trabajador = t.id_trabajador)
          ORDER BY c1.fecha_inicio DESC NULLS LAST, c1.id_contrato DESC
         LIMIT 1) c ON (true))
     LEFT JOIN LATERAL ( SELECT jsonb_agg(jsonb_build_object('tipo', di.codigo, 'numero', pd.num_documento, 'pais', pa.nombre_pais) ORDER BY di.codigo) AS documentos_identidad
           FROM ((public.persona_documentos pd
             JOIN public.documentos_identidad di ON ((di.id_doc = pd.fk_tipo_doc)))
             JOIN public.paises pa ON ((pa.id_pais = pd.fk_pais_emisor)))
          WHERE ((pd.fk_persona = p.id_persona) AND (pd.activo = true))) docs ON (true));
CREATE VIEW public.v_personal_asistencia_temporal AS
 SELECT e.razon_social AS empresa,
    s.nombre AS sede,
    ec.fk_area_asociada AS area,
    a.fecha_hora,
    a.orden,
    a.metodo,
    t.id_trabajador,
    p.apellido_paterno,
    p.apellido_materno,
    p.nombres,
    COALESCE(docs.documentos_identidad, '[]'::jsonb) AS documentos_identidad,
    c.cargo,
    p.id_persona,
    e.id_empresa,
    s.id_sede,
    a.id_asistencia,
    a.fk_credencial,
    a.fk_equipo_control
   FROM (((((((public.asistencia a
     JOIN public.trabajadores t ON ((t.id_trabajador = a.fk_trabajador)))
     JOIN public.personas p ON ((p.id_persona = t.fk_persona)))
     JOIN public.sedes s ON ((s.id_sede = t.fk_sede)))
     JOIN public.empresas e ON ((e.id_empresa = t.fk_empresa)))
     LEFT JOIN public.equipos_control ec ON ((ec.id_equipo_control = a.fk_equipo_control)))
     LEFT JOIN LATERAL ( SELECT c1.cargo
           FROM public.contrato c1
          WHERE (c1.fk_trabajador = t.id_trabajador)
          ORDER BY c1.fecha_inicio DESC NULLS LAST, c1.id_contrato DESC
         LIMIT 1) c ON (true))
     LEFT JOIN LATERAL ( SELECT jsonb_agg(jsonb_build_object('tipo', di.codigo, 'numero', pd.num_documento, 'pais', pa.nombre_pais) ORDER BY di.codigo) AS documentos_identidad
           FROM ((public.persona_documentos pd
             JOIN public.documentos_identidad di ON ((di.id_doc = pd.fk_tipo_doc)))
             JOIN public.paises pa ON ((pa.id_pais = pd.fk_pais_emisor)))
          WHERE ((pd.fk_persona = p.id_persona) AND (pd.activo = true))) docs ON (true))
  WHERE (a.activo = true);
CREATE VIEW public.v_personal_contratos AS
 SELECT e.razon_social AS empresa,
    s.nombre AS sede,
    p.apellido_paterno,
    p.apellido_materno,
    p.nombres,
    c.id_contrato,
    c.cargo,
    c.tipo_contrato,
    c.fecha_inicio,
    c.fecha_fin,
    c.remuneracion,
    c.frecuencia_pago,
    m.nombre_moneda AS moneda,
    m.simbolo AS moneda_simbolo,
    c.documento_url,
    c.turno,
    c.modalidad,
    c.sistema,
    c.observacion AS observacion_contrato,
    t.id_trabajador,
    p.id_persona,
    e.id_empresa,
    s.id_sede
   FROM (((((public.contrato c
     JOIN public.trabajadores t ON ((t.id_trabajador = c.fk_trabajador)))
     JOIN public.personas p ON ((p.id_persona = t.fk_persona)))
     JOIN public.sedes s ON ((s.id_sede = t.fk_sede)))
     JOIN public.empresas e ON ((e.id_empresa = t.fk_empresa)))
     LEFT JOIN public.monedas m ON ((m.id_moneda = c.fk_moneda)));
CREATE VIEW public.v_personal_contratos_activos AS
 SELECT e.razon_social AS empresa,
    s.nombre AS sede,
    t.id_trabajador,
    p.apellido_paterno,
    p.apellido_materno,
    p.nombres,
    c.cargo,
    c.tipo_contrato,
    c.fecha_inicio,
    c.fecha_fin,
    c.remuneracion,
    c.frecuencia_pago,
    m.nombre_moneda AS moneda,
    m.simbolo AS moneda_simbolo,
    c.documento_url,
    c.turno,
    c.modalidad,
    c.sistema,
    c.observacion AS observacion_contrato,
    p.id_persona,
    e.id_empresa,
    s.id_sede
   FROM (((((public.contrato c
     JOIN public.trabajadores t ON ((t.id_trabajador = c.fk_trabajador)))
     JOIN public.personas p ON ((p.id_persona = t.fk_persona)))
     JOIN public.sedes s ON ((s.id_sede = t.fk_sede)))
     JOIN public.empresas e ON ((e.id_empresa = t.fk_empresa)))
     LEFT JOIN public.monedas m ON ((m.id_moneda = c.fk_moneda)))
  WHERE ((c.fecha_fin IS NULL) OR (c.fecha_fin >= CURRENT_DATE));
CREATE VIEW public.v_personal_credenciales AS
 SELECT p.apellido_paterno,
    p.apellido_materno,
    p.nombres,
    COALESCE(docs.documentos_identidad, '[]'::jsonb) AS documentos_identidad,
    e.razon_social AS empresa,
    s.nombre AS sede,
    ca.id_credencial,
    ca.tecnologia,
    ca.valor,
    ca.clave,
    ca.activo AS credencial_activa,
    t.id_trabajador,
    p.id_persona,
    e.id_empresa,
    s.id_sede,
    t.fotografia_url
   FROM (((((public.credenciales_acceso ca
     JOIN public.trabajadores t ON ((t.id_trabajador = ca.fk_trabajador)))
     JOIN public.personas p ON ((p.id_persona = t.fk_persona)))
     JOIN public.sedes s ON ((s.id_sede = t.fk_sede)))
     JOIN public.empresas e ON ((e.id_empresa = t.fk_empresa)))
     LEFT JOIN LATERAL ( SELECT jsonb_agg(jsonb_build_object('tipo', di.codigo, 'numero', pd.num_documento, 'pais', pa.nombre_pais) ORDER BY di.codigo) AS documentos_identidad
           FROM ((public.persona_documentos pd
             JOIN public.documentos_identidad di ON ((di.id_doc = pd.fk_tipo_doc)))
             JOIN public.paises pa ON ((pa.id_pais = pd.fk_pais_emisor)))
          WHERE ((pd.fk_persona = p.id_persona) AND (pd.activo = true))) docs ON (true));
CREATE VIEW public.v_personal_temporal AS
 SELECT p.id_persona,
    p.fk_pais,
    p.nombres,
    p.apellido_paterno,
    p.apellido_materno,
    p.fecha_nacimiento,
    p.genero,
    p.activo,
    pa.nombre_pais AS pais_nombre,
    t.id_trabajador,
    t.fk_empresa,
    t.fk_sede,
    e.razon_social AS empresa_nombre,
    s.nombre AS sede_nombre,
    pd.num_documento AS documento_numero,
    COALESCE(di.nombre_documento, (di.codigo)::text) AS documento_tipo
   FROM ((((((public.personas p
     LEFT JOIN public.paises pa ON ((pa.id_pais = p.fk_pais)))
     JOIN public.trabajadores t ON ((t.fk_persona = p.id_persona)))
     LEFT JOIN public.empresas e ON ((e.id_empresa = t.fk_empresa)))
     LEFT JOIN public.sedes s ON ((s.id_sede = t.fk_sede)))
     LEFT JOIN LATERAL ( SELECT pd2.num_documento,
            pd2.fk_tipo_doc
           FROM public.persona_documentos pd2
          WHERE (pd2.fk_persona = p.id_persona)
          ORDER BY pd2.id_persona_doc
         LIMIT 1) pd ON (true))
     LEFT JOIN public.documentos_identidad di ON ((di.id_doc = pd.fk_tipo_doc)));
CREATE VIEW public.v_trabajadores AS
 SELECT DISTINCT ON (p.id_persona, e.id_empresa) e.razon_social AS empresa,
    s.nombre AS sede,
    t.id_trabajador,
    p.id_persona,
    p.apellido_paterno,
    p.apellido_materno,
    p.nombres,
    p.fecha_nacimiento,
    p.genero,
    c.cargo,
    e.id_empresa,
    s.id_sede
   FROM ((((public.contrato c
     JOIN public.trabajadores t ON ((t.id_trabajador = c.fk_trabajador)))
     JOIN public.personas p ON ((p.id_persona = t.fk_persona)))
     JOIN public.empresas e ON ((e.id_empresa = t.fk_empresa)))
     JOIN public.sedes s ON ((s.id_sede = t.fk_sede)))
  ORDER BY p.id_persona, e.id_empresa, ((c.fecha_fin IS NULL) OR (c.fecha_fin >= CURRENT_DATE)) DESC, c.fecha_inicio DESC NULLS LAST, c.id_contrato DESC;
CREATE VIEW public.v_trabajadores_temporal AS
 SELECT e.razon_social AS empresa,
    s.nombre AS sede,
    t.id_trabajador,
    p.apellido_paterno,
    p.apellido_materno,
    p.nombres,
    p.fecha_nacimiento,
    p.genero,
    c.cargo,
    p.id_persona,
    e.id_empresa,
    s.id_sede,
    dni.num_documento AS dni,
    t.fotografia_url
   FROM (((((public.trabajadores t
     JOIN public.personas p ON ((p.id_persona = t.fk_persona)))
     JOIN public.sedes s ON ((s.id_sede = t.fk_sede)))
     JOIN public.empresas e ON ((e.id_empresa = t.fk_empresa)))
     LEFT JOIN LATERAL ( SELECT c1.cargo
           FROM public.contrato c1
          WHERE (c1.fk_trabajador = t.id_trabajador)
          ORDER BY ((c1.fecha_fin IS NULL) OR (c1.fecha_fin >= CURRENT_DATE)) DESC, c1.fecha_inicio DESC NULLS LAST, c1.id_contrato DESC
         LIMIT 1) c ON (true))
     LEFT JOIN LATERAL ( SELECT pd.num_documento
           FROM (public.persona_documentos pd
             JOIN public.documentos_identidad di ON ((di.id_doc = pd.fk_tipo_doc)))
          WHERE ((pd.fk_persona = p.id_persona) AND (COALESCE(pd.activo, true) = true) AND (upper((di.codigo)::text) = 'DNI'::text))
          ORDER BY pd.id_persona_doc DESC
         LIMIT 1) dni ON (true));
CREATE VIEW public.v_ubigeo_temporal AS
 SELECT u.id_ubigeo,
    u.fk_pais,
    u.fk_nivel,
    u.fk_padre,
    u.nombre,
    u.codigo,
    u.activo,
    n.nombre_nivel,
    n.nivel
   FROM (public.ubigeo u
     LEFT JOIN public.niveles_ubigeo n ON ((n.id_nivel_ubigeo = u.fk_nivel)));
