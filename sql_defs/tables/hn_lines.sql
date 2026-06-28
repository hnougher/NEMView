CREATE TABLE public.hn_lines (
	line_id character varying(30) NOT NULL,
	name character varying(100) NOT NULL,
	kva smallint,
	place_names character varying(100)[],
	place_bypassed boolean[],
	is_major_line boolean NOT NULL,
	notes text,
	CONSTRAINT hn_lines_pkey PRIMARY KEY (line_id)
);
