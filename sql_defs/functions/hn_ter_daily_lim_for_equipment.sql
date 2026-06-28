CREATE OR REPLACE FUNCTION public.hn_ter_daily_lim_for_equipment(p_timestamp timestamp with time zone, p_equipment_id character varying, p_rating_level character varying DEFAULT 'NORM'::character varying)
 RETURNS TABLE(rating numeric, rating_type text)
 LANGUAGE sql
 STABLE PARALLEL SAFE
AS $function$SELECT MIN(rating) rating, string_agg(rating_type,',') rating_type
FROM ter_daily_lim_altlim JOIN hn_alternate_values(p_timestamp) USING(alternate_value_id)
WHERE equipment_id = p_equipment_id AND rating_level = p_rating_level AND rating >= 0$function$
