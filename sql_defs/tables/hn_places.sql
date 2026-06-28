CREATE TABLE public.hn_places (
	place_id character varying(50),
	name character varying(100) NOT NULL,
	coordinate point,
	region_id character varying(10),
	region_sub character varying(50),
	CONSTRAINT hn_places_name_key UNIQUE (name),
	CONSTRAINT hn_places_place_id_key UNIQUE (place_id),
	CONSTRAINT places_pkey PRIMARY KEY (name)
);
