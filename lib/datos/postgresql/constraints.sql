--
-- PostgreSQL database dump
--

\restrict mQ72IA0EhTPSJStupCo4FUbS2bmYGpIKroDGJPROZohedMg8b1pUmOaJlLVagk6

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

SET default_tablespace = '';

--
-- Name: area_mineral_carguio area_mineral_carguio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.area_mineral_carguio
    ADD CONSTRAINT area_mineral_carguio_pkey PRIMARY KEY (id_area_mineral);


--
-- Name: asistencia asistencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asistencia
    ADD CONSTRAINT asistencia_pkey PRIMARY KEY (id_asistencia);


--
-- Name: carnets_plantillas_temp carnets_plantillas_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carnets_plantillas_temp
    ADD CONSTRAINT carnets_plantillas_temp_pkey PRIMARY KEY (id_plantilla);


--
-- Name: contrato contrato_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contrato
    ADD CONSTRAINT contrato_pkey PRIMARY KEY (id_contrato);


--
-- Name: credenciales_acceso credenciales_acceso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credenciales_acceso
    ADD CONSTRAINT credenciales_acceso_pkey PRIMARY KEY (id_credencial);


--
-- Name: credenciales_usuario credenciales_usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credenciales_usuario
    ADD CONSTRAINT credenciales_usuario_pkey PRIMARY KEY (id_credencial_usuario);


--
-- Name: credenciales_usuario_roles credenciales_usuario_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credenciales_usuario_roles
    ADD CONSTRAINT credenciales_usuario_roles_pkey PRIMARY KEY (id_credencial_usuario_rol);


--
-- Name: credenciales_usuario_roles credenciales_usuario_roles_unique_trabajador_rol; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credenciales_usuario_roles
    ADD CONSTRAINT credenciales_usuario_roles_unique_trabajador_rol UNIQUE (fk_trabajador, fk_rol);


--
-- Name: credenciales_usuario credenciales_usuario_unique_trabajador; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credenciales_usuario
    ADD CONSTRAINT credenciales_usuario_unique_trabajador UNIQUE (fk_trabajador);


--
-- Name: credenciales_usuario credenciales_usuario_unique_usuario; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credenciales_usuario
    ADD CONSTRAINT credenciales_usuario_unique_usuario UNIQUE (fk_usuario);


--
-- Name: documento_empresa_formato documento_empresa_formato_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documento_empresa_formato
    ADD CONSTRAINT documento_empresa_formato_pkey PRIMARY KEY (id_doc_empresa);


--
-- Name: documentos_identidad_formatos documentos_identidad_formatos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documentos_identidad_formatos
    ADD CONSTRAINT documentos_identidad_formatos_pkey PRIMARY KEY (id_formato_doc);


--
-- Name: documentos_identidad documentos_identidad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documentos_identidad
    ADD CONSTRAINT documentos_identidad_pkey PRIMARY KEY (id_doc);


--
-- Name: empresas empresa_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.empresas
    ADD CONSTRAINT empresa_pkey PRIMARY KEY (id_empresa);


--
-- Name: empresas empresas_uk_pais_doc_num; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.empresas
    ADD CONSTRAINT empresas_uk_pais_doc_num UNIQUE (fk_pais, fk_tipo_doc, numero_documento);


--
-- Name: equipos_control equipos_control_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipos_control
    ADD CONSTRAINT equipos_control_pkey PRIMARY KEY (id_equipo_control);


--
-- Name: idiomas idiomas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idiomas
    ADD CONSTRAINT idiomas_pkey PRIMARY KEY (codigo);


--
-- Name: monedas monedas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monedas
    ADD CONSTRAINT monedas_pkey PRIMARY KEY (id_moneda);


--
-- Name: niveles_ubigeo niveles_ubigeo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.niveles_ubigeo
    ADD CONSTRAINT niveles_ubigeo_pkey PRIMARY KEY (id_nivel_ubigeo);


--
-- Name: paises paises_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paises
    ADD CONSTRAINT paises_pkey PRIMARY KEY (id_pais);


--
-- Name: persona_documentos persona_documentos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persona_documentos
    ADD CONSTRAINT persona_documentos_pkey PRIMARY KEY (id_persona_doc);


