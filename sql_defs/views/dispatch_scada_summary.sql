CREATE OR REPLACE VIEW public.dispatch_scada_summary AS
SELECT ds.regionid,
    ds.settlementdate,
    ds.bagasse,
    ds."battery storage",
    ds."biomass and industrial materials",
    ds."black coal",
    ds."brown coal",
    ds."coal seam methane",
    ds."coal mine waste gas",
    ds."diesel oil",
    ds.ethane,
    ds.hydro,
    ds."kerosene - non aviation",
    ds."landfill biogas methane",
    ds."natural gas (pipeline)",
    ds."other biofuels",
    ds.solar,
    ds.wind
FROM _timescaledb_internal._materialized_hypertable_7 ds
WHERE ds.settlementdate < COALESCE(
    _timescaledb_functions.to_timestamp(
        _timescaledb_functions.cagg_watermark(7)
    ),
    '-infinity'::timestamp with time zone
)
UNION ALL
SELECT ds.regionid,
    time_bucket('00:05:00'::interval, ds.settlementdate) AS settlementdate,
    sum(ds.scadavalue) FILTER (WHERE lower(ds.energy_source::text) = 'bagasse'::text) AS bagasse,
    sum(ds.scadavalue) FILTER (WHERE lower(ds.energy_source::text) = 'battery storage'::text) AS "battery storage",
    sum(ds.scadavalue) FILTER (WHERE lower(ds.energy_source::text) = 'biomass and industrial materials'::text) AS "biomass and industrial materials",
    sum(ds.scadavalue) FILTER (WHERE lower(ds.energy_source::text) = 'black coal'::text) AS "black coal",
    sum(ds.scadavalue) FILTER (WHERE lower(ds.energy_source::text) = 'brown coal'::text) AS "brown coal",
    sum(ds.scadavalue) FILTER (WHERE lower(ds.energy_source::text) = 'coal seam methane'::text) AS "coal seam methane",
    sum(ds.scadavalue) FILTER (WHERE lower(ds.energy_source::text) = 'coal mine waste gas'::text) AS "coal mine waste gas",
    sum(ds.scadavalue) FILTER (WHERE lower(ds.energy_source::text) = 'diesel oil'::text) AS "diesel oil",
    sum(ds.scadavalue) FILTER (WHERE lower(ds.energy_source::text) = 'ethane'::text) AS ethane,
    sum(ds.scadavalue) FILTER (WHERE lower(ds.energy_source::text) = 'hydro'::text) AS hydro,
    sum(ds.scadavalue) FILTER (WHERE lower(ds.energy_source::text) = 'kerosene - non aviation'::text) AS "kerosene - non aviation",
    sum(ds.scadavalue) FILTER (WHERE lower(ds.energy_source::text) = 'landfill biogas methane'::text) AS "landfill biogas methane",
    sum(ds.scadavalue) FILTER (WHERE lower(ds.energy_source::text) = 'natural gas (pipeline)'::text) AS "natural gas (pipeline)",
    sum(ds.scadavalue) FILTER (WHERE lower(ds.energy_source::text) = 'other biofuels'::text) AS "other biofuels",
    sum(ds.scadavalue) FILTER (WHERE lower(ds.energy_source::text) = 'solar'::text) AS solar,
    sum(ds.scadavalue) FILTER (WHERE lower(ds.energy_source::text) = 'wind'::text) AS wind
FROM dispatch_scada ds
WHERE ds.regionid IS NOT NULL
  AND ds.settlementdate >= COALESCE(
    _timescaledb_functions.to_timestamp(
        _timescaledb_functions.cagg_watermark(7)
    ),
    '-infinity'::timestamp with time zone
  )
GROUP BY ds.regionid,
    (time_bucket('00:05:00'::interval, ds.settlementdate));
