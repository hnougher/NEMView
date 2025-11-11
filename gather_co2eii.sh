#!/usr/bin/bash
# This script is run on a 5 minute interval to download the latest data from the AEMO website.
# Once downloaded the file needs to be unzipped, then processed since the file is a few CSV files concatenated together.
# The processed data is then uploaded to the PostgreSQL database using the COPY command.
echo '-----------------------'

# Rotate the log file if larger than 1MB
logfile=/usr/local/lsws/social-japan.bnr.la/gather_co2eii.log
if [ -f $logfile ]; then
	if [ $(stat -c%s $logfile) -gt 1048576 ]; then
		echo 'Rotating log file' + $(stat -c%s $logfile)
		mv $logfile $logfile.old
	fi
fi

# Set the environment variables
working_dir=/usr/local/lsws/social-japan.bnr.la/tmp
filename="CO2EII_AVAILABLE_GENERATORS"

# Empty the working directory, just in case of leftovers
rm $working_dir/$filename.CSV -f
rm $working_dir/$filename.processed.CSV -f
rm $working_dir/$filename.final.CSV -f

# Download the latest file from the AEMO website
url="http://nemweb.com.au/Reports/CURRENT/CDEII/$filename.CSV"
wget -O $working_dir/$filename.CSV $url

# Process the file part 1
# Remove everything before a line starting with "I,CO2EII,PUBLISHING,", keeping the line
# And remove everything from a line starting with "C,END OF REPORT," onwards
awk '/^I,CO2EII,PUBLISHING,/{flag=1;print;next}/^C,"END OF REPORT",/{flag=0}flag' $working_dir/$filename.CSV > $working_dir/$filename.processed.CSV

# Process the file part 2
# Remove the first 4 fields of the CSV file
mlr --csv cut -x -f "I,CO2EII,PUBLISHING,1" $working_dir/$filename.processed.CSV > $working_dir/$filename.final.CSV

# Upload the file to the database using the \copy command to insert these new values into the co2eii_available_generators table
# The table is truncated first to remove any old data as this is a new copy
psql -h 10.240.0.165 -U nem_worker -d nem <<EOF
SET TIME ZONE '+10';
START TRANSACTION;
TRUNCATE co2eii_available_generators;
\copy co2eii_available_generators FROM '$working_dir/$filename.final.CSV' DELIMITER ',' CSV HEADER
COMMIT;
EOF

# Cleanup
rm $working_dir/$filename.CSV -f
rm $working_dir/$filename.processed.CSV -f
rm $working_dir/$filename.final.CSV -f
