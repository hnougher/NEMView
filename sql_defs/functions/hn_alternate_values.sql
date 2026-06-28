CREATE OR REPLACE FUNCTION public.hn_alternate_values(timestamp with time zone)
 RETURNS TABLE(alternate_value_id character varying)
 LANGUAGE plpgsql
 STABLE PARALLEL SAFE COST 10 ROWS 20
AS $function$
BEGIN
	RETURN QUERY
	SELECT a.alternate_value_id
	FROM public.hn_alternate_value_id a
	WHERE (
		(time_start IS NULL AND time_end IS NULL)
		OR (time_start <= time_end AND CAST($1 AT TIME ZONE 'UTC+10' AS TIME) BETWEEN time_start AND time_end)
		OR (time_start > time_end AND (CAST($1 AT TIME ZONE 'UTC+10' AS TIME) >= time_start OR CAST($1 AT TIME ZONE 'UTC+10' AS TIME) <= time_end))
	) AND (
		(month_start IS NULL AND month_end IS NULL)
		OR (month_start <= month_end AND EXTRACT(MONTH FROM $1) BETWEEN month_start AND month_end)
		OR (month_start > month_end AND (EXTRACT(MONTH FROM $1) >= month_start OR EXTRACT(MONTH FROM $1) <= month_end))
	);
END;
$function$
