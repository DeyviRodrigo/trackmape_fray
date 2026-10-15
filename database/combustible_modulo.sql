-- Complemento para el modulo de combustible.
-- Ejecutar despues de crear public.vehiculos y public.ingresos_combustible.

alter table public.ingresos_combustible
  add column if not exists fk_vehiculo uuid null;

do $$
begin
  alter table public.ingresos_combustible
    add constraint ingresos_combustible_fk_vehiculo_fkey
    foreign key (fk_vehiculo)
    references public.vehiculos (id_vehiculo)
    on delete cascade;
exception
  when duplicate_object then null;
end $$;

create index if not exists idx_ingresos_combustible_vehiculo_fecha
  on public.ingresos_combustible (fk_vehiculo, fecha_hora desc);

-- Opcional, pero recomendado si las posiciones GPS vienen de equipos_control.
-- Permite guardar el tracker asociado al vehiculo y autocompletar fk_emisor en la app.
alter table public.vehiculos
  add column if not exists fk_equipo_control uuid null;

do $$
begin
  alter table public.vehiculos
    add constraint vehiculos_fk_equipo_control_fkey
    foreign key (fk_equipo_control)
    references public.equipos_control (id_equipo_control)
    on delete set null;
exception
  when duplicate_object then null;
end $$;

create index if not exists idx_vehiculos_fk_equipo_control
  on public.vehiculos (fk_equipo_control);
