CREATE TABLE public.rooftop_pv_actual (
	interval_datetime timestamp(0) with time zone NOT NULL,
	regionid character varying(20) NOT NULL,
	power numeric(16,6),
	qi numeric(2,1) NOT NULL,
	type character varying(20) NOT NULL,
	lastchanged timestamp(0) with time zone NOT NULL,
	CONSTRAINT rooftop_pv_actual_interval_datetime_regionid_type_key UNIQUE (interval_datetime, regionid, type)
);

-- Convert to a Timescale hypertable.
SELECT create_hypertable(
	'public.rooftop_pv_actual',
	'interval_datetime',
	chunk_time_interval => INTERVAL '7 days',
	if_not_exists => TRUE
);

-- Retention policy as configured in Timescale.
SELECT add_retention_policy(
	'public.rooftop_pv_actual',
	INTERVAL '6 mons',
	if_not_exists => TRUE,
	schedule_interval => INTERVAL '1 day'
);

-- Additional indexes configured in the database.
-- Index: public.rooftop_pv_actual_interval_datetime_idx
CREATE INDEX IF NOT EXISTS rooftop_pv_actual_interval_datetime_idx
	ON public.rooftop_pv_actual USING btree
	(interval_datetime DESC NULLS LAST)
	TABLESPACE pg_default;
