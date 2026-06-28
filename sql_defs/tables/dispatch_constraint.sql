CREATE TABLE public.dispatch_constraint (
	settlementdate timestamp(0) with time zone NOT NULL,
	runno smallint NOT NULL,
	constraintid character varying(120) NOT NULL,
	dispatchinterval numeric(22,0) NOT NULL,
	intervention smallint NOT NULL,
	rhs numeric(15,5),
	marginvalue numeric(15,5),
	violationdegree numeric(15,5),
	lastchanged timestamp(0) with time zone,
	duid character varying(50),
	genconid_effectivedate timestamp(0) with time zone,
	genconid_versionno smallint,
	lhs numeric(15,5)
);

-- Convert to a Timescale hypertable.
SELECT create_hypertable(
	'public.dispatch_constraint',
	'settlementdate',
	chunk_time_interval => INTERVAL '7 days',
	if_not_exists => TRUE
);

-- Retention policy as configured in Timescale.
SELECT add_retention_policy(
	'public.dispatch_constraint',
	INTERVAL '6 mons',
	if_not_exists => TRUE,
	schedule_interval => INTERVAL '1 day'
);

-- Additional indexes configured in the database.
-- Index: public.dispatchconstraint_constraintid
CREATE INDEX IF NOT EXISTS dispatchconstraint_constraintid
	ON public.dispatch_constraint USING btree
	(constraintid COLLATE pg_catalog."default" varchar_pattern_ops ASC NULLS LAST)
	WITH (deduplicate_items='true')
	TABLESPACE pg_default;

-- Index: public.dispatchconstraint_settlementdate_idx
CREATE INDEX IF NOT EXISTS dispatchconstraint_settlementdate_idx
	ON public.dispatch_constraint USING btree
	(settlementdate ASC NULLS LAST)
	WITH (deduplicate_items='true')
	TABLESPACE pg_default;
