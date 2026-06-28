CREATE OR REPLACE FUNCTION public.hn_scada_graph()
 RETURNS json
 LANGUAGE plpgsql
AS $function$DECLARE
	j JSON;
BEGIN
	SELECT json_agg(t) INTO j
	FROM (
		SELECT ds.settlementdate,
		ds.duid,
		ds.scadavalue
		FROM dispatch_scada ds
		WHERE (ds.energy_source = 'Black coal'
		OR ds.energy_source = 'Brown coal'
		OR ds.energy_source = 'Natural Gas (Pipeline)')
		AND ds.regionid = 'NSW1'
	) t;
	RETURN j;
END;$function$
