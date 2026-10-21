--
-- PostgreSQL database dump
--

\restrict qyD3R121lqq73KNFbUhMFA3CxMk2XOgHEHXBFD8JgjLxJaZQ6gy6PqrPlwAWreE

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.10 (Ubuntu 17.10-1.pgdg24.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: roles_rangos; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.roles_rangos AS ENUM (
    'master',
    'daitec',
    'empresa',
    'area'
);


--
-- Name: DocsEmpresaPeruRUC_apisperu(text); Type: FUNCTION; Schema: public; Owner: -
--

  v_key text;
  v_url text;

  r record;
  j jsonb;

  v_ok boolean := false;

  v_id_pais_pe uuid;
  v_id_tipo_ruc uuid;
  v_id_empresa uuid;

  v_ubigeo_int int;
  v_id_ubigeo uuid;

  v_razon_social text;
  v_nombre_comercial text;
  v_estado text;
  v_condicion text;
  v_direccion text;

  v_ubigeo_txt text;

  -- ✅ extras limpios (solo lo que NO está en columnas)
  v_extras jsonb := '{}'::jsonb;

  -- extras potenciales APISPERU
  v_capital text;
  v_tipo text;
begin
  if v_ruc = '' then
    raise exception 'ruc requerido';
  end if;

  if v_ruc !~ '^[0-9]{11}$' then
    return jsonb_build_object('ok', false, 'error', 'ruc_formato_invalido', 'ruc', v_ruc);
  end if;

  select decrypted_secret
    into v_key
  from vault.decrypted_secrets
  where name = 'apisperu'
  order by created_at desc
  limit 1;

  if v_key is null then
    raise exception 'Secret Vault no encontrado: apisperu';
  end if;

  select id_pais
    into v_id_pais_pe
  from public.paises
  where iso2 = 'PE';

  if v_id_pais_pe is null then
    return jsonb_build_object('ok', false, 'error', 'País PE no configurado en tabla paises');
  end if;

  select d.id_doc_empresa
    into v_id_tipo_ruc
  from public.documento_empresa_formato d
  where d.codigo = 'RUC'
    and d.fk_pais = v_id_pais_pe
    and d.activo = true
  limit 1;

  if v_id_tipo_ruc is null then
    return jsonb_build_object('ok', false, 'error', 'Tipo de documento RUC no encontrado para PE');
  end if;

  v_url := format('https://dniruc.apisperu.com/api/v1/ruc/%s?token=%s', v_ruc, v_key);

  select *
    into r
  from extensions.http(('GET', v_url, null, null, null)::extensions.http_request);

  if r.status <> 200 then
    return jsonb_build_object('ok', false, 'status', r.status, 'error', 'http_error', 'body', coalesce(r.content,''));
  end if;

  j := (r.content)::jsonb;

  -- Parse APISPERU -> columnas principales
  v_razon_social := btrim(coalesce(j->>'razonSocial',''));
  v_nombre_comercial := nullif(btrim(coalesce(j->>'nombreComercial','')), '');
  v_estado := nullif(btrim(coalesce(j->>'estado','')), '');
  v_condicion := nullif(btrim(coalesce(j->>'condicion','')), '');
  v_direccion := nullif(btrim(coalesce(j->>'direccion','')), '');

  -- criterio de OK
  v_ok := (v_razon_social <> '' and v_estado is not null);

  -- ubigeo (de distrito)
  v_ubigeo_txt := nullif(btrim(coalesce(j->>'ubigeo','')), '');
  v_ubigeo_int := null;
  if v_ubigeo_txt is not null and v_ubigeo_txt ~ '^[0-9]+$' then
    v_ubigeo_int := v_ubigeo_txt::int;
  end if;

  if v_ubigeo_int is not null then
    select u.id_ubigeo
      into v_id_ubigeo
    from public.ubigeo u
    where u.fk_pais = v_id_pais_pe
      and u.codigo = v_ubigeo_int
    limit 1;
  end if;

  -- buscar empresa existente
  select e.id_empresa
    into v_id_empresa
  from public.empresas e
  where e.fk_pais = v_id_pais_pe
    and e.fk_tipo_doc = v_id_tipo_ruc
    and e.numero_documento = v_ruc
  limit 1;

  if not v_ok and v_id_empresa is null then
    -- devuelve raw completo SOLO en error (para diagnóstico)
    return jsonb_build_object('ok', false, 'error', 'ruc_no_encontrado', 'ruc', v_ruc, 'raw', j);
  end if;

  -- ✅ extras: solo campos NO modelados
  v_capital := nullif(btrim(coalesce(j->>'capital','')), '');
  v_tipo := nullif(btrim(coalesce(j->>'tipo','')), '');

  v_extras := jsonb_strip_nulls(jsonb_build_object(
    'capital', v_capital,
    'tipo', v_tipo
  ));

  if v_id_empresa is null then
    insert into public.empresas (
      fk_pais, fk_tipo_doc, numero_documento,
      razon_social, nombre_comercial,
      estado, condicion, fk_ubigeo, direccion,
      columnas_extras,
      activo
    )
    values (
      v_id_pais_pe, v_id_tipo_ruc, v_ruc,
      v_razon_social, v_nombre_comercial,
      v_estado, v_condicion, v_id_ubigeo, v_direccion,
      nullif(v_extras, '{}'::jsonb),
      true
    )
    returning id_empresa into v_id_empresa;

  else
    update public.empresas set
      razon_social = case when v_razon_social <> '' then v_razon_social else razon_social end,
      nombre_comercial = coalesce(v_nombre_comercial, nombre_comercial),
      estado = coalesce(v_estado, estado),
      condicion = coalesce(v_condicion, condicion),
      fk_ubigeo = coalesce(v_id_ubigeo, fk_ubigeo),
      direccion = coalesce(v_direccion, direccion),
      columnas_extras = case
        when v_extras = '{}'::jsonb then columnas_extras
        when columnas_extras is null then v_extras
        else columnas_extras || v_extras
      end,
      activo = true
    where id_empresa = v_id_empresa;
  end if;

  insert into public.verificacion_empresas (fk_empresa, verificado, fuente_verificacion, fecha_verificacion)
  values (v_id_empresa, v_ok, 'APISPERU', now());

  -- ✅ respuesta sin "raw" (si quieres, lo puedes dejar)
  return jsonb_build_object(
    'ok', v_ok,
    'id_empresa', v_id_empresa,
    'ruc', v_ruc
  );
end;
$_$;


--
-- Name: DocsEmpresaPeruRUC_consultor(text); Type: FUNCTION; Schema: public; Owner: -
--

  v_id_pais_pe uuid;
  v_id_tipo_ruc uuid;

  v_id_empresa uuid;
  v_ult_ok timestamptz;

  r_refresh jsonb := null;

  v_refresh_ok boolean := false;

  e_row jsonb;
begin
  if v_ruc = '' then
    raise exception 'ruc requerido';
  end if;

  if v_ruc !~ '^[0-9]{11}$' then
    return jsonb_build_object('ok', false, 'error', 'ruc_formato_invalido', 'ruc', v_ruc);
  end if;

  select id_pais into v_id_pais_pe
  from public.paises
  where iso2 = 'PE';

  if v_id_pais_pe is null then
    return jsonb_build_object('ok', false, 'error', 'País PE no configurado en tabla paises');
  end if;

  select d.id_doc_empresa
    into v_id_tipo_ruc
  from public.documento_empresa_formato d
  where d.codigo = 'RUC'
    and d.fk_pais = v_id_pais_pe
    and d.activo = true
  limit 1;

  if v_id_tipo_ruc is null then
    return jsonb_build_object('ok', false, 'error', 'Tipo de documento RUC no encontrado para PE');
  end if;

  -- 1) Cache
  select e.id_empresa
    into v_id_empresa
  from public.empresas e
  where e.fk_pais = v_id_pais_pe
    and e.fk_tipo_doc = v_id_tipo_ruc
    and e.numero_documento = v_ruc
    and e.activo = true
  limit 1;

  -- si no existe, refrescar
  if v_id_empresa is null then
    r_refresh := public."DocsEmpresaPeruRUC_router"(v_ruc);
    v_refresh_ok := coalesce((r_refresh->>'ok'),'false') in ('true','t','1','yes','y');

    if not v_refresh_ok then
      return jsonb_build_object(
        'ok', false,
        'modo', 'refresh',
        'ruc', v_ruc,
        'error', 'router_fallo',
        'router', r_refresh
      );
    end if;

    select e.id_empresa
      into v_id_empresa
    from public.empresas e
    where e.fk_pais = v_id_pais_pe
      and e.fk_tipo_doc = v_id_tipo_ruc
      and e.numero_documento = v_ruc
      and e.activo = true
    limit 1;

    if v_id_empresa is null then
      return jsonb_build_object(
        'ok', false,
        'modo', 'refresh',
        'ruc', v_ruc,
        'error', 'router_ok_pero_no_registro_en_bd',
        'router', r_refresh
      );
    end if;
  end if;

  -- 2) última verificación ok
  select max(v.fecha_verificacion)
    into v_ult_ok
  from public.verificacion_empresas v
  where v.fk_empresa = v_id_empresa
    and v.verificado = true;

  -- 3) refrescar si viejo (6 meses)
  if v_ult_ok is null or v_ult_ok < (now() - interval '6 months') then
    r_refresh := public."DocsEmpresaPeruRUC_router"(v_ruc);
    v_refresh_ok := coalesce((r_refresh->>'ok'),'false') in ('true','t','1','yes','y');

    if v_refresh_ok then
      select max(v.fecha_verificacion)
        into v_ult_ok
      from public.verificacion_empresas v
      where v.fk_empresa = v_id_empresa
        and v.verificado = true;
    end if;
  end if;

  -- 4) devolver la vista (formato de app)
  select to_jsonb(v)
    into e_row
  from public.v_empresas v
  where v.id_empresa = v_id_empresa;

  if e_row is null then
    return jsonb_build_object(
      'ok', false,
      'error', 'no_encontrado_en_vista',
      'id_empresa', v_id_empresa
    );
  end if;

  return jsonb_build_object(
    'ok', true,
    'modo', 'cache',
    'ruc', v_ruc,
    'ultima_verificacion_ok', v_ult_ok,
    'empresa', e_row,
    'refresh', r_refresh
  );
