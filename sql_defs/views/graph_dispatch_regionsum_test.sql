CREATE OR REPLACE VIEW public.graph_dispatch_regionsum_test AS
SELECT rs.settlementdate,
    rs.regionid,
    rs.demand_and_nonschedgen,
    rs.availablegeneration - rs.dispatchablegeneration AS remaininggeneration,
    rs.dispatchablegeneration,
    (- rs.availableload) + rs.bdu_min_avail AS availableload,
    (- rs.dispatchableload) + rs.bdu_clearedmw_load AS dispatchableload,
    rs.ss_solar_uigf,
    rs.ss_wind_uigf,
    rs.ss_solar_clearedmw + rs.ss_wind_clearedmw +
        CASE
            WHEN scada.hydro IS NULL THEN 0::numeric
            ELSE scada.hydro * 0.9
        END AS renwable_cleared,
    rs.ss_solar_clearedmw,
    rs.ss_wind_clearedmw,
        CASE
            WHEN (rs.settlementdate + '00:06:00'::interval) >= now() THEN NULL::numeric
            ELSE
            CASE
                WHEN scada.hydro IS NULL THEN 0::numeric
                ELSE scada.hydro * 0.9
            END
        END AS hydro,
        CASE
            WHEN (rs.settlementdate + '00:06:00'::interval) >= now() THEN NULL::numeric
            ELSE
            CASE
                WHEN scada."black coal" IS NULL THEN 0::numeric
                ELSE scada."black coal"
            END +
            CASE
                WHEN scada."brown coal" IS NULL THEN 0::numeric
                ELSE scada."brown coal"
            END +
            CASE
                WHEN scada."natural gas (pipeline)" IS NULL THEN 0::numeric
                ELSE scada."natural gas (pipeline)"
            END * 0.9
        END AS coal_gas,
    rs.wdr_dispatched,
    - rs.bdu_min_avail AS bdu_max_load,
    rs.bdu_max_avail AS bdu_max_gen,
    rs.bdu_clearedmw_gen - rs.bdu_clearedmw_load AS bdu_clearedmw
FROM dispatch_regionsum rs
LEFT JOIN (
    SELECT ds.settlementdate - '00:05:00'::interval AS settlementdate,
        ds.regionid,
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Bagasse'::text) AS bagasse,
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Battery Storage'::text) AS "battery storage",
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Biomass and industrial materials'::text) AS "biomass and industrial materials",
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Black coal'::text) AS "black coal",
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Brown coal'::text) AS "brown coal",
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Coal Seam Methane'::text) AS "coal seam methane",
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Coal mine waste gas'::text) AS "coal mine waste gas",
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Coal seam methane'::text) AS "coal seam methane",
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Diesel oil'::text) AS "diesel oil",
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Ethane'::text) AS ethane,
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Hydro'::text) AS hydro,
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Kerosene - non aviation'::text) AS "kerosene - non aviation",
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Landfill biogas methane'::text) AS "landfill biogas methane",
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Natural Gas (Pipeline)'::text) AS "natural gas (pipeline)",
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Other Biofuels'::text) AS "other biofuels",
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Solar'::text) AS solar,
        sum(ds.scadavalue) FILTER (WHERE ds.energy_source::text = 'Wind'::text) AS wind
    FROM dispatch_scada ds
    GROUP BY (ds.settlementdate - '00:05:00'::interval), ds.regionid
) scada(
    settlementdate,
    regionid,
    bagasse,
    "battery storage",
    "biomass and industrial materials",
    "black coal",
    "brown coal",
    "coal seam methane",
    "coal mine waste gas",
    "coal seam methane_1",
    "diesel oil",
    ethane,
    hydro,
    "kerosene - non aviation",
    "landfill biogas methane",
    "natural gas (pipeline)",
    "other biofuels",
    solar,
    wind
)
    ON (scada.settlementdate - '00:05:00'::interval) = rs.settlementdate
    AND scada.regionid::text = rs.regionid::text;
