CREATE OR REPLACE FUNCTION public.hn_dispatchscada_pivot_creator()
 RETURNS text
 LANGUAGE plpgsql
AS $function$DECLARE
	sql text;
	r record;
BEGIN
	sql := 'SELECT settlementdate,regionid';
	
	FOR r IN SELECT DISTINCT co2e_energy_source FROM public.co2eii_available_generators
	LOOP
		sql := sql || E'\n,SUM(scadavalue) FILTER (WHERE co2e_energy_source = ''' || r.co2e_energy_source || ''') "' || LOWER(r.co2e_energy_source) || '"';
	END LOOP;

	sql := sql || E'\nFROM public.dispatch_scada ds';
	sql := sql || E'\n INNER JOIN (SELECT DISTINCT duid,regionid,co2e_energy_source FROM public.co2eii_available_generators) co USING(duid)';
	sql := sql || E'\nGROUP BY 1,2';
	raise notice '%', sql;
	RETURN sql;
END;$function$