--
-- Name: personas personas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personas
    ADD CONSTRAINT personas_pkey PRIMARY KEY (id_persona);


--
-- Name: posiciones posiciones_2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posiciones
    ADD CONSTRAINT posiciones_2_pkey PRIMARY KEY (id_posicion);


--
-- Name: posiciones_temp posiciones_temp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posiciones_temp
    ADD CONSTRAINT posiciones_temp_pkey PRIMARY KEY (id_posicion);


--
-- Name: relacion_empresas relacion_empresas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relacion_empresas
    ADD CONSTRAINT relacion_empresas_pkey PRIMARY KEY (id_relacion_empresas);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id_rol);


--
-- Name: sede_empresas_autorizadas sede_empresas_autorizadas_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sede_empresas_autorizadas
    ADD CONSTRAINT sede_empresas_autorizadas_pk PRIMARY KEY (id_sede_empresas_autorizadas);


--
-- Name: sede_empresas_autorizadas sede_empresas_autorizadas_uk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sede_empresas_autorizadas
    ADD CONSTRAINT sede_empresas_autorizadas_uk UNIQUE (fk_sede, fk_empresa);


--
-- Name: sedes sedes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sedes
    ADD CONSTRAINT sedes_pkey PRIMARY KEY (id_sede);


--
-- Name: tablas tablas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tablas
    ADD CONSTRAINT tablas_pkey PRIMARY KEY (id_tabla);


--
-- Name: trabajadores trabajadores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trabajadores
    ADD CONSTRAINT trabajadores_pkey PRIMARY KEY (id_trabajador);


--
-- Name: ubigeo ubigeo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ubigeo
    ADD CONSTRAINT ubigeo_pkey PRIMARY KEY (id_ubigeo);


--
-- Name: unir_personas unir_personas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unir_personas
    ADD CONSTRAINT unir_personas_pkey PRIMARY KEY (id_union);


--
-- Name: vc_fm_excavadora vc_fm_excavadora_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vc_fm_excavadora
    ADD CONSTRAINT vc_fm_excavadora_pkey PRIMARY KEY (id_vc_excavadora);


--
-- Name: vc_fm_volquete vc_fm_volquete_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vc_fm_volquete
    ADD CONSTRAINT vc_fm_volquete_pkey PRIMARY KEY (id_fm_volquete);


--
-- Name: vc_p_volquete vc_p_volquete_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vc_p_volquete
    ADD CONSTRAINT vc_p_volquete_pkey PRIMARY KEY (id_p_volquete);


--
-- Name: verificacion_docs_id verificacion_docs_id_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.verificacion_docs_id
    ADD CONSTRAINT verificacion_docs_id_pkey PRIMARY KEY (id_verificacion);


--
-- Name: verificacion_empresas verificacion_empresas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.verificacion_empresas
    ADD CONSTRAINT verificacion_empresas_pkey PRIMARY KEY (id_verificacion_empresa);


--
-- Name: asistencia_fk_empresa_fecha_hora_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX asistencia_fk_empresa_fecha_hora_idx ON public.asistencia USING btree (fk_empresa, fecha_hora);


--
-- Name: asistencia_fk_sede_fecha_hora_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX asistencia_fk_sede_fecha_hora_idx ON public.asistencia USING btree (fk_sede, fecha_hora);


--
-- Name: asistencia_idx_orden; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX asistencia_idx_orden ON public.asistencia USING btree (fk_sede, fk_trabajador, fecha_hora);


--
-- Name: credenciales_acceso_trabajador_tecnologia_base_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX credenciales_acceso_trabajador_tecnologia_base_uidx ON public.credenciales_acceso USING btree (fk_trabajador, tecnologia) WHERE (tecnologia = ANY (ARRAY['QRCode'::text, 'BarCode'::text, 'Manual'::text]));


--
-- Name: documentos_identidad_codigo_global_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX documentos_identidad_codigo_global_uidx ON public.documentos_identidad USING btree (codigo) WHERE (fk_pais_aplicacion IS NULL);


--
-- Name: documentos_identidad_codigo_pais_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX documentos_identidad_codigo_pais_uidx ON public.documentos_identidad USING btree (codigo, fk_pais_aplicacion) WHERE (fk_pais_aplicacion IS NOT NULL);


