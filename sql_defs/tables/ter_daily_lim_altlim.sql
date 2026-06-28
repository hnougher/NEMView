CREATE TABLE public.ter_daily_lim_altlim (
	site_id character varying(30) NOT NULL,
	equipment_type character varying(10) NOT NULL,
	equipment_id character varying(30) NOT NULL,
	region_id character varying(10) NOT NULL,
	rating_level character varying(10) NOT NULL,
	alternate_value_id character varying(30) NOT NULL,
	rating numeric(15,5) NOT NULL,
	rating_type character varying(10) NOT NULL,
	spd_id character varying(21) NOT NULL,
	effective_from timestamp(0) with time zone NOT NULL,
	effective_to timestamp(0) with time zone NOT NULL,
	CONSTRAINT ter_daily_lim_altlim_pkey PRIMARY KEY (alternate_value_id, spd_id, effective_from)
);

-- Index: public.ter_daily_lim_altlim_equipment
CREATE INDEX IF NOT EXISTS ter_daily_lim_altlim_equipment
	ON public.ter_daily_lim_altlim USING btree
	(equipment_type COLLATE pg_catalog."default" ASC NULLS LAST, equipment_id COLLATE pg_catalog."default" ASC NULLS LAST)
	WITH (deduplicate_items='true')
	TABLESPACE pg_default;

-- Index: public.ter_daily_lim_altlim_rating_level
CREATE INDEX IF NOT EXISTS ter_daily_lim_altlim_rating_level
	ON public.ter_daily_lim_altlim USING btree
	(rating_level COLLATE pg_catalog."default" ASC NULLS LAST)
	WITH (deduplicate_items='true')
	TABLESPACE pg_default;

-- Index: public.ter_daily_lim_altlim_region_id
CREATE INDEX IF NOT EXISTS ter_daily_lim_altlim_region_id
	ON public.ter_daily_lim_altlim USING btree
	(region_id COLLATE pg_catalog."default" ASC NULLS LAST)
	WITH (deduplicate_items='true')
	TABLESPACE pg_default;
