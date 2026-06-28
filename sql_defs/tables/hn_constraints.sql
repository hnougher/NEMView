CREATE TABLE public.hn_constraints (
	constraint_id character varying(120) NOT NULL,
	type character varying(120),
	variant smallint,
	json jsonb,
	"HN Note" text,
	state character(1),
	CONSTRAINT hn_constraints_pkey PRIMARY KEY (constraint_id)
);

CREATE TRIGGER hn_contraints_hn_constraints_process BEFORE INSERT OR UPDATE ON hn_constraints FOR EACH ROW EXECUTE FUNCTION hn_constraints_process();

-- Index: public.hn_constraints_type_variant_idx
CREATE INDEX IF NOT EXISTS hn_constraints_type_variant_idx
	ON public.hn_constraints USING btree
	(type COLLATE pg_catalog."default" ASC NULLS LAST)
	INCLUDE (variant)
	WITH (deduplicate_items='true')
	TABLESPACE pg_default;