--
-- Name: documentos_identidad_formatos_doc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX documentos_identidad_formatos_doc_idx ON public.documentos_identidad_formatos USING btree (fk_doc);


--
-- Name: documentos_identidad_formatos_doc_orden_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX documentos_identidad_formatos_doc_orden_uidx ON public.documentos_identidad_formatos USING btree (fk_doc, orden);


--
-- Name: empresas_idx_lookup_ruc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX empresas_idx_lookup_ruc ON public.empresas USING btree (fk_pais, fk_tipo_doc, numero_documento) WHERE (activo = true);


--
-- Name: idx_carnets_plantillas_temp_fk_empresa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_carnets_plantillas_temp_fk_empresa ON public.carnets_plantillas_temp USING btree (fk_empresa);


--
-- Name: idx_carnets_plantillas_temp_fk_sede; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_carnets_plantillas_temp_fk_sede ON public.carnets_plantillas_temp USING btree (fk_sede);


--
-- Name: idx_credenciales_usuario_fk_trabajador; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_credenciales_usuario_fk_trabajador ON public.credenciales_usuario USING btree (fk_trabajador);


--
-- Name: idx_credenciales_usuario_fk_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_credenciales_usuario_fk_usuario ON public.credenciales_usuario USING btree (fk_usuario);


--
-- Name: idx_credenciales_usuario_roles_fk_rol; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_credenciales_usuario_roles_fk_rol ON public.credenciales_usuario_roles USING btree (fk_rol);


--
-- Name: idx_credenciales_usuario_roles_fk_trabajador; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_credenciales_usuario_roles_fk_trabajador ON public.credenciales_usuario_roles USING btree (fk_trabajador);


--
-- Name: idx_trabajadores_fk_sede; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_trabajadores_fk_sede ON public.trabajadores USING btree (fk_sede);


--
-- Name: monedas_codigo_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX monedas_codigo_uidx ON public.monedas USING btree (codigo);


--
-- Name: paises_iso2_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX paises_iso2_uidx ON public.paises USING btree (iso2);


--
-- Name: paises_iso3_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX paises_iso3_uidx ON public.paises USING btree (iso3);


--
-- Name: persona_documentos_doc_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX persona_documentos_doc_uidx ON public.persona_documentos USING btree (fk_pais_emisor, fk_tipo_doc, num_documento);


--
-- Name: persona_documentos_persona_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX persona_documentos_persona_idx ON public.persona_documentos USING btree (fk_persona);


--
-- Name: persona_documentos_tipo_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX persona_documentos_tipo_idx ON public.persona_documentos USING btree (fk_tipo_doc);


--
-- Name: personas_apellidos_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX personas_apellidos_idx ON public.personas USING btree (apellido_paterno, apellido_materno);


--
-- Name: personas_nombres_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX personas_nombres_idx ON public.personas USING btree (nombres);


--
-- Name: personas_pais_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX personas_pais_idx ON public.personas USING btree (fk_pais);


--
-- Name: relacion_empresas_destino_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX relacion_empresas_destino_idx ON public.relacion_empresas USING btree (fk_empresa_destino);


--
-- Name: relacion_empresas_origen_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX relacion_empresas_origen_idx ON public.relacion_empresas USING btree (fk_empresa_origen);


--
-- Name: relacion_empresas_perm_edit_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX relacion_empresas_perm_edit_gin ON public.relacion_empresas USING gin (permisos_edicion);


--
-- Name: relacion_empresas_perm_vis_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX relacion_empresas_perm_vis_gin ON public.relacion_empresas USING gin (permisos_visualizacion);


--
-- Name: sede_empresas_autorizadas_fechas_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sede_empresas_autorizadas_fechas_idx ON public.sede_empresas_autorizadas USING btree (fecha_inicio, fecha_fin);


--
-- Name: sede_empresas_autorizadas_fk_empresa_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sede_empresas_autorizadas_fk_empresa_idx ON public.sede_empresas_autorizadas USING btree (fk_empresa);


