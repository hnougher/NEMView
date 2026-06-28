CREATE TABLE public.co2eii_available_generators (
	stationname character varying(80) NOT NULL,
	duid character varying(10) NOT NULL,
	gensetid character varying(20) NOT NULL,
	regionid character varying(20) NOT NULL,
	co2e_emissions_factor numeric(18,8) NOT NULL,
	co2e_energy_source character varying(100) NOT NULL,
	co2e_data_source character varying(20) NOT NULL,
	CONSTRAINT cdeii_available_generators_pkey PRIMARY KEY (gensetid)
);

-- Index: public.cdeii_available_generators_duid_multi_idx
CREATE INDEX IF NOT EXISTS cdeii_available_generators_duid_multi_idx
	ON public.co2eii_available_generators USING btree
	(duid COLLATE pg_catalog."default" ASC NULLS LAST)
	INCLUDE (co2e_energy_source, regionid)
	WITH (deduplicate_items='true')
	TABLESPACE pg_default;