end;
$_$;


--
-- Name: DocsEmpresaPeruRUC_peruapi(text); Type: FUNCTION; Schema: public; Owner: -
--

  v_key text;
  v_url text;
  r record;
  j jsonb;

  v_ok boolean := false;

  v_id_pais_pe uuid;
  v_id_tipo_ruc uuid;
  v_id_empresa uuid;

  v_ubigeo_int int;
  v_id_ubigeo uuid;

  v_razon_social text;
  v_estado text;
  v_condicion text;
  v_direccion text;

  v_departamento text;
  v_provincia text;
  v_distrito text;
  v_fecha_actualizacion text;

  v_ubigeo_txt text;
begin
  if v_ruc = '' then
    raise exception 'ruc requerido';
  end if;

  if v_ruc !~ '^[0-9]{11}$' then
    return jsonb_build_object('ok', false, 'error', 'ruc_formato_invalido', 'ruc', v_ruc);
  end if;

  select decrypted_secret
    into v_key
  from vault.decrypted_secrets
  where name = 'peruapi'
  order by created_at desc
  limit 1;

  if v_key is null then
    raise exception 'Secret Vault no encontrado: peruapi';
  end if;

  select id_pais
    into v_id_pais_pe
  from public.paises
  where iso2 = 'PE';

  if v_id_pais_pe is null then
    return jsonb_build_object('ok', false, 'error', 'País PE no configurado en tabla paises');
  end if;

  -- ✅ CORREGIDO: documento_empresa_formato
  select d.id_doc_empresa
    into v_id_tipo_ruc
  from public.documento_empresa_formato d
  where d.codigo = 'RUC'
    and d.fk_pais = v_id_pais_pe
    and d.activo = true
  limit 1;

  if v_id_tipo_ruc is null then
    return jsonb_build_object('ok', false, 'error', 'Tipo de documento RUC no encontrado para PE');
  end if;

  v_url := format('https://peruapi.com/api/ruc/%s', v_ruc);

  select *
    into r
  from extensions.http((
    'GET',
    v_url,
    array[('X-API-KEY', v_key)::extensions.http_header],
    null,
    null
  )::extensions.http_request);

  if r.status <> 200 then
    return jsonb_build_object('ok', false, 'status', r.status, 'error', 'http_error', 'body', coalesce(r.content,''));
  end if;

  j := (r.content)::jsonb;

  v_ok := (coalesce(j->>'code','') = '200' and upper(coalesce(j->>'mensaje','')) = 'OK');

  v_razon_social := coalesce(j->>'razon_social','');
  v_estado := nullif(coalesce(j->>'estado',''), '');
  v_condicion := nullif(coalesce(j->>'condicion',''), '');
  v_direccion := nullif(coalesce(j->>'direccion',''), '');

  v_departamento := nullif(coalesce(j->>'departamento',''), '');
  v_provincia := nullif(coalesce(j->>'provincia',''), '');
  v_distrito := nullif(coalesce(j->>'distrito',''), '');
  v_fecha_actualizacion := nullif(coalesce(j->>'fecha_actualizacion',''), '');

  -- ✅ ubigeo seguro
  v_ubigeo_txt := nullif(btrim(coalesce(j->>'ubigeo','')), '');
  v_ubigeo_int := null;
  if v_ubigeo_txt is not null and v_ubigeo_txt ~ '^[0-9]+$' then
    v_ubigeo_int := v_ubigeo_txt::int;
  end if;

  if v_ubigeo_int is not null then
    select u.id_ubigeo
      into v_id_ubigeo
    from public.ubigeo u
    where u.fk_pais = v_id_pais_pe
      and u.codigo = v_ubigeo_int
    limit 1;
  end if;

  -- buscar empresa existente
  select e.id_empresa
    into v_id_empresa
  from public.empresas e
  where e.fk_pais = v_id_pais_pe
    and e.fk_tipo_doc = v_id_tipo_ruc
    and e.numero_documento = v_ruc
  limit 1;

  if not v_ok and v_id_empresa is null then
    return jsonb_build_object('ok', false, 'error', 'ruc_no_encontrado', 'ruc', v_ruc, 'raw', j);
  end if;

  if v_id_empresa is null then
    insert into public.empresas (
      fk_pais, fk_tipo_doc, numero_documento,
      razon_social, estado, condicion, fk_ubigeo, direccion,
      columnas_extras, activo
    )
    values (
      v_id_pais_pe, v_id_tipo_ruc, v_ruc,
      nullif(v_razon_social,''), v_estado, v_condicion, v_id_ubigeo, v_direccion,
      jsonb_strip_nulls(jsonb_build_object(
        'departamento', v_departamento,
        'provincia', v_provincia,
        'distrito', v_distrito,
        'fecha_actualizacion', v_fecha_actualizacion,
        'ubigeo_text', v_ubigeo_txt,
        'raw', j
      )),
      true
    )
    returning id_empresa into v_id_empresa;
  else
    update public.empresas set
      razon_social = case when v_razon_social <> '' then v_razon_social else razon_social end,
      estado = coalesce(v_estado, estado),
      condicion = coalesce(v_condicion, condicion),
      fk_ubigeo = coalesce(v_id_ubigeo, fk_ubigeo),
      direccion = coalesce(v_direccion, direccion),
      columnas_extras = coalesce(columnas_extras, '{}'::jsonb) ||
        jsonb_strip_nulls(jsonb_build_object(
          'departamento', v_departamento,
          'provincia', v_provincia,
          'distrito', v_distrito,
          'fecha_actualizacion', v_fecha_actualizacion,
          'ubigeo_text', v_ubigeo_txt,
          'raw', j
        )),
      activo = true
    where id_empresa = v_id_empresa;
  end if;

  insert into public.verificacion_empresas (fk_empresa, verificado, fuente_verificacion, fecha_verificacion)
  values (v_id_empresa, v_ok, 'PERUAPI', now());

  return jsonb_build_object(
    'ok', v_ok,
    'id_empresa', v_id_empresa,
    'ruc', v_ruc,
    'raw', j
  );