--
-- Name: sede_empresas_autorizadas_fk_sede_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sede_empresas_autorizadas_fk_sede_idx ON public.sede_empresas_autorizadas USING btree (fk_sede);


--
-- Name: unir_personas_destino_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX unir_personas_destino_idx ON public.unir_personas USING btree (fk_persona_destino);


--
-- Name: unir_personas_origen_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unir_personas_origen_uidx ON public.unir_personas USING btree (fk_persona_origen);


--
-- Name: ux_asistencia_orden_dia; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_asistencia_orden_dia ON public.asistencia USING btree (fk_sede, fk_trabajador, ((fecha_hora)::date), orden);


--
-- Name: verificacion_docs_id_doc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX verificacion_docs_id_doc_idx ON public.verificacion_docs_id USING btree (fk_persona_doc);


--
-- Name: verificacion_docs_id_fecha_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX verificacion_docs_id_fecha_idx ON public.verificacion_docs_id USING btree (fecha_verificacion);


--
-- Name: v_documentos_identidad_temporal _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.v_documentos_identidad_temporal AS
 SELECT di.id_doc,
    di.codigo,
    di.nombre_documento,
    di.fk_pais_aplicacion,
    di.activo,
    di.categoria_doc_id,
    di.orden_doc_id,
    COALESCE(jsonb_agg(jsonb_build_object('id_formato_doc', df.id_formato_doc, 'fk_doc', df.fk_doc, 'nombre_formato', df.nombre_formato, 'regex_validacion', df.regex_validacion, 'ejemplo', df.ejemplo, 'mensaje_error', df.mensaje_error, 'activo', df.activo, 'orden', df.orden) ORDER BY df.orden) FILTER (WHERE (df.id_formato_doc IS NOT NULL)), '[]'::jsonb) AS formatos
   FROM (public.documentos_identidad di
     LEFT JOIN public.documentos_identidad_formatos df ON ((df.fk_doc = di.id_doc)))
  GROUP BY di.id_doc;


--
-- Name: asistencia asistencia_asignar_empresa_trg; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER asistencia_asignar_empresa_trg BEFORE INSERT ON public.asistencia FOR EACH ROW EXECUTE FUNCTION public.asistencia_asignar_empresa();


--
-- Name: asistencia trg_asistencia_antes_insercion; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_asistencia_antes_insercion BEFORE INSERT ON public.asistencia FOR EACH ROW EXECUTE FUNCTION public.asistencia_antes_insercion();


--
-- Name: asistencia trg_asistencia_set_orden; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_asistencia_set_orden BEFORE INSERT ON public.asistencia FOR EACH ROW EXECUTE FUNCTION public.asistencia_set_orden();


--
-- Name: trabajadores trg_trabajadores_crear_credenciales_base; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_trabajadores_crear_credenciales_base AFTER INSERT ON public.trabajadores FOR EACH ROW EXECUTE FUNCTION public.trabajadores_crear_credenciales_base();


--
-- Name: asistencia asistencia_fk_credencial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asistencia
    ADD CONSTRAINT asistencia_fk_credencial_fkey FOREIGN KEY (fk_credencial) REFERENCES public.credenciales_acceso(id_credencial);


--
-- Name: asistencia asistencia_fk_equipo_control_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asistencia
    ADD CONSTRAINT asistencia_fk_equipo_control_fkey FOREIGN KEY (fk_equipo_control) REFERENCES public.equipos_control(id_equipo_control);


--
-- Name: asistencia asistencia_fk_sede_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asistencia
    ADD CONSTRAINT asistencia_fk_sede_fkey FOREIGN KEY (fk_sede) REFERENCES public.sedes(id_sede);


--
-- Name: asistencia asistencia_fk_trabajador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asistencia
    ADD CONSTRAINT asistencia_fk_trabajador_fkey FOREIGN KEY (fk_trabajador) REFERENCES public.trabajadores(id_trabajador);


--
-- Name: carnets_plantillas_temp carnets_plantillas_temp_fk_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carnets_plantillas_temp
    ADD CONSTRAINT carnets_plantillas_temp_fk_empresa_fkey FOREIGN KEY (fk_empresa) REFERENCES public.empresas(id_empresa);


