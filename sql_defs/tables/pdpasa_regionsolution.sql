CREATE TABLE public.pdpasa_regionsolution (
	run_datetime timestamp(0) with time zone NOT NULL,
	interval_datetime timestamp(0) with time zone NOT NULL,
	regionid character varying(10) NOT NULL,
	demand10 numeric(12,2),
	demand50 numeric(12,2),
	demand90 numeric(12,2),
	reservereq numeric(12,2),
	capacityreq numeric(12,2),
	energydemand50 numeric(12,2),
	unconstrainedcapacity numeric(12,0),
	constrainedcapacity numeric(12,0),
	netinterchangeunderscarcity numeric(12,2),
	surpluscapacity numeric(12,2),
	surplusreserve numeric(12,2),
	reservecondition numeric(1,0),
	maxsurplusreserve numeric(12,2),
	maxsparecapacity numeric(12,2),
	lorcondition numeric(1,0),
	aggregatecapacityavailable numeric(12,2),
	aggregatescheduledload numeric(12,2),
	aggregatepasaavailability numeric(12,0),
	lastchanged timestamp(0) with time zone,
	runtype character varying(20) NOT NULL,
	energydemand10 numeric(12,2),
	calculatedlor1level numeric(16,6),
	calculatedlor2level numeric(16,6),
	msrnetinterchangeunderscarcity numeric(12,2),
	lorinterchangeunderscarcity numeric(12,2),
	totalintermittentgeneration numeric(15,5),
	demand_and_nonschedgen numeric(15,5),
	uigf numeric(12,2),
	semischeduledcapacity numeric(12,2),
	lor_semischeduledcapacity numeric(12,2),
	lcr numeric(16,6),
	lcr2 numeric(16,6),
	fum numeric(16,6),
	ss_solar_uigf numeric(12,2),
	ss_wind_uigf numeric(12,2),
	ss_solar_capacity numeric(12,2),
	ss_wind_capacity numeric(12,2),
	ss_solar_cleared numeric(12,2),
	ss_wind_cleared numeric(12,2),
	wdr_available numeric(12,2),
	wdr_pasaavailable numeric(12,2),
	wdr_capacity numeric(12,2)
);

-- Index: public.pdpasa_regionsolution_interval_datetime_idx
CREATE INDEX IF NOT EXISTS pdpasa_regionsolution_interval_datetime_idx
	ON public.pdpasa_regionsolution USING btree
	(interval_datetime ASC NULLS LAST)
	WITH (deduplicate_items='true')
	TABLESPACE pg_default;

-- Index: public.pdpasa_regionsolution_regionid_idx
CREATE INDEX IF NOT EXISTS pdpasa_regionsolution_regionid_idx
	ON public.pdpasa_regionsolution USING btree
	(regionid COLLATE pg_catalog."default" ASC NULLS LAST)
	WITH (deduplicate_items='true')
	TABLESPACE pg_default;

-- Index: public.pdpasa_regionsolution_run_datetime_interval_datetime_region_idx
CREATE UNIQUE INDEX IF NOT EXISTS pdpasa_regionsolution_run_datetime_interval_datetime_region_idx
	ON public.pdpasa_regionsolution USING btree
	(run_datetime ASC NULLS LAST, interval_datetime ASC NULLS LAST, regionid COLLATE pg_catalog."default" ASC NULLS LAST)
	WITH (deduplicate_items='false')
	TABLESPACE pg_default;
