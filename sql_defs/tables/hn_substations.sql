CREATE TABLE public.hn_substations (
	region character(1) NOT NULL,
	abbr character varying(8) NOT NULL,
	local_id character varying(8)[],
	name character varying(64) NOT NULL,
	CONSTRAINT hn_substations_pkey PRIMARY KEY (region, abbr)
);
