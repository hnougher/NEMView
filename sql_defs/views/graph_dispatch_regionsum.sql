CREATE OR REPLACE VIEW public.graph_dispatch_regionsum AS
SELECT rs.settlementdate,
    scada.settlementdate::timestamp(0) with time zone AS settlementdate_inner,
    rs.regionid,
    rs.totaldemand,
    rs.demand_and_nonschedgen,
    rs.availablegeneration - rs.dispatchablegeneration AS remaininggeneration,
    rs.dispatchablegeneration,
    COALESCE((- rs.availableload) + rs.bdu_min_avail, 0::numeric) AS availableload,
    COALESCE((- rs.dispatchableload) + rs.bdu_clearedmw_load, 0::numeric) AS dispatchableload,
    rs.ss_solar_uigf,
    rs.ss_wind_uigf,
    rs.ss_solar_clearedmw + rs.ss_wind_clearedmw +
        CASE
            WHEN (rs.settlementdate + '00:06:00'::interval) >= now() THEN NULL::numeric
            ELSE COALESCE(scada.hydro, 0::numeric) * 0.9
        END AS renwable_cleared,
    rs.ss_solar_clearedmw,
    rs.ss_wind_clearedmw,
        CASE
            WHEN (rs.settlementdate + '00:06:00'::interval) >= now() THEN NULL::numeric
            ELSE COALESCE(scada.hydro, 0::numeric) * 0.9
        END AS hydro,
        CASE
            WHEN (rs.settlementdate + '00:06:00'::interval) >= now() THEN NULL::numeric
            ELSE (COALESCE(scada."black coal", 0::numeric) + COALESCE(scada."brown coal", 0::numeric) + COALESCE(scada."natural gas (pipeline)", 0::numeric)) * 0.9
        END AS coal_gas,
    rs.wdr_dispatched,
    COALESCE(- rs.bdu_min_avail, 0::numeric) AS bdu_max_load,
    COALESCE(rs.bdu_max_avail, 0::numeric) AS bdu_max_gen,
    COALESCE(rs.bdu_clearedmw_gen, 0::numeric) AS bdu_clearedmw_gen,
    COALESCE(- rs.bdu_clearedmw_load, 0::numeric) AS bdu_clearedmw_load,
    COALESCE(rs.bdu_clearedmw_gen - rs.bdu_clearedmw_load, 0::numeric) AS bdu_clearedmw,
        CASE
            WHEN pvm.type IS NULL THEN NULL::numeric
            ELSE COALESCE(pv.power, 0::numeric)
        END::numeric(16,6) AS rooftop_estimate,
        CASE
            WHEN pvm.type IS NULL THEN NULL::numeric
            ELSE COALESCE(pv.power, 0::numeric)
        END::numeric(16,6) + rs.totaldemand AS underlying_demand
FROM dispatch_regionsum_p5 rs
LEFT JOIN rooftop_pv_actual pv ON pv.type::text = 'SATELLITE'::text
    AND (pv.interval_datetime + '00:15:00'::interval) = rs.settlementdate
    AND rs.regionid::text = pv.regionid::text
LEFT JOIN rooftop_pv_actual pvm ON pvm.type::text = 'MEASUREMENT'::text
    AND (pvm.interval_datetime + '00:15:00'::interval) = rs.settlementdate
    AND rs.regionid::text = pvm.regionid::text
LEFT JOIN dispatch_scada_summary scada ON (scada.settlementdate - '00:05:00'::interval) = rs.settlementdate
    AND scada.regionid::text = rs.regionid::text;
