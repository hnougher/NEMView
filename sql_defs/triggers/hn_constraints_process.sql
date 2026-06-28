CREATE OR REPLACE FUNCTION public.hn_constraints_process()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$DECLARE
BEGIN

	-- Detect the type used
	NEW.type := CASE
		WHEN NEW.constraint_id ~ '^D(ATA)?(S(NAP)?)?_' THEN 'Datasnap?'
		WHEN NEW.constraint_id ~ '^F_' THEN 'FACS'
		WHEN NEW.constraint_id ~ '^NRM_' THEN 'Negative Residue Management'
		WHEN NEW.constraint_id ~ '^[QNVST][QNVST]([^_]+)?_ROC(_\\d+)?$' THEN 'Rate of Change'
		WHEN NEW.constraint_id ~ '^[QNVST](>|>>|:|::|\\^|\\^\\^|\\+|\\+\\+|_|__)([QNVST][_-])?NIL(_|$)' THEN 'System Normal'
		WHEN NEW.constraint_id ~ '^[QNVST](>|>>|:|::|\\^|\\^\\^|\\+|\\+\\+|_|__)([QNVST][_-])?(?!\\^X)[^_]*(_|$)' THEN 'Single Outage'
		WHEN NEW.constraint_id ~ '^[QNVST](>|>>|:|::|\\^|\\^\\^|\\+|\\+\\+|_|__)([QNVST][_-])?_X_[^_]*(_|$)' THEN 'Multi Outage'
	END;

	-- Detect the variant
	NEW.variant := CASE
		-- FACS (not correct)
		WHEN NEW.constraint_id ~ '^F_[QNVST]\+[^\+_]+_[^_]+$' THEN 5
		WHEN NEW.constraint_id ~ '^F_(I|MAIN|ESTN|[QNVST]+)\+[^\+_]+_[^_]+$' THEN 1
		WHEN NEW.constraint_id ~ '^F_(I|MAIN|ESTN|[QNVST]+)\+\+[^_]+_[^_]+$' THEN 2
		WHEN NEW.constraint_id ~ '^F_(I|MAIN|ESTN|[QNVST]+)\+[^\+_]+_[^_]+_[^_]+$' THEN 3
		WHEN NEW.constraint_id ~ '^F_(I|MAIN|ESTN|[QNVST]+)\+[^\+_]+_[^_]+_[^_]+$' THEN 4
		-- Eq Sys Norm
		WHEN NEW.constraint_id ~ '^[QNVST](>|>>|:|::|\\^|\\^\\^|\\+|\\+\\+|_|__)([QNVST][_-])?NIL(_|$)' THEN 1
		WHEN NEW.constraint_id ~ '^[QNVST](>|>>|:|::|\\^|\\^\\^|\\+|\\+\\+|_|__)([^_]+_)NIL(_|$)' THEN 2
		-- Eq Single Outage
		WHEN NEW.constraint_id ~ '^[QNVST](>|>>|:|::|\\^|\\^\\^|\\+|\\+\\+|_|__)([QNVST][_-])?(?!\\^X)[^_]*(_|$)' THEN 1
		WHEN NEW.constraint_id ~ '^[QNVST](>|>>|:|::|\\^|\\^\\^|\\+|\\+\\+|_|__)([^_]+_)(?!\\^X)[^_]*(_|$)' THEN 2
	END;

	NEW.state := CASE
	WHEN NEW.type = 'System Normal' OR NEW.type = 'Single Outage' OR NEW.type = 'Multi Outage' THEN
		SUBSTRING(NEW.constraint_id,1,1)
	END;
	
	RETURN NEW;
END;
$function$
