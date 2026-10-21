CREATE FUNCTION public."DocsEmpresaPeruRUC_apisperu"(p_ruc text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'vault'
    AS $_$
declare
  v_ruc text := trim(coalesce(p_ruc,''));
CREATE FUNCTION public."DocsEmpresaPeruRUC_consultor"(p_ruc text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'vault'
    AS $_$
declare
  v_ruc text := trim(coalesce(p_ruc,''));
CREATE FUNCTION public."DocsEmpresaPeruRUC_peruapi"(p_ruc text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'vault'
    AS $_$
declare
  v_ruc text := trim(coalesce(p_ruc,''));
CREATE FUNCTION public."DocsEmpresaPeruRUC_router"(p_ruc text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare
  r1 jsonb;
CREATE FUNCTION public."DocsIdPeruDNI_apisperu"(p_dni text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'vault'
    AS $$declare
  v_dni text := trim(coalesce(p_dni,''));
CREATE FUNCTION public."DocsIdPeruDNI_consultor"(p_dni text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'vault'
    AS $$declare
  v_dni text := trim(coalesce(p_dni,''));
CREATE FUNCTION public."DocsIdPeruDNI_peruapi"(p_dni text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'vault'
    AS $$declare
  v_dni text := trim(coalesce(p_dni,''));
CREATE FUNCTION public."DocsIdPeruDNI_router"(p_dni text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'vault'
    AS $$
declare
  r1 jsonb;
CREATE FUNCTION public.asistencia_antes_insercion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
  v_zona_horaria text;
CREATE FUNCTION public.asistencia_asignar_empresa() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if new.fk_empresa is null then
    select t.fk_empresa
      into new.fk_empresa
    from public.trabajadores t
    where t.id_trabajador = new.fk_trabajador;
CREATE FUNCTION public.asistencia_set_orden() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
  v_zona_horaria text;
CREATE FUNCTION public.crear_credenciales_base_trabajador(p_id_trabajador uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
    v_fk_persona uuid;
CREATE FUNCTION public.insert_posiciones_temp(p_paquetes jsonb) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    paquete JSONB;
CREATE FUNCTION public.obtener_numero_doc_prioritario(p_fk_persona uuid) RETURNS text
    LANGUAGE sql STABLE
    AS $$
    select pd.num_documento
    from public.persona_documentos pd
    join public.documentos_identidad di
      on di.id_doc = pd.fk_tipo_doc
    where pd.fk_persona = p_fk_persona
      and pd.num_documento is not null
      and btrim(pd.num_documento) <> ''
    order by
      case
        when upper(di.codigo) = 'DNI' then 1
        when upper(di.codigo) = 'PASAPORTE' then 2
        else 3
      end,
      pd.id_persona_doc
    limit 1
$$;
CREATE FUNCTION public.trabajadores_crear_credenciales_base() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    perform public.crear_credenciales_base_trabajador(new.id_trabajador);
