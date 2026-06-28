CREATE TABLE public.hn_alternate_value_id (
	alternate_value_id character varying(30) NOT NULL,
	region_id character varying(10) NOT NULL,
	name character varying(120) NOT NULL,
	time_start time(0) with time zone,
	time_end time(0) with time zone,
	month_start smallint,
	month_end smallint,
	temperature_start smallint,
	temperature_end smallint,
	is_dynamic boolean NOT NULL DEFAULT false,
	v smallint NOT NULL DEFAULT 1,
	CONSTRAINT alternate_value_id_pkey PRIMARY KEY (v, alternate_value_id)
);

-- Index: public.alternate_value_id_id
CREATE INDEX IF NOT EXISTS alternate_value_id_id
	ON public.hn_alternate_value_id USING hash
	(alternate_value_id)
	TABLESPACE pg_default;

-- Index: public.alternate_value_id_region
CREATE INDEX IF NOT EXISTS alternate_value_id_region
	ON public.hn_alternate_value_id USING hash
	(region_id)
	TABLESPACE pg_default;
