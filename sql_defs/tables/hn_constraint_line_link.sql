CREATE TABLE public.hn_constraint_line_link (
	line_id character varying(30) NOT NULL,
	segment_id smallint NOT NULL DEFAULT 1,
	constraint_id character varying(120) NOT NULL,
	reversed boolean NOT NULL DEFAULT false,
	priority smallint NOT NULL DEFAULT 1,
	multiplier numeric(3,2) NOT NULL DEFAULT 1,
	is_outage boolean NOT NULL DEFAULT false,
	CONSTRAINT hn_constraint_line_link_pkey PRIMARY KEY (line_id, segment_id, constraint_id)
);

-- Index: public.hn_constraint_line_link_contraintid_idx
CREATE INDEX IF NOT EXISTS hn_constraint_line_link_contraintid_idx
	ON public.hn_constraint_line_link USING btree
	(constraint_id COLLATE pg_catalog."default" ASC NULLS LAST)
	WITH (deduplicate_items='true')
	TABLESPACE pg_default;