end;
$_$;


--
-- Name: DocsEmpresaPeruRUC_router(text); Type: FUNCTION; Schema: public; Owner: -
--

  r2 jsonb;
begin
  -- 1) Intento principal: APISPERU
  begin
    r1 := public."DocsEmpresaPeruRUC_apisperu"(p_ruc);
    if coalesce((r1->>'ok')::boolean, false) then
      return jsonb_build_object(
        'ok', true,
        'fuente', 'APISPERU',
        'resultado', r1
      );
    end if;
  exception when others then
    r1 := jsonb_build_object(
      'ok', false,
      'error', 'exception',
      'detalle', sqlerrm
    );
  end;

  -- 2) Fallback: PERUAPI
  begin
    r2 := public."DocsEmpresaPeruRUC_peruapi"(p_ruc);
    if coalesce((r2->>'ok')::boolean, false) then
      return jsonb_build_object(
        'ok', true,
        'fuente', 'PERUAPI',
        'resultado', r2,
        'primer_intento', r1
      );
    end if;
  exception when others then
    r2 := jsonb_build_object(
      'ok', false,
      'error', 'exception',
      'detalle', sqlerrm
    );
  end;

  -- 3) Si ambos fallan, retorna ambos resultados para depurar
  return jsonb_build_object(
    'ok', false,
    'fuente', null,
    'primer_intento', r1,
    'segundo_intento', r2
  );
end;
$$;


--
-- Name: DocsIdPeruDNI_apisperu(text); Type: FUNCTION; Schema: public; Owner: -
--

  v_key text;
  v_url text;
  r record;
  j jsonb;
  v_ok boolean := false;
  v_id_pais_pe uuid;
  v_id_tipo_dni uuid;
  v_id_persona uuid;
  v_id_persona_doc uuid;
  v_persona_tmp uuid;
  v_apellido_paterno text;
  v_apellido_materno text;
  v_nombres text;
  v_cod_verifica text;