--
-- Name: carnets_plantillas_temp carnets_plantillas_temp_fk_sede_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carnets_plantillas_temp
    ADD CONSTRAINT carnets_plantillas_temp_fk_sede_fkey FOREIGN KEY (fk_sede) REFERENCES public.sedes(id_sede);


--
-- Name: contrato contrato_fk_moneda_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contrato
    ADD CONSTRAINT contrato_fk_moneda_fkey FOREIGN KEY (fk_moneda) REFERENCES public.monedas(id_moneda);


--
-- Name: contrato contrato_fk_trabajador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contrato
    ADD CONSTRAINT contrato_fk_trabajador_fkey FOREIGN KEY (fk_trabajador) REFERENCES public.trabajadores(id_trabajador);


--
-- Name: credenciales_acceso credenciales_acceso_fk_trabajador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credenciales_acceso
    ADD CONSTRAINT credenciales_acceso_fk_trabajador_fkey FOREIGN KEY (fk_trabajador) REFERENCES public.trabajadores(id_trabajador);


--
-- Name: credenciales_usuario credenciales_usuario_fk_trabajador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credenciales_usuario
    ADD CONSTRAINT credenciales_usuario_fk_trabajador_fkey FOREIGN KEY (fk_trabajador) REFERENCES public.trabajadores(id_trabajador) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: credenciales_usuario credenciales_usuario_fk_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credenciales_usuario
    ADD CONSTRAINT credenciales_usuario_fk_usuario_fkey FOREIGN KEY (fk_usuario) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: credenciales_usuario_roles credenciales_usuario_roles_fk_rol_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credenciales_usuario_roles
    ADD CONSTRAINT credenciales_usuario_roles_fk_rol_fkey FOREIGN KEY (fk_rol) REFERENCES public.roles(id_rol) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: credenciales_usuario_roles credenciales_usuario_roles_fk_trabajador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credenciales_usuario_roles
    ADD CONSTRAINT credenciales_usuario_roles_fk_trabajador_fkey FOREIGN KEY (fk_trabajador) REFERENCES public.trabajadores(id_trabajador) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documento_empresa_formato documento_empresa_formato_fk_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documento_empresa_formato
    ADD CONSTRAINT documento_empresa_formato_fk_pais_fkey FOREIGN KEY (fk_pais) REFERENCES public.paises(id_pais) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: documentos_identidad documentos_identidad_fk_pais_aplicacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documentos_identidad
    ADD CONSTRAINT documentos_identidad_fk_pais_aplicacion_fkey FOREIGN KEY (fk_pais_aplicacion) REFERENCES public.paises(id_pais) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: documentos_identidad_formatos documentos_identidad_formatos_fk_doc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documentos_identidad_formatos
    ADD CONSTRAINT documentos_identidad_formatos_fk_doc_fkey FOREIGN KEY (fk_doc) REFERENCES public.documentos_identidad(id_doc) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: empresas empresa_fk_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.empresas
    ADD CONSTRAINT empresa_fk_pais_fkey FOREIGN KEY (fk_pais) REFERENCES public.paises(id_pais) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: empresas empresa_fk_tipo_doc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.empresas
    ADD CONSTRAINT empresa_fk_tipo_doc_fkey FOREIGN KEY (fk_tipo_doc) REFERENCES public.documento_empresa_formato(id_doc_empresa) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: empresas empresa_fk_ubigeo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.empresas
    ADD CONSTRAINT empresa_fk_ubigeo_fkey FOREIGN KEY (fk_ubigeo) REFERENCES public.ubigeo(id_ubigeo) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: equipos_control equipos_control_fk_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipos_control
    ADD CONSTRAINT equipos_control_fk_empresa_fkey FOREIGN KEY (fk_empresa) REFERENCES public.empresas(id_empresa);


--
-- Name: equipos_control equipos_control_fk_sede_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.equipos_control
    ADD CONSTRAINT equipos_control_fk_sede_fkey FOREIGN KEY (fk_sede) REFERENCES public.sedes(id_sede);


--
-- Name: monedas monedas_fk_pais_emisor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monedas
    ADD CONSTRAINT monedas_fk_pais_emisor_fkey FOREIGN KEY (fk_pais_emisor) REFERENCES public.paises(id_pais) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: niveles_ubigeo niveles_ubigeo_fk_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.niveles_ubigeo
    ADD CONSTRAINT niveles_ubigeo_fk_pais_fkey FOREIGN KEY (fk_pais) REFERENCES public.paises(id_pais);


