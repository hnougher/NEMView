-- Creates a continuous aggregate martialised view of the dispatch_scada table.

-- Create the table
CREATE MATERIALIZED VIEW dispatch_scada_summary
WITH (timescaledb.continuous) AS
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
GROUP BY 1,2
WITH NO DATA;

-- Configuration for 7 day chunks, continuous updates, 6 month rentention and 15min delay on aggregation
SELECT set_chunk_time_interval('dispatch_scada_summary', INTERVAL '7 days');
ALTER MATERIALIZED VIEW dispatch_scada_summary set (timescaledb.materialized_only = false);
SELECT add_retention_policy('dispatch_scada_summary', INTERVAL '6 months');
SELECT add_continuous_aggregate_policy('dispatch_scada_summary',
  start_offset => INTERVAL '1 h',
  end_offset => INTERVAL '15 min',
  schedule_interval => INTERVAL '5 min');

-- Update the entire table
CALL refresh_continuous_aggregate('dispatch_scada_summary', NULL, localtimestamp - INTERVAL '15 min');