begin
  if v_dni = '' then raise exception 'dni requerido'; end if;

  select decrypted_secret into v_key from vault.decrypted_secrets where name = 'apisperu' order by created_at desc limit 1;
  if v_key is null then raise exception 'Secret Vault no encontrado: apisperu'; end if;

  select id_pais into v_id_pais_pe from public.paises where iso2 = 'PE';
  if v_id_pais_pe is null then
    return jsonb_build_object('ok', false, 'error', 'País PE no configurado en tabla paises');
  end if;

  select d.id_doc into v_id_tipo_dni from public.documentos_identidad d where d.codigo = 'DNI' and d.fk_pais_aplicacion = v_id_pais_pe;
  if v_id_tipo_dni is null then
    return jsonb_build_object('ok', false, 'error', 'Tipo de documento DNI no encontrado para PE');
  end if;

  v_url := format('https://dniruc.apisperu.com/api/v1/dni/%s?token=%s', v_dni, v_key);
  select * into r from extensions.http(('GET', v_url, null, null, null)::extensions.http_request);

  if r.status <> 200 then
    return jsonb_build_object('ok', false, 'status', r.status, 'error', 'http_error', 'body', coalesce(r.content,''));
  end if;

  j := (r.content)::jsonb;
  v_nombres := coalesce(j->>'nombres','');
  v_apellido_paterno := coalesce(j->>'apellidoPaterno','');
  v_apellido_materno := nullif(coalesce(j->>'apellidoMaterno',''), '');
  v_cod_verifica := nullif(coalesce(j->>'codVerifica',''), '');
  v_ok := (v_nombres <> '' and v_apellido_paterno <> '');

  select pd.fk_persona, pd.id_persona_doc into v_id_persona, v_id_persona_doc
  from public.persona_documentos pd
  where pd.fk_pais_emisor = v_id_pais_pe and pd.fk_tipo_doc = v_id_tipo_dni and pd.num_documento = v_dni;

  if not v_ok and v_id_persona is null then
    return jsonb_build_object('ok', false, 'error', 'dni_no_encontrado', 'dni', v_dni);
  end if;

  if v_id_persona is null then
    insert into public.personas (fk_pais, nombres, apellido_paterno, apellido_materno, activo)
    values (v_id_pais_pe, v_nombres, v_apellido_paterno, v_apellido_materno, false)
    returning id_persona into v_persona_tmp;

    insert into public.persona_documentos (fk_persona, fk_pais_emisor, fk_tipo_doc, num_documento, cod_verificacion, activo)
    values (v_persona_tmp, v_id_pais_pe, v_id_tipo_dni, v_dni, v_cod_verifica, true)
    ON CONFLICT (fk_pais_emisor, fk_tipo_doc, num_documento)
    DO UPDATE SET
      cod_verificacion = coalesce(excluded.cod_verificacion, public.persona_documentos.cod_verificacion),
      activo = true
    RETURNING id_persona_doc, fk_persona INTO v_id_persona_doc, v_id_persona;

    if v_id_persona <> v_persona_tmp then
      update public.personas set activo = false where id_persona = v_persona_tmp;
    end if;
  else
    update public.personas set
      nombres = case when v_nombres <> '' then v_nombres else nombres end,
      apellido_paterno = case when v_apellido_paterno <> '' then v_apellido_paterno else apellido_paterno end,
      apellido_materno = coalesce(v_apellido_materno, apellido_materno)
    where id_persona = v_id_persona;

    update public.persona_documentos set cod_verificacion = coalesce(v_cod_verifica, cod_verificacion), activo = true
    where id_persona_doc = v_id_persona_doc;
  end if;

  insert into public.verificacion_docs_id (fk_persona_doc, verificado, fuente_verificacion, fecha_verificacion)
  values (v_id_persona_doc, v_ok, 'APISPERU', now());

  return jsonb_build_object('ok', v_ok, 'id_persona', v_id_persona, 'id_persona_doc', v_id_persona_doc, 'dni', v_dni, 'raw', j);
end;$$;


--
-- Name: DocsIdPeruDNI_consultor(text); Type: FUNCTION; Schema: public; Owner: -
--

  v_id_pais_pe uuid;
  v_id_tipo_dni uuid;
  v_id_persona uuid;
  v_id_persona_doc uuid;
  v_ult_ok timestamptz;
  r_refresh jsonb;
  p_row jsonb;
  d_row jsonb;
begin
  if v_dni = '' then raise exception 'dni requerido'; end if;

  select id_pais into v_id_pais_pe from public.paises where iso2 = 'PE';
  if v_id_pais_pe is null then
    return jsonb_build_object('ok', false, 'error', 'País PE no configurado en tabla paises');
  end if;

  select d.id_doc into v_id_tipo_dni from public.documentos_identidad d where d.codigo = 'DNI' and d.fk_pais_aplicacion = v_id_pais_pe;
  if v_id_tipo_dni is null then
    return jsonb_build_object('ok', false, 'error', 'Tipo de documento DNI no encontrado para PE');
  end if;

  select pd.fk_persona, pd.id_persona_doc into v_id_persona, v_id_persona_doc
  from public.persona_documentos pd
  where pd.fk_pais_emisor = v_id_pais_pe
    and pd.fk_tipo_doc = v_id_tipo_dni
    and pd.num_documento = v_dni
    and pd.activo = true;

  if v_id_persona_doc is null then
    r_refresh := public."DocsIdPeruDNI_router"(v_dni);
    return jsonb_build_object('ok', true, 'modo', 'refresh', 'resultado', r_refresh);
  end if;

  select max(v.fecha_verificacion) into v_ult_ok from public.verificacion_docs_id v
  where v.fk_persona_doc = v_id_persona_doc and v.verificado = true;

  if v_ult_ok is null or v_ult_ok < (now() - interval '2 years') then
    r_refresh := public."DocsIdPeruDNI_router"(v_dni);
    if coalesce((r_refresh->>'ok')::boolean, false) then
      return jsonb_build_object('ok', true, 'modo', 'refresh', 'resultado', r_refresh);
    end if;
  end if;

  select jsonb_build_object('id_persona', p.id_persona, 'nombres', p.nombres, 'apellido_paterno', p.apellido_paterno, 'apellido_materno', p.apellido_materno)
  into p_row from public.personas p where p.id_persona = v_id_persona;

  select jsonb_build_object('id_persona_doc', d.id_persona_doc, 'num_documento', d.num_documento)
  into d_row from public.persona_documentos d where d.id_persona_doc = v_id_persona_doc;

  return jsonb_build_object('ok', true, 'modo', 'cache', 'dni', v_dni, 'ultima_verificacion_ok', v_ult_ok, 'persona', p_row, 'documento', d_row);
end;$$;


--
-- Name: DocsIdPeruDNI_peruapi(text); Type: FUNCTION; Schema: public; Owner: -
--

  v_key text;
  v_url text;
  r record;
  j jsonb;
  v_ok boolean := false;
  v_id_pais_pe uuid;
  v_id_tipo_dni uuid;
  v_id_persona uuid;
  v_id_persona_doc uuid;
  v_persona_tmp uuid;
  v_dv text;
  v_apellido_paterno text;
  v_apellido_materno text;
  v_nombres text;