--
-- Name: paises paises_fk_idioma_pred_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paises
    ADD CONSTRAINT paises_fk_idioma_pred_fkey FOREIGN KEY (fk_idioma_pred) REFERENCES public.idiomas(codigo) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: paises paises_fk_moneda_pred_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paises
    ADD CONSTRAINT paises_fk_moneda_pred_fkey FOREIGN KEY (fk_moneda_pred) REFERENCES public.monedas(codigo) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: persona_documentos persona_documentos_fk_pais_emisor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persona_documentos
    ADD CONSTRAINT persona_documentos_fk_pais_emisor_fkey FOREIGN KEY (fk_pais_emisor) REFERENCES public.paises(id_pais) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: persona_documentos persona_documentos_fk_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persona_documentos
    ADD CONSTRAINT persona_documentos_fk_persona_fkey FOREIGN KEY (fk_persona) REFERENCES public.personas(id_persona) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: persona_documentos persona_documentos_fk_tipo_doc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persona_documentos
    ADD CONSTRAINT persona_documentos_fk_tipo_doc_fkey FOREIGN KEY (fk_tipo_doc) REFERENCES public.documentos_identidad(id_doc) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: personas personas_fk_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personas
    ADD CONSTRAINT personas_fk_pais_fkey FOREIGN KEY (fk_pais) REFERENCES public.paises(id_pais) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: posiciones posiciones_fk_emisor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posiciones
    ADD CONSTRAINT posiciones_fk_emisor_fkey FOREIGN KEY (fk_emisor) REFERENCES public.equipos_control(id_equipo_control);


--
-- Name: posiciones posiciones_fk_receptor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posiciones
    ADD CONSTRAINT posiciones_fk_receptor_fkey FOREIGN KEY (fk_receptor) REFERENCES public.equipos_control(id_equipo_control);


--
-- Name: posiciones_temp posiciones_temp_fk_emisor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posiciones_temp
    ADD CONSTRAINT posiciones_temp_fk_emisor_fkey FOREIGN KEY (fk_emisor) REFERENCES public.equipos_control(id_equipo_control);


--
-- Name: posiciones_temp posiciones_temp_fk_receptor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posiciones_temp
    ADD CONSTRAINT posiciones_temp_fk_receptor_fkey FOREIGN KEY (fk_receptor) REFERENCES public.equipos_control(id_equipo_control);


--
-- Name: relacion_empresas relacion_empresas_fk_empresa_destino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relacion_empresas
    ADD CONSTRAINT relacion_empresas_fk_empresa_destino_fkey FOREIGN KEY (fk_empresa_destino) REFERENCES public.empresas(id_empresa) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: relacion_empresas relacion_empresas_fk_empresa_origen_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relacion_empresas
    ADD CONSTRAINT relacion_empresas_fk_empresa_origen_fkey FOREIGN KEY (fk_empresa_origen) REFERENCES public.empresas(id_empresa) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sede_empresas_autorizadas sede_empresas_autorizadas_fk_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sede_empresas_autorizadas
    ADD CONSTRAINT sede_empresas_autorizadas_fk_empresa_fkey FOREIGN KEY (fk_empresa) REFERENCES public.empresas(id_empresa) ON DELETE CASCADE;


--
-- Name: sede_empresas_autorizadas sede_empresas_autorizadas_fk_sede_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sede_empresas_autorizadas
    ADD CONSTRAINT sede_empresas_autorizadas_fk_sede_fkey FOREIGN KEY (fk_sede) REFERENCES public.sedes(id_sede) ON DELETE CASCADE;


--
-- Name: sedes sedes_fk_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sedes
    ADD CONSTRAINT sedes_fk_empresa_fkey FOREIGN KEY (fk_empresa) REFERENCES public.empresas(id_empresa);


--
-- Name: sedes sedes_fk_ubigeo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sedes
    ADD CONSTRAINT sedes_fk_ubigeo_fkey FOREIGN KEY (fk_ubigeo) REFERENCES public.ubigeo(id_ubigeo);


