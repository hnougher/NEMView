CREATE TABLE public.dispatch_scada (
	settlementdate timestamp(0) with time zone NOT NULL,
	duid character varying(10) NOT NULL,
	scadavalue numeric(16,6) NOT NULL,
	lastchanged timestamp(0) with time zone NOT NULL,
	energy_source character varying(100) DEFAULT hn_duid_energy_source(duid),
	regionid character varying(20) DEFAULT hn_duid_regionid(duid)
);

-- Convert to a Timescale hypertable.
SELECT create_hypertable(
	'public.dispatch_scada',
	'settlementdate',
	chunk_time_interval => INTERVAL '7 days',
	if_not_exists => TRUE
);

-- Retention policy as configured in Timescale.
SELECT add_retention_policy(
	'public.dispatch_scada',
	INTERVAL '6 mons',
	if_not_exists => TRUE,
	schedule_interval => INTERVAL '1 day'
);

-- Additional indexes configured in the database.
-- Index: public.dispatch_scada_energy_source_idx
CREATE INDEX IF NOT EXISTS dispatch_scada_energy_source_idx
	ON public.dispatch_scada USING btree
	(energy_source COLLATE pg_catalog."default" ASC NULLS LAST)
	WITH (deduplicate_items='true')
	TABLESPACE pg_default;

-- Index: public.dispatch_scada_settlementdate_idx
CREATE INDEX IF NOT EXISTS dispatch_scada_settlementdate_idx
	ON public.dispatch_scada USING btree
	(settlementdate ASC NULLS LAST)
	WITH (deduplicate_items='true')
	TABLESPACE pg_default;