begin
  if v_dni = '' then raise exception 'dni requerido'; end if;

  select decrypted_secret into v_key from vault.decrypted_secrets where name = 'peruapi' order by created_at desc limit 1;
  if v_key is null then raise exception 'Secret Vault no encontrado: peruapi'; end if;

  select id_pais into v_id_pais_pe from public.paises where iso2 = 'PE';
  if v_id_pais_pe is null then
    return jsonb_build_object('ok', false, 'error', 'País PE no configurado en tabla paises');
  end if;

  select d.id_doc into v_id_tipo_dni from public.documentos_identidad d where d.codigo = 'DNI' and d.fk_pais_aplicacion = v_id_pais_pe;
  if v_id_tipo_dni is null then
    return jsonb_build_object('ok', false, 'error', 'Tipo de documento DNI no encontrado para PE');
  end if;

  v_url := format('https://peruapi.com/api/dni/%s', v_dni);
  select * into r from extensions.http(('GET', v_url, array[('X-API-KEY', v_key)::extensions.http_header], null, null)::extensions.http_request);

  if r.status <> 200 then
    return jsonb_build_object('ok', false, 'status', r.status, 'error', 'http_error', 'body', coalesce(r.content,''));
  end if;

  j := (r.content)::jsonb;
  v_ok := (coalesce(j->>'code','') = '200' and upper(coalesce(j->>'mensaje','')) = 'OK');
  v_dv := nullif(coalesce(j->>'dv',''), '');
  v_apellido_paterno := coalesce(j->>'apellido_paterno','');
  v_apellido_materno := nullif(coalesce(j->>'apellido_materno',''), '');
  v_nombres := coalesce(j->>'nombres','');

  select pd.fk_persona, pd.id_persona_doc into v_id_persona, v_id_persona_doc
  from public.persona_documentos pd
  where pd.fk_pais_emisor = v_id_pais_pe and pd.fk_tipo_doc = v_id_tipo_dni and pd.num_documento = v_dni;

  if not v_ok and v_id_persona is null then
    return jsonb_build_object('ok', false, 'error', 'dni_no_encontrado', 'dni', v_dni);
  end if;

  if v_id_persona is null then
    insert into public.personas (fk_pais, nombres, apellido_paterno, apellido_materno, activo)
    values (v_id_pais_pe, v_nombres, v_apellido_paterno, v_apellido_materno, false)
    returning id_persona into v_persona_tmp;

    insert into public.persona_documentos (fk_persona, fk_pais_emisor, fk_tipo_doc, num_documento, cod_verificacion, activo)
    values (v_persona_tmp, v_id_pais_pe, v_id_tipo_dni, v_dni, v_dv, true)
    ON CONFLICT (fk_pais_emisor, fk_tipo_doc, num_documento)
    DO UPDATE SET
      cod_verificacion = coalesce(excluded.cod_verificacion, public.persona_documentos.cod_verificacion),
      activo = true
    RETURNING id_persona_doc, fk_persona INTO v_id_persona_doc, v_id_persona;

    if v_id_persona <> v_persona_tmp then
      update public.personas set activo = false where id_persona = v_persona_tmp;
    end if;
  else
    update public.personas set
      nombres = case when v_nombres <> '' then v_nombres else nombres end,
      apellido_paterno = case when v_apellido_paterno <> '' then v_apellido_paterno else apellido_paterno end,
      apellido_materno = coalesce(v_apellido_materno, apellido_materno)
    where id_persona = v_id_persona;

    update public.persona_documentos set cod_verificacion = coalesce(v_dv, cod_verificacion), activo = true
    where id_persona_doc = v_id_persona_doc;
  end if;

  insert into public.verificacion_docs_id (fk_persona_doc, verificado, fuente_verificacion, fecha_verificacion)
  values (v_id_persona_doc, v_ok, 'PERUAPI', now());

  return jsonb_build_object('ok', v_ok, 'id_persona', v_id_persona, 'id_persona_doc', v_id_persona_doc, 'dni', v_dni, 'dv', v_dv, 'raw', j);
end;$$;


--
-- Name: DocsIdPeruDNI_router(text); Type: FUNCTION; Schema: public; Owner: -
--

  r2 jsonb;
begin
  -- 1) Intento principal: PeruAPI
  begin
    r1 := public."DocsIdPeruDNI_peruapi"(p_dni);
    if coalesce((r1->>'ok')::boolean, false) then
      return jsonb_build_object(
        'ok', true,
        'fuente', 'PERUAPI',
        'resultado', r1
      );
    end if;
  exception when others then
    r1 := jsonb_build_object(
      'ok', false,
      'error', 'exception',
      'detalle', sqlerrm
    );
  end;

  -- 2) Fallback: APISPERU
  begin
    r2 := public."DocsIdPeruDNI_apisperu"(p_dni);
    if coalesce((r2->>'ok')::boolean, false) then
      return jsonb_build_object(
        'ok', true,
        'fuente', 'APISPERU',
        'resultado', r2,
        'primer_intento', r1
      );
    end if;
  exception when others then
    r2 := jsonb_build_object(
      'ok', false,
      'error', 'exception',
      'detalle', sqlerrm
    );
  end;

  -- 3) Si ambos fallan, retorna ambos resultados para depurar
  return jsonb_build_object(
    'ok', false,
    'fuente', null,
    'primer_intento', r1,
    'segundo_intento', r2
  );
end;
$$;


--
-- Name: asistencia_antes_insercion(); Type: FUNCTION; Schema: public; Owner: -
--

  v_dia date;
  v_next smallint;
  v_fk_trabajador_cred uuid;
begin
  -- 1) Completar fk_sede desde el equipo si no vino
  if new.fk_sede is null then
    if new.fk_equipo_control is null then
      raise exception 'fk_sede null y fk_equipo_control null; no se puede determinar sede';
    end if;

    select e.fk_sede
      into new.fk_sede
    from public.equipos_control e
    where e.id_equipo_control = new.fk_equipo_control;
  end if;

  if new.fk_sede is null then
    raise exception 'fk_sede no encontrado para el equipo_control %', new.fk_equipo_control;
  end if;

  -- 2) fk_trabajador dueño de la credencial
  select c.fk_trabajador
    into v_fk_trabajador_cred
  from public.credenciales_acceso c
  where c.id_credencial = new.fk_credencial;

  if v_fk_trabajador_cred is null then
    raise exception 'fk_trabajador no encontrado para la credencial %', new.fk_credencial;
  end if;

  -- 3) Si viene fk_trabajador, validar; si no viene, completar
  if new.fk_trabajador is not null then
    if new.fk_trabajador <> v_fk_trabajador_cred then
      raise exception 'fk_trabajador (%) no coincide con el de la credencial (%)',
        new.fk_trabajador, v_fk_trabajador_cred;
    end if;
  else
    new.fk_trabajador := v_fk_trabajador_cred;
  end if;

  -- 4) Zona horaria
  select s.zona_horaria
    into v_zona_horaria
  from public.sedes s
  where s.id_sede = new.fk_sede;

  -- 5) fecha_hora por defecto (sin tz)
  if new.fecha_hora is null then
    new.fecha_hora := timezone(coalesce(v_zona_horaria,'America/Lima'), now());
  end if;

  -- 6) Si ya viene orden, no recalcular
  if new.orden is not null then
    return new;
  end if;

  v_dia := new.fecha_hora::date;

  -- 7) Lock por sede + trabajador + día
  perform pg_advisory_xact_lock(
    hashtextextended(new.fk_sede::text || '|' || new.fk_trabajador::text || '|' || v_dia::text, 0)
  );

  -- 8) Orden por sede + trabajador + día
  select coalesce(max(a.orden),0) + 1
    into v_next
  from public.asistencia a
  where a.fk_sede = new.fk_sede
    and a.fk_trabajador = new.fk_trabajador
    and a.fecha_hora::date = v_dia;

  new.orden := v_next;
  return new;
