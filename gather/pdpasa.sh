#!/usr/bin/bash
# This script is run on a 5 minute interval to download the latest data from the AEMO website.
# Once downloaded the file needs to be unzipped, then processed since the file is a few CSV files concatenated together.
# The processed data is then uploaded to the PostgreSQL database using the COPY command.

echo '-----------------------'

# Rotate the log file if larger than 1MB
logfile=/usr/local/lsws/social-japan.bnr.la/gather/pdpasa.log
if [ -f $logfile ]; then
	if [ $(stat -c%s $logfile) -gt 1048576 ]; then
		echo 'Rotating log file' + $(stat -c%s $logfile)
		mv $logfile $logfile.old
	fi
fi

# Set the environment variables
START_EPOCH=$(date +%s)
working_dir=/usr/local/lsws/social-japan.bnr.la/tmp

# No delay needed for 30 minute data

# Collect the filenames to download
previous=$(psql -h 10.240.0.165 -U nem_worker -d nem -t -c "SET TIME ZONE '+10';SELECT to_char(MAX(run_datetime),'YYYYMMDDHH24MI') FROM pdpasa_regionsolution;")
previous=${previous#*$'\n'}
echo "Previous: $previous"

# Get list of filenames from the AEMO website, and remove any that the middle number is less than or equal to $previous
rm $working_dir/filenames_pdpasa.html -f
wget -O $working_dir/filenames_pdpasa.html http://nemweb.com.au/Reports/CURRENT/PDPASA/
filenames=$(grep -o "/PUBLIC_PDPASA_[0-9]*_[0-9]*" $working_dir/filenames_pdpasa.html | sed 's#^/##' | awk -v previous="$previous" -F_ '$3 > previous {print}')
rm $working_dir/filenames_pdpasa.html -f

# Only keep the last filename, since we do not need history for now
# I couldn't get a direct index to work so... loop it is!
for filename in $filenames
do
	final_file=$filename
done
filenames=($final_file)

# Cleanup just in case
rm $working_dir/PUBLIC_PDPASA_* -f

# Loop through the files
for filename in $filenames
do
	# Download the file and unzip it, producing a CSV
	# Retry on wget error in case AEMO has a server missing files again
	COUNT=10
	while [ $COUNT -gt 0 ]; do
		if wget -O $working_dir/$filename.zip http://nemweb.com.au/Reports/CURRENT/PDPASA/$filename.zip; then
			break
		fi
		COUNT=$((COUNT - 1))
		sleep 1
	done
	unzip $working_dir/$filename.zip -d $working_dir

	## REGIONSOLUTION table
	# Process the file part 1
	# Remove everything before a line starting with "I,PDPASA,REGIONSOLUTION,", keeping the line
	# And remove everything from a line starting with "C," onwards
	awk '/^I,PDPASA,REGIONSOLUTION,/{flag=1;print;next}/^C,/{flag=0}flag' $working_dir/$filename.CSV > $working_dir/$filename.processed.CSV

	# Process the file part 2
	# Remove the first 4 columns of the CSV
	mlr --csv cut -x -f "I,PDPASA,REGIONSOLUTION,7" $working_dir/$filename.processed.CSV > $working_dir/$filename.final.CSV

	# Upload the file to the database using the \copy command to insert these new values into the pdpasa_regionsolution table
	psql -h 10.240.0.165 -U nem_worker -d nem <<EOF
SET TIME ZONE '+10';
START TRANSACTION;
TRUNCATE pdpasa_regionsolution;
\copy pdpasa_regionsolution FROM '$working_dir/$filename.final.CSV' DELIMITER ',' CSV HEADER
COMMIT;
EOF

	# Cleanup
	cp $working_dir/$filename.processed.CSV $working_dir/$filename.processed.regionsolution.CSV
	cp $working_dir/$filename.final.CSV $working_dir/$filename.final.regionsolution.CSV
	rm $working_dir/$filename.processed.CSV
	rm $working_dir/$filename.final.CSV

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
