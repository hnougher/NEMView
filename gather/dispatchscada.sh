#!/usr/bin/bash
# This script is run on a 5 minute interval to download the latest data from the AEMO website.
# Once downloaded the file needs to be unzipped, then processed since the file is a few CSV files concatenated together.
# The processed data is then uploaded to the PostgreSQL database using the COPY command.

## Useful cleanup SQL when things have gone wrong
#-- Find newest date in table
#--SELECT MAX(settlementdate), to_char(MAX(settlementdate),'YYYYMMDDHH24MI') FROM dispatch_scada;
#-- Be carful of multiple gatherers running at the same time
#--DELETE FROM dispatch_scada WHERE settlementdate >= '2095-11-16 06:00:00+10';
echo '-----------------------'

# Rotate the log file if larger than 1MB
logfile=/usr/local/lsws/social-japan.bnr.la/gather/dispatchscada.log
if [ -f $logfile ]; then
	if [ $(stat -c%s $logfile) -gt 1048576 ]; then
		echo 'Rotating log file' + $(stat -c%s $logfile)
		mv $logfile $logfile.old
	fi
fi

# Set the environment variables
START_EPOCH=$(date +%s)
working_dir=/usr/local/lsws/social-japan.bnr.la/tmp

# Sleep for 20 seconds to give AEMO more time to update their website
sleep 20

# Collect the filenames to download
previous=$(psql -h 10.240.0.165 -U nem_worker -d nem -t -c "SET TIME ZONE '+10';SELECT to_char(MAX(settlementdate),'YYYYMMDDHH24MI') FROM dispatch_scada;")
previous=${previous#*$'\n'}
echo "Previous: $previous"

# Get list of filenames from the AEMO website, and remove any that the middle number is less than or equal to $previous
rm $working_dir/filenames_dispatchscada.html -f
wget -O $working_dir/filenames_dispatchscada.html http://nemweb.com.au/Reports/CURRENT/Dispatch_SCADA/
filenames=$(grep -o "/PUBLIC_DISPATCHSCADA_[0-9]*_[0-9]*" $working_dir/filenames_dispatchscada.html | sed 's#^/##' | awk -v previous="$previous" -F_ '$3 > previous {print}')
rm $working_dir/filenames_dispatchscada.html -f

# Cleanup just in case
rm $working_dir/PUBLIC_DISPATCHSCADA_* -f

# Loop through the files
for filename in $filenames
do
	# Download the file and unzip it, producing a CSV
	# Retry on wget error in case AEMO has a server missing files again
	COUNT=10
	while [ $COUNT -gt 0 ]; do
		if wget -O $working_dir/$filename.zip http://nemweb.com.au/Reports/CURRENT/Dispatch_SCADA/$filename.zip; then
			break
		fi
		COUNT=$((COUNT - 1))
		sleep 1
	done
	unzip $working_dir/$filename.zip -d $working_dir

	## DISPATCH_SCADA table
	# Process the file part 1
	# Remove everything before a line starting with "I,DISPATCH,UNIT_SCADA,", keeping the line
	# And remove everything from a line starting with "C,"END OF REPORT"," onwards
	awk '/^I,DISPATCH,UNIT_SCADA,/{flag=1;print;next}/^C,"END OF REPORT",/{flag=0}flag' $working_dir/$filename.CSV > $working_dir/$filename.processed.CSV

	# Process the file part 2
	# Remove the first 4 columns of the CSV
	mlr --csv cut -x -f "I,DISPATCH,UNIT_SCADA,1" $working_dir/$filename.processed.CSV > $working_dir/$filename.final.CSV

	# Upload the file to the database using the \copy command to insert these new values into the dispatch_scada table
	psql -h 10.240.0.165 -U nem_worker -d nem <<EOF
SET TIME ZONE '+10';
START TRANSACTION;
\copy dispatch_scada FROM '$working_dir/$filename.final.CSV' DELIMITER ',' CSV HEADER
COMMIT;
EOF

	# Cleanup
	rm $working_dir/$filename.zip -f
	rm $working_dir/$filename.CSV -f
	rm $working_dir/$filename.processed.CSV -f
	rm $working_dir/$filename.final.CSV -f

	# Sleep for 1 second to avoid overloading the server
	sleep 1

	# If 4 minutes have passed since script started, cancel the loop
  NOW_EPOCH=$(date +%s)
  ELAPSED=$((NOW_EPOCH - START_EPOCH))
  if (( ELAPSED >= 240 )); then
    echo "Reached 4 minutes. Exiting loop."
    break
  fi
done

echo 'Script Complete'
