CREATE TABLE public.dispatch_regionsum (
	settlementdate timestamp(0) with time zone NOT NULL,
	runno numeric(3,0) NOT NULL,
	regionid character varying(10) NOT NULL,
	dispatchinterval numeric(22,0) NOT NULL,
	intervention numeric(2,0) NOT NULL,
	totaldemand numeric(15,5),
	availablegeneration numeric(15,5),
	availableload numeric(15,5),
	demandforecast numeric(15,5),
	dispatchablegeneration numeric(15,5),
	dispatchableload numeric(15,5),
	netinterchange numeric(15,5),
	excessgeneration numeric(15,5),
	lower5mindispatch numeric(15,5),
	lower5minimport numeric(15,5),
	lower5minlocaldispatch numeric(15,5),
	lower5minlocalprice numeric(15,5),
	lower5minlocalreq numeric(15,5),
	lower5minprice numeric(15,5),
	lower5minreq numeric(15,5),
	lower5minsupplyprice numeric(15,5),
	lower60secdispatch numeric(15,5),
	lower60secimport numeric(15,5),
	lower60seclocaldispatch numeric(15,5),
	lower60seclocalprice numeric(15,5),
	lower60seclocalreq numeric(15,5),
	lower60secprice numeric(15,5),
	lower60secreq numeric(15,5),
	lower60secsupplyprice numeric(15,5),
	lower6secdispatch numeric(15,5),
	lower6secimport numeric(15,5),
	lower6seclocaldispatch numeric(15,5),
	lower6seclocalprice numeric(15,5),
	lower6seclocalreq numeric(15,5),
	lower6secprice numeric(15,5),
	lower6secreq numeric(15,5),
	lower6secsupplyprice numeric(15,5),
	raise5mindispatch numeric(15,5),
	raise5minimport numeric(15,5),
	raise5minlocaldispatch numeric(15,5),
	raise5minlocalprice numeric(15,5),
	raise5minlocalreq numeric(15,5),
	raise5minprice numeric(15,5),
	raise5minreq numeric(15,5),
	raise5minsupplyprice numeric(15,5),
	raise60secdispatch numeric(15,5),
	raise60secimport numeric(15,5),
	raise60seclocaldispatch numeric(15,5),
	raise60seclocalprice numeric(15,5),
	raise60seclocalreq numeric(15,5),
	raise60secprice numeric(15,5),
	raise60secreq numeric(15,5),
	raise60secsupplyprice numeric(15,5),
	raise6secdispatch numeric(15,5),
	raise6secimport numeric(15,5),
	raise6seclocaldispatch numeric(15,5),
	raise6seclocalprice numeric(15,5),
	raise6seclocalreq numeric(15,5),
	raise6secprice numeric(15,5),
	raise6secreq numeric(15,5),
	raise6secsupplyprice numeric(15,5),
	aggegatedispatcherror numeric(15,5),
	aggregatedispatcherror numeric(15,5),
	lastchanged timestamp(0) with time zone,
	initialsupply numeric(15,5),
	clearedsupply numeric(15,5),
	lowerregimport numeric(15,5),
	lowerreglocaldispatch numeric(15,5),
	lowerreglocalreq numeric(15,5),
	lowerregreq numeric(15,5),
	raiseregimport numeric(15,5),
	raisereglocaldispatch numeric(15,5),
	raisereglocalreq numeric(15,5),
	raiseregreq numeric(15,5),
	raise5minlocalviolation numeric(15,5),
	raisereglocalviolation numeric(15,5),
	raise60seclocalviolation numeric(15,5),
	raise6seclocalviolation numeric(15,5),
	lower5minlocalviolation numeric(15,5),
	lowerreglocalviolation numeric(15,5),
	lower60seclocalviolation numeric(15,5),
	lower6seclocalviolation numeric(15,5),
	raise5minviolation numeric(15,5),
	raiseregviolation numeric(15,5),
	raise60secviolation numeric(15,5),
	raise6secviolation numeric(15,5),
	lower5minviolation numeric(15,5),
	lowerregviolation numeric(15,5),
	lower60secviolation numeric(15,5),
	lower6secviolation numeric(15,5),
	raiser6secactualavailability numeric(16,6),
	raiser60secactualavailability numeric(16,6),
	raiser5minactualavailability numeric(16,6),
	raiseregactualavailability numeric(16,6),
	lower6secactualavailability numeric(16,6),
	lower60secactualavailability numeric(16,6),
	lower5minactualavailability numeric(16,6),
	lowerregactualavailability numeric(16,6),
	lorsurplus numeric(16,6),
	lrcsurplus numeric(16,6),
	totalintermittentgeneration numeric(15,5),
	demand_and_nonschedgen numeric(15,5),
	uigf numeric(15,5),
	semischedule_clearedmw numeric(15,5),
	semischedule_compliancemw numeric(15,5),
	ss_solar_uigf numeric(15,5),
	ss_wind_uigf numeric(15,5),
	ss_solar_clearedmw numeric(15,5),
	ss_wind_clearedmw numeric(15,5),
	ss_solar_compliancemw numeric(15,5),
	ss_wind_compliancemw numeric(15,5),
	wdr_initialmw numeric(15,5),
	wdr_available numeric(15,5),
	wdr_dispatched numeric(15,5),
	raise1seclocaldispatch numeric(15,5),
	lower1seclocaldispatch numeric(15,5),
	raise1secactualavailability numeric(16,6),
	lower1secactualavailability numeric(16,6),
	ss_solar_availability numeric(15,5),
	ss_wind_availability numeric(15,5),
	bdu_energy_storage numeric(15,5),
	bdu_min_avail numeric(15,5),
	bdu_max_avail numeric(15,5),
	bdu_clearedmw_gen numeric(15,5),
	bdu_clearedmw_load numeric(15,5),
	bdu_initial_energy_storage numeric(15,5)
);

-- Convert to a Timescale hypertable.
SELECT create_hypertable(
	'public.dispatch_regionsum',
	'settlementdate',
	chunk_time_interval => INTERVAL '7 days',
	if_not_exists => TRUE
);

-- Retention policy as configured in Timescale.
SELECT add_retention_policy(
	'public.dispatch_regionsum',
	INTERVAL '6 mons',
	if_not_exists => TRUE,
	schedule_interval => INTERVAL '1 day'
);

-- Additional indexes configured in the database.
-- Index: public.dispatch_regionsum_regionid
CREATE INDEX IF NOT EXISTS dispatch_regionsum_regionid
	ON public.dispatch_regionsum USING btree
	(regionid COLLATE pg_catalog."default" ASC NULLS LAST)
	WITH (deduplicate_items='true')
	TABLESPACE pg_default;

-- Index: public.dispatch_regionsum_settlementdate_idx
CREATE INDEX IF NOT EXISTS dispatch_regionsum_settlementdate_idx
	ON public.dispatch_regionsum USING btree
	(settlementdate ASC NULLS LAST)
	WITH (deduplicate_items='true')
	TABLESPACE pg_default;

-- Index: public.dispatch_regionsum_timezone_idx
CREATE INDEX IF NOT EXISTS dispatch_regionsum_timezone_idx
	ON public.dispatch_regionsum USING btree
	((settlementdate AT TIME ZONE '-10'::text) ASC NULLS LAST)
	WITH (deduplicate_items='true')
	TABLESPACE pg_default;
