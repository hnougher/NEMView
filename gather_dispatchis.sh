#!/usr/bin/bash
# This script is run on a 5 minute interval to download the latest data from the AEMO website.
# Once downloaded the file needs to be unzipped, then processed since the file is a few CSV files concatenated together.
# The processed data is then uploaded to the PostgreSQL database using the COPY command.

## Useful cleanup SQL when things have gone wrong
#-- Find newest date in table
#--SELECT MAX(settlementdate), to_char(MAX(settlementdate),'YYYYMMDDHH24MI') FROM dispatch_constraint;
#--SELECT MAX(settlementdate), to_char(MAX(settlementdate),'YYYYMMDDHH24MI') FROM dispatch_regionsum;
#-- Be carful of multiple gatherers running at the same time
#--DELETE FROM dispatch_constraint WHERE settlementdate >= '2025-07-01 09:55:00+10';
#--DELETE FROM dispatch_regionsum WHERE settlementdate >= '2025-07-01 09:55:00+10';
#-- Find duplicates that fill the graph
#--SELECT settlementdate, count(settlementdate) FROM public.graph_dispatch_regionsum WHERE regionid = 'NSW1' GROUP BY settlementdate HAVING count(settlementdate) > 1
echo '-----------------------'

# Rotate the log file if larger than 1MB
logfile=/usr/local/lsws/social-japan.bnr.la/gather_dispatchis.log
if [ -f $logfile ]; then
	if [ $(stat -c%s $logfile) -gt 1048576 ]; then
		echo 'Rotating log file' + $(stat -c%s $logfile)
		mv $logfile $logfile.old
	fi
fi

# Set the environment variables
working_dir=/usr/local/lsws/social-japan.bnr.la/tmp

# Collect the filenames to download
previous=$(psql -h 10.240.0.165 -U nem_worker -d nem -t -c "SET TIME ZONE '+10';SELECT to_char(MAX(settlementdate),'YYYYMMDDHH24MI') FROM dispatch_constraint;")
previous=${previous#*$'\n'}
echo "Previous: $previous"

# Get list of filenames from the AEMO website, and remove any that the middle number is less than or equal to $previous
rm $working_dir/filenames_dispatchis.html -f
wget -O $working_dir/filenames_dispatchis.html http://nemweb.com.au/Reports/CURRENT/DispatchIS_Reports/
filenames=$(grep -o "/PUBLIC_DISPATCHIS_[0-9]*_[0-9]*" $working_dir/filenames_dispatchis.html | sed 's#^/##' | awk -v previous="$previous" -F_ '$3 > previous {print}')
rm $working_dir/filenames_dispatchis.html -f

# Cleanup just in case
rm $working_dir/PUBLIC_DISPATCHIS_* -f

# Loop through the files
for filename in $filenames
do
	# Download the file and unzip it, producing a CSV
	wget -O $working_dir/$filename.zip http://nemweb.com.au/Reports/CURRENT/DispatchIS_Reports/$filename.zip
	unzip $working_dir/$filename.zip -d $working_dir

	## DISPATCH_REGIONSUM table
	# Process the file part 1
	# Remove everything before a line starting with "I,DISPATCH,REGIONSUM,", keeping the line
	# And remove everything from a line starting with "I," onwards
	awk '/^I,DISPATCH,REGIONSUM,/{flag=1;print;next}/^I,/{flag=0}flag' $working_dir/$filename.CSV > $working_dir/$filename.processed.CSV

	# Process the file part 2
	# Remove the first 4 columns of the CSV
	mlr --csv cut -x -f "I,DISPATCH,REGIONSUM,9" $working_dir/$filename.processed.CSV > $working_dir/$filename.final.CSV

	# Upload the file to the database using the \copy command to insert these new values into the dispatch_regionsum table
	psql -h 10.240.0.165 -U nem_worker -d nem <<EOF
SET TIME ZONE '+10';
START TRANSACTION;
\copy dispatch_regionsum FROM '$working_dir/$filename.final.CSV' DELIMITER ',' CSV HEADER
COMMIT;
EOF

	# Cleanup
	cp $working_dir/$filename.processed.CSV $working_dir/$filename.processed.regionsum.CSV
	cp $working_dir/$filename.final.CSV $working_dir/$filename.final.regionsum.CSV
	rm $working_dir/$filename.processed.CSV
	rm $working_dir/$filename.final.CSV

	## DISPATCH_CONSTRAINT table
	# Process the file part 1
	# Remove everything before a line starting with "I,DISPATCH,CONSTRAINT,", keeping the line
	# And remove everything from a line starting with "I," onwards
	awk '/^I,DISPATCH,CONSTRAINT,/{flag=1;print;next}/^I,/{flag=0}flag' $working_dir/$filename.CSV > $working_dir/$filename.processed.CSV

	# Process the file part 2
	# Remove the first 4 columns of the CSV
	mlr --csv cut -x -f "I,DISPATCH,CONSTRAINT,5" $working_dir/$filename.processed.CSV > $working_dir/$filename.final.CSV

	# Upload the file to the database using the \copy command to insert these new values into the dispatch_constraint table
	psql -h 10.240.0.165 -U nem_worker -d nem <<EOF
SET TIME ZONE '+10';
START TRANSACTION;
\copy dispatch_constraint FROM '$working_dir/$filename.final.CSV' DELIMITER ',' CSV HEADER
COMMIT;
EOF

	# Cleanup
	rm $working_dir/$filename.zip -f
	rm $working_dir/$filename.CSV -f
	cp $working_dir/$filename.processed.CSV $working_dir/$filename.processed.constraint.CSV
	cp $working_dir/$filename.final.CSV $working_dir/$filename.final.constraint.CSV
	rm $working_dir/$filename.processed.CSV -f
	rm $working_dir/$filename.final.CSV -f

	# Sleep for 1 second to avoid overloading the server
	sleep 1
done

# Update table hn_constraints with any new constraintid in the dispatch_constraint table
psql -h 10.240.0.165 -U nem_worker -d nem <<EOF
START TRANSACTION;
INSERT INTO hn_constraints (constraint_id)
	SELECT DISTINCT constraintid
	FROM dispatch_constraint
	WHERE settlementdate > NOW() - INTERVAL '1 day'
		AND constraintid NOT IN (SELECT constraint_id FROM hn_constraints);
COMMIT;
EOF

echo 'Script Complete'