end;
$$;


--
-- Name: asistencia_asignar_empresa(); Type: FUNCTION; Schema: public; Owner: -
--

  end if;

  return new;
end;
$$;


--
-- Name: asistencia_set_orden(); Type: FUNCTION; Schema: public; Owner: -
--

  v_dia date;
  v_next smallint;
begin
  select s.zona_horaria
    into v_zona_horaria
  from public.sedes s
  where s.id_sede = new.fk_sede;

  if new.fecha_hora is null then
    new.fecha_hora := timezone(coalesce(v_zona_horaria,'America/Lima'), now());
  end if;

  if new.orden is not null then
    return new;
  end if;

  v_dia := new.fecha_hora::date;

  -- Lock por sede + trabajador + día (evita colisiones)
  perform pg_advisory_xact_lock(
    hashtextextended(new.fk_sede::text || '|' || coalesce(new.fk_trabajador::text,'') || '|' || v_dia::text, 0)
  );

  select coalesce(max(a.orden),0) + 1
    into v_next
  from public.asistencia a
  where a.fk_sede = new.fk_sede
    and a.fk_trabajador = new.fk_trabajador
    and a.fecha_hora::date = v_dia;

  new.orden := v_next;
  return new;
end;
$$;


--
-- Name: crear_credenciales_base_trabajador(uuid); Type: FUNCTION; Schema: public; Owner: -
--

    v_nombres text;
    v_apellido_paterno text;
    v_apellido_materno text;
    v_num_doc text;
    v_nombre_completo text;
begin
    -- Buscar persona del trabajador
    select
        t.fk_persona,
        p.nombres,
        p.apellido_paterno,
        p.apellido_materno
    into
        v_fk_persona,
        v_nombres,
        v_apellido_paterno,
        v_apellido_materno
    from public.trabajadores t
    join public.personas p
      on p.id_persona = t.fk_persona
    where t.id_trabajador = p_id_trabajador;

    if v_fk_persona is null then
        return;
    end if;

    -- Obtener documento prioritario
    v_num_doc := public.obtener_numero_doc_prioritario(v_fk_persona);

    if v_num_doc is null or btrim(v_num_doc) = '' then
        return;
    end if;

    -- Formato solicitado:
    -- numero_doc - NOMBRES APELLIDO_PATERNO APELLIDO_MATERNO
    v_nombre_completo := upper(
        concat_ws(
            ' ',
            coalesce(v_nombres, ''),
            coalesce(v_apellido_paterno, ''),
            coalesce(v_apellido_materno, '')
        )
    );

    insert into public.credenciales_acceso (fk_trabajador, tecnologia, valor, activo)
    values
        (p_id_trabajador, 'QRCode', v_num_doc, true),
        (p_id_trabajador, 'BarCode', v_num_doc, true),
        (p_id_trabajador, 'Manual', v_num_doc || ' - ' || v_nombre_completo, true)
    on conflict do nothing;
end;
$$;


