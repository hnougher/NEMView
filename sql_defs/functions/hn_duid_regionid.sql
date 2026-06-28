CREATE OR REPLACE FUNCTION public.hn_duid_regionid(duid_in character varying)
 RETURNS character varying
 LANGUAGE sql
 IMMUTABLE PARALLEL SAFE STRICT LEAKPROOF COST 1
AS $function$SELECT regionid
FROM co2eii_available_generators
WHERE duid = duid_in
LIMIT 1$function$