--
-- Name: trabajadores trabajadores_fk_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trabajadores
    ADD CONSTRAINT trabajadores_fk_empresa_fkey FOREIGN KEY (fk_empresa) REFERENCES public.empresas(id_empresa);


--
-- Name: trabajadores trabajadores_fk_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trabajadores
    ADD CONSTRAINT trabajadores_fk_persona_fkey FOREIGN KEY (fk_persona) REFERENCES public.personas(id_persona);


--
-- Name: trabajadores trabajadores_fk_referido_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trabajadores
    ADD CONSTRAINT trabajadores_fk_referido_fkey FOREIGN KEY (fk_referido) REFERENCES public.personas(id_persona);


--
-- Name: trabajadores trabajadores_fk_sede_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trabajadores
    ADD CONSTRAINT trabajadores_fk_sede_fkey FOREIGN KEY (fk_sede) REFERENCES public.sedes(id_sede);


--
-- Name: trabajadores trabajadores_fk_ubigeo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trabajadores
    ADD CONSTRAINT trabajadores_fk_ubigeo_fkey FOREIGN KEY (fk_ubigeo) REFERENCES public.ubigeo(id_ubigeo);


--
-- Name: ubigeo ubigeo_fk_nivel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ubigeo
    ADD CONSTRAINT ubigeo_fk_nivel_fkey FOREIGN KEY (fk_nivel) REFERENCES public.niveles_ubigeo(id_nivel_ubigeo);


--
-- Name: ubigeo ubigeo_fk_padre_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ubigeo
    ADD CONSTRAINT ubigeo_fk_padre_fkey FOREIGN KEY (fk_padre) REFERENCES public.ubigeo(id_ubigeo);


--
-- Name: ubigeo ubigeo_fk_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ubigeo
    ADD CONSTRAINT ubigeo_fk_pais_fkey FOREIGN KEY (fk_pais) REFERENCES public.paises(id_pais);


--
-- Name: unir_personas unir_personas_fk_persona_destino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unir_personas
    ADD CONSTRAINT unir_personas_fk_persona_destino_fkey FOREIGN KEY (fk_persona_destino) REFERENCES public.personas(id_persona) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: unir_personas unir_personas_fk_persona_origen_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unir_personas
    ADD CONSTRAINT unir_personas_fk_persona_origen_fkey FOREIGN KEY (fk_persona_origen) REFERENCES public.personas(id_persona) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: vc_fm_excavadora vc_fm_excavadora_fk_equipo_control_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vc_fm_excavadora
    ADD CONSTRAINT vc_fm_excavadora_fk_equipo_control_fkey FOREIGN KEY (fk_equipo_control) REFERENCES public.equipos_control(id_equipo_control);


--
-- Name: vc_fm_volquete vc_fm_volquete_fk_equipo_control_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vc_fm_volquete
    ADD CONSTRAINT vc_fm_volquete_fk_equipo_control_fkey FOREIGN KEY (fk_equipo_control) REFERENCES public.equipos_control(id_equipo_control);


--
-- Name: verificacion_docs_id verificacion_docs_id_fk_persona_doc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.verificacion_docs_id
    ADD CONSTRAINT verificacion_docs_id_fk_persona_doc_fkey FOREIGN KEY (fk_persona_doc) REFERENCES public.persona_documentos(id_persona_doc) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: verificacion_empresas verificacion_empresas_fk_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.verificacion_empresas
    ADD CONSTRAINT verificacion_empresas_fk_empresa_fkey FOREIGN KEY (fk_empresa) REFERENCES public.empresas(id_empresa);


--
-- Name: niveles_ubigeo; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.niveles_ubigeo ENABLE ROW LEVEL SECURITY;

--
-- Name: roles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

--
-- Name: tablas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tablas ENABLE ROW LEVEL SECURITY;

--
-- Name: ubigeo; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.ubigeo ENABLE ROW LEVEL SECURITY;

--
-- Name: verificacion_empresas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.verificacion_empresas ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict mQ72IA0EhTPSJStupCo4FUbS2bmYGpIKroDGJPROZohedMg8b1pUmOaJlLVagk6

