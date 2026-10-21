-- GIS v1 TrackMAPE
-- Ejecutar manualmente en Supabase SQL Editor.
-- Mantiene GeoJSON en JSONB para una primera version liviana.

create extension if not exists pgcrypto;

create table if not exists public.tipos_area (
  id_tipo_area uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  color text not null default '#ff9800',
  activo boolean not null default true,
  fecha_creacion timestamptz not null default now()
);

create table if not exists public.areas_operativas (
  id_area uuid primary key default gen_random_uuid(),
  fk_empresa uuid not null references public.empresas(id_empresa),
  fk_sede uuid null references public.sedes(id_sede),
  fk_tipo_area uuid not null references public.tipos_area(id_tipo_area),
  nombre text not null,
  geojson jsonb not null,
  color text not null default '#ff9800',
  activo boolean not null default true,
  prioridad integer not null default 0,
  fecha_creacion timestamptz not null default now(),
  constraint areas_operativas_geojson_polygon
    check (geojson ->> 'type' = 'Polygon')
);

create table if not exists public.rutas_operativas (
  id_ruta uuid primary key default gen_random_uuid(),
  fk_empresa uuid not null references public.empresas(id_empresa),
  fk_sede uuid null references public.sedes(id_sede),
  nombre text not null,
  geojson jsonb not null,
  color text not null default '#00bcd4',
  activo boolean not null default true,
  fecha_creacion timestamptz not null default now(),
  constraint rutas_operativas_geojson_linestring
    check (geojson ->> 'type' = 'LineString')
);

create index if not exists idx_areas_operativas_empresa_activo
  on public.areas_operativas (fk_empresa, activo);

create index if not exists idx_areas_operativas_sede_activo
  on public.areas_operativas (fk_sede, activo);

create index if not exists idx_rutas_operativas_empresa_activo
  on public.rutas_operativas (fk_empresa, activo);

create index if not exists idx_rutas_operativas_sede_activo
  on public.rutas_operativas (fk_sede, activo);

insert into public.tipos_area (nombre, color, activo)
values
  ('Corte', '#ef5350', true),
  ('Carga', '#00bcd4', true),
  ('Descarga', '#ff9800', true),
  ('Chute', '#ffb300', true),
  ('Desmonte', '#8d6e63', true),
  ('Estacionamiento', '#66bb6a', true)
on conflict (nombre) do update
set
  color = excluded.color,
  activo = excluded.activo;

grant select on public.tipos_area to anon, authenticated;
grant select on public.areas_operativas to anon, authenticated;
grant select on public.rutas_operativas to anon, authenticated;

-- Ejemplo de insercion manual de area:
-- insert into public.areas_operativas (
--   fk_empresa, fk_sede, fk_tipo_area, nombre, geojson, color
-- )
-- select
--   'UUID_EMPRESA',
--   null,
--   id_tipo_area,
--   'Carga principal',
--   '{"type":"Polygon","coordinates":[[[-70.0,-15.0],[-70.0,-15.1],[-69.9,-15.1],[-69.9,-15.0],[-70.0,-15.0]]]}'::jsonb,
--   '#00bcd4'
-- from public.tipos_area
-- where nombre = 'Carga';

-- Ejemplo de insercion manual de ruta:
-- insert into public.rutas_operativas (
--   fk_empresa, fk_sede, nombre, geojson, color
-- )
-- values (
--   'UUID_EMPRESA',
--   null,
--   'Ruta Carga - Descarga',
--   '{"type":"LineString","coordinates":[[-70.0,-15.0],[-69.95,-15.05],[-69.9,-15.1]]}'::jsonb,
--   '#00bcd4'
-- );
