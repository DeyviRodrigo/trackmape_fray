-- Configuracion operativa de prueba para areas, rutas y puntos.
-- Modelo actual: una sola tabla con metadatos y GeoJSON en la misma fila.

drop table if exists public.pr_elementos_operativos cascade;
drop table if exists public.pr_geometrias_operativas cascade;

create table if not exists public.pr_elementos_operativos (
  id_elemento uuid primary key default gen_random_uuid(),
  fk_empresa uuid not null
    references public.empresas(id_empresa)
    on delete cascade,
  fk_sede uuid null
    references public.sedes(id_sede)
    on delete set null,
  categoria text not null,
  tipo_operativo text not null,
  nombre text not null,
  descripcion text null,
  geojson jsonb not null,
  color text not null default '#ff9800',
  prioridad integer not null default 0,
  activo boolean not null default true,
  fecha_creacion timestamptz not null default now(),
  fecha_actualizacion timestamptz not null default now(),
  constraint pr_elementos_operativos_categoria_check
    check (categoria in ('area', 'ruta', 'punto')),
  constraint pr_elementos_operativos_color_check
    check (color ~ '^#[0-9A-Fa-f]{6}$'),
  constraint pr_elementos_operativos_geojson_tipo_check
    check (
      (categoria = 'area' and geojson ->> 'type' = 'Polygon')
      or (categoria = 'ruta' and geojson ->> 'type' = 'LineString')
      or (categoria = 'punto' and geojson ->> 'type' = 'Point')
    )
);

create index if not exists idx_pr_elementos_operativos_empresa_activo
  on public.pr_elementos_operativos (fk_empresa, activo);

create index if not exists idx_pr_elementos_operativos_sede_activo
  on public.pr_elementos_operativos (fk_sede, activo);

create index if not exists idx_pr_elementos_operativos_categoria_activo
  on public.pr_elementos_operativos (categoria, activo);

grant select, insert, update, delete on public.pr_elementos_operativos
  to anon, authenticated;

-- Limpieza manual si quieres volver a borrar la prueba:
-- drop table if exists public.pr_elementos_operativos cascade;