--
-- Name: insert_posiciones_temp(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

BEGIN
    FOR paquete IN SELECT * FROM jsonb_array_elements(p_paquetes)
    LOOP
        INSERT INTO public.posiciones_temp (
            tiempo,
            fk_receptor,
            fk_emisor,
            lat_grados,
            lon_grados,
            alt_msnm_m
        )
        VALUES (
            (paquete->>'tiempo')::timestamp,
            paquete->>'fk_receptor',
            paquete->>'fk_emisor',
            (paquete->>'lat_grados')::double precision,
            (paquete->>'lon_grados')::double precision,
            (paquete->>'alt_msnm_m')::smallint
        );
    END LOOP;
END;
$$;


--
-- Name: obtener_numero_doc_prioritario(uuid); Type: FUNCTION; Schema: public; Owner: -
--



--
-- Name: trabajadores_crear_credenciales_base(); Type: FUNCTION; Schema: public; Owner: -
--

    return new;
end;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: area_mineral_carguio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.area_mineral_carguio (
    id_area_mineral uuid DEFAULT gen_random_uuid() NOT NULL,
    tiempo timestamp without time zone,
    fk_equipos_control uuid,
    area_excedente real
);


--
-- Name: asistencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asistencia (
    id_asistencia uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_sede uuid,
    fk_equipo_control uuid,
    fk_credencial uuid NOT NULL,
    fecha_hora timestamp without time zone,
    metodo text,
    orden smallint,
    fk_trabajador uuid NOT NULL,
    fk_empresa uuid,
    activo boolean DEFAULT true NOT NULL,
    observaciones text
);


--
-- Name: carnets_plantillas_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.carnets_plantillas_temp (
    id_plantilla uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_empresa uuid,
    fk_sede uuid,
    nombre text NOT NULL,
    orientacion text DEFAULT 'horizontal'::text NOT NULL,
    fondo_url text,
    logo_url text,
    campos jsonb DEFAULT '[]'::jsonb NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_eliminacion timestamp with time zone
);


--
-- Name: contrato; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contrato (
    id_contrato uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_trabajador uuid NOT NULL,
    cargo text NOT NULL,
    tipo_contrato text,
    fecha_inicio date DEFAULT CURRENT_DATE NOT NULL,
    fecha_fin date,
    remuneracion real,
    frecuencia_pago text,
    fk_moneda uuid,
    documento_url text,
    observacion text,
    columnas_extras jsonb,
    turno text,
    modalidad text,
    sistema text
);


--
-- Name: credenciales_acceso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credenciales_acceso (
    id_credencial uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_trabajador uuid NOT NULL,
    tecnologia text NOT NULL,
    valor text NOT NULL,
    clave text,
    activo boolean DEFAULT true NOT NULL
);


--
-- Name: TABLE credenciales_acceso; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.credenciales_acceso IS 'QRCode, BarCode, NFC, RFID, Huella, Etc';


--
-- Name: credenciales_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credenciales_usuario (
    id_credencial_usuario uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_trabajador uuid NOT NULL,
    fk_usuario uuid NOT NULL
);


--
-- Name: credenciales_usuario_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credenciales_usuario_roles (
    id_credencial_usuario_rol uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_trabajador uuid NOT NULL,
    fk_rol uuid NOT NULL
);


--
-- Name: documento_empresa_formato; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documento_empresa_formato (
    id_doc_empresa uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_pais uuid NOT NULL,
    codigo character varying NOT NULL,
    nombre text NOT NULL,
    regex_validacion text NOT NULL,
    ejemplo text,
    mensaje_error text,
    activo boolean DEFAULT true NOT NULL
);


--
-- Name: documentos_identidad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documentos_identidad (
    id_doc uuid DEFAULT gen_random_uuid() NOT NULL,
    codigo character varying(20) NOT NULL,
    nombre_documento text NOT NULL,
    fk_pais_aplicacion uuid,
    activo boolean DEFAULT true NOT NULL,
    categoria_doc_id text DEFAULT 'Documento Nacional'::text NOT NULL,
    orden_doc_id smallint DEFAULT '1'::smallint NOT NULL,
    CONSTRAINT documentos_identidad_codigo_chk CHECK (((codigo)::text = upper((codigo)::text)))
);


--
-- Name: documentos_identidad_formatos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documentos_identidad_formatos (
    id_formato_doc uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_doc uuid NOT NULL,
    nombre_formato text NOT NULL,
    regex_validacion text NOT NULL,
    ejemplo text,
    mensaje_error text NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    orden integer DEFAULT 1 NOT NULL
);


--
-- Name: empresas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.empresas (
    id_empresa uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_pais uuid NOT NULL,
    fk_tipo_doc uuid NOT NULL,
    numero_documento text NOT NULL,
    razon_social text NOT NULL,
    nombre_comercial text,
    estado text,
    condicion text,
    fk_ubigeo uuid,
    direccion text,
    columnas_extras jsonb,
    fk_responsable text,
    celular text,
    email text,
    pagina_web text,
    logo_url text,
    activo boolean DEFAULT true
);


--
-- Name: equipos_control; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.equipos_control (
    id_equipo_control uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_empresa uuid NOT NULL,
    fk_sede uuid,
    nombre text,
    ubicacion text,
    id_equipo_fabrica text,
    tipo_equipo_control text,
    codigo_equipo_control text,
    direccion_mac text,
    observaciones text,
    fk_area_asociada text,
    fk_equipo_asociado text,
    fecha_inicio date,
    fecha_final date
);


--
-- Name: TABLE equipos_control; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.equipos_control IS 'asistencia, visión computacional, receptores lora, trackers, etc';


--
-- Name: idiomas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idiomas (
    codigo character varying(10) NOT NULL,
    nombre_idioma text NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    CONSTRAINT idiomas_codigo_chk CHECK (((codigo)::text = lower((codigo)::text)))
);


--
-- Name: monedas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monedas (
    id_moneda uuid DEFAULT gen_random_uuid() NOT NULL,
    codigo character(3) NOT NULL,
    nombre_moneda text NOT NULL,
    simbolo text,
    decimales smallint DEFAULT 2 NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    fk_pais_emisor uuid,
    CONSTRAINT monedas_codigo_chk CHECK (((codigo)::text = upper((codigo)::text))),
    CONSTRAINT monedas_decimales_chk CHECK (((decimales >= 0) AND (decimales <= 6)))
);


--
-- Name: niveles_ubigeo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.niveles_ubigeo (
    id_nivel_ubigeo uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_pais uuid DEFAULT gen_random_uuid(),
    nombre_nivel text NOT NULL,
    nivel bigint NOT NULL,
    activo boolean DEFAULT true NOT NULL
);


--
-- Name: paises; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paises (
    id_pais uuid DEFAULT gen_random_uuid() NOT NULL,
    iso2 character(2) NOT NULL,
    iso3 character(3) NOT NULL,
    nombre_pais text NOT NULL,
    prefijo_tel text,
    fk_moneda_pred character(3),
    activo boolean DEFAULT true NOT NULL,
    fk_idioma_pred character varying(10),
    CONSTRAINT paises_iso2_chk CHECK (((iso2)::text = upper((iso2)::text))),
    CONSTRAINT paises_iso3_chk CHECK (((iso3)::text = upper((iso3)::text))),
    CONSTRAINT paises_moneda_pred_chk CHECK (((fk_moneda_pred IS NULL) OR ((fk_moneda_pred)::text = upper((fk_moneda_pred)::text))))
);


--
-- Name: persona_documentos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.persona_documentos (
    id_persona_doc uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_persona uuid NOT NULL,
    fk_pais_emisor uuid NOT NULL,
    fk_tipo_doc uuid NOT NULL,
    num_documento text NOT NULL,
    cod_verificacion text,
    activo boolean DEFAULT true NOT NULL
);


--
-- Name: personas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.personas (
    id_persona uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_pais uuid NOT NULL,
    nombres text NOT NULL,
    apellido_paterno text NOT NULL,
    apellido_materno text,
    fecha_nacimiento date,
    genero character varying(20),
    activo boolean DEFAULT true NOT NULL,
    CONSTRAINT personas_genero_chk CHECK (((genero IS NULL) OR ((genero)::text = ANY ((ARRAY['M'::character varying, 'F'::character varying, 'X'::character varying, 'NO_ESPECIFICA'::character varying])::text[]))))
);


--
-- Name: posiciones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posiciones (
    id_posicion uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    tiempo timestamp without time zone,
    fk_receptor uuid,
    fk_emisor uuid,
    epoca_rx bigint,
    lat_grados double precision,
    lon_grados double precision,
    alt_msnm_m smallint,
    hae_m smallint,
    geo_m smallint,
    pdop real,
    hdop real,
    vdop real,
    largo_payload smallint
);


--
-- Name: posiciones_temp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posiciones_temp (
    id_posicion uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    tiempo timestamp without time zone,
    fk_receptor uuid,
    fk_emisor uuid,
    epoca_rx bigint,
    lat_grados double precision,
    lon_grados double precision,
    alt_msnm_m smallint,
    hae_m smallint,
    geo_m smallint,
    pdop real,
    hdop real,
    vdop real,
    largo_payload smallint
);


--
-- Name: relacion_empresas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.relacion_empresas (
    id_relacion_empresas uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_empresa_origen uuid,
    fk_empresa_destino uuid,
    tipo_relacion text,
    permisos_visualizacion jsonb DEFAULT '[]'::jsonb NOT NULL,
    permisos_edicion jsonb DEFAULT '[]'::jsonb NOT NULL,
    vigente_desde date,
    vigente_hasta date,
    CONSTRAINT relacion_empresas_edicion_subset_chk CHECK ((permisos_edicion <@ permisos_visualizacion)),
    CONSTRAINT relacion_empresas_no_self_chk CHECK ((fk_empresa_origen <> fk_empresa_destino))
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id_rol uuid DEFAULT gen_random_uuid() NOT NULL,
    rol text,
    rango public.roles_rangos
);


--
-- Name: sede_empresas_autorizadas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sede_empresas_autorizadas (
    id_sede_empresas_autorizadas uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_sede uuid NOT NULL,
    fk_empresa uuid NOT NULL,
    fecha_inicio date DEFAULT CURRENT_DATE NOT NULL,
    fecha_fin date,
    CONSTRAINT sede_empresas_autorizadas_chk_fechas CHECK (((fecha_fin IS NULL) OR (fecha_fin >= fecha_inicio)))
);


--
-- Name: sedes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sedes (
    id_sede uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_empresa uuid NOT NULL,
    nombre text NOT NULL,
    tipo_sede text,
    fk_responsable text,
    celular text,
    email text,
    pagina_web text,
    logo_url text,
    fk_ubigeo uuid,
    direccion text,
    columnas_extras jsonb,
    activo boolean DEFAULT true,
    zona_horaria text
);


--
-- Name: tablas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tablas (
    id_tabla bigint NOT NULL,
    nombre text NOT NULL,
    modulo text,
    edicion boolean DEFAULT false NOT NULL
);


--
-- Name: tablas_id_tabla_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tablas ALTER COLUMN id_tabla ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tablas_id_tabla_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: trabajadores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trabajadores (
    id_trabajador uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_persona uuid,
    fk_sede uuid,
    celular text,
    email text,
    fk_contacto_emergencia text,
    fk_referido uuid,
    observaciones text,
    fotografia_url text,
    columnas_extras jsonb,
    fk_ubigeo uuid,
    direccion text,
    fk_empresa uuid NOT NULL,
    activo boolean DEFAULT true NOT NULL
);


--
-- Name: ubigeo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ubigeo (
    id_ubigeo uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_pais uuid,
    fk_nivel uuid,
    fk_padre uuid,
    nombre text,
    codigo integer,
    codigos_adicionales jsonb,
    activo boolean DEFAULT true
);


--
-- Name: unir_personas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.unir_personas (
    id_union uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_persona_origen uuid NOT NULL,
    fk_persona_destino uuid NOT NULL,
    motivo text,
    CONSTRAINT unir_personas_distintas_chk CHECK ((fk_persona_origen <> fk_persona_destino))
);


--
-- Name: v_documentos_identidad_temporal; Type: VIEW; Schema: public; Owner: -
--



--
-- Name: verificacion_empresas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.verificacion_empresas (
    id_verificacion_empresa uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_empresa uuid,
    verificado boolean,
    fuente_verificacion text,
    fecha_verificacion timestamp with time zone
);


--
-- Name: v_empresas; Type: VIEW; Schema: public; Owner: -
--



--
-- Name: verificacion_docs_id; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.verificacion_docs_id (
    id_verificacion uuid DEFAULT gen_random_uuid() NOT NULL,
    fk_persona_doc uuid NOT NULL,
    verificado boolean NOT NULL,
    fuente_verificacion text,
    fecha_verificacion timestamp with time zone DEFAULT now()
);


--
-- Name: v_persona_documentos_temporal; Type: VIEW; Schema: public; Owner: -
--



--
-- Name: v_personal_asistencia; Type: VIEW; Schema: public; Owner: -
--



--
-- Name: v_personal_asistencia_temporal; Type: VIEW; Schema: public; Owner: -
--



--
-- Name: v_personal_contratos; Type: VIEW; Schema: public; Owner: -
--



--
-- Name: VIEW v_personal_contratos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_personal_contratos IS 'Tabla anexa de contratos vigentes. Cada fila es un contrato vigente (fecha_fin >= hoy o NULL).
Incluye apellidos y nombres del trabajador para lectura directa en SQL.';


--
-- Name: v_personal_contratos_activos; Type: VIEW; Schema: public; Owner: -
--



--
-- Name: VIEW v_personal_contratos_activos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_personal_contratos_activos IS 'Contratos vigentes + asistencia. Cada fila representa una marcación de asistencia de un trabajador con contrato vigente.
Incluye empresa/sede, luego fecha_hora, orden y metodo, y nombres para lectura directa en SQL.';


--
-- Name: v_personal_credenciales; Type: VIEW; Schema: public; Owner: -
--



--
-- Name: v_personal_temporal; Type: VIEW; Schema: public; Owner: -
--



--
-- Name: v_trabajadores; Type: VIEW; Schema: public; Owner: -
--



--
-- Name: v_trabajadores_temporal; Type: VIEW; Schema: public; Owner: -
--



--
-- Name: VIEW v_trabajadores_temporal; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_trabajadores_temporal IS 'Listado base de trabajadores. Incluye a todos, tengan o no contrato.
El campo cargo se obtiene del contrato vigente si existe; si no, del último contrato.';


--
-- Name: v_ubigeo_temporal; Type: VIEW; Schema: public; Owner: -
--



--
-- Name: vc_fm_excavadora; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vc_fm_excavadora (
    id_vc_excavadora uuid DEFAULT gen_random_uuid() NOT NULL,
    fecha date DEFAULT CURRENT_DATE,
    estado text,
    inicial timestamp without time zone,
    final timestamp without time zone,
    t_total bigint,
    t_efectivo bigint,
    t_preparacion_anidado bigint,
    t_muerto_anidado bigint,
    fk_equipo_control uuid
);


--
-- Name: vc_fm_volquete; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vc_fm_volquete (
    id_fm_volquete uuid DEFAULT gen_random_uuid() NOT NULL,
    fecha date,
    estado text,
    inicial timestamp without time zone,
    final timestamp without time zone,
    duracion bigint,
    fk_equipo_control uuid
);


--
-- Name: vc_p_volquete; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vc_p_volquete (
    id_p_volquete uuid DEFAULT gen_random_uuid() NOT NULL,
    fecha date,
    fk_equipos_control uuid,
    estado text,
    inicial timestamp without time zone,
    final timestamp without time zone,
    duracion bigint
);


--
-- PostgreSQL database dump complete
--

\unrestrict qyD3R121lqq73KNFbUhMFA3CxMk2XOgHEHXBFD8JgjLxJaZQ6gy6PqrPlwAWreE

