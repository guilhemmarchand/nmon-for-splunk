#!/bin/sh

# set -x

# Program name: purge_nmon_repository.sh
# Purpose - simple shell script to purge nmon repository
# Author - Guilhem Marchand
# Disclaimer:  this provided "as is".  
# Date - May 2014

# Version 1.1.2

# For AIX / Linux / Solaris

#################################################
## 	Your Customizations Go Here            ##
#################################################

# App directory definition
echo $SPLUNK_HOME|grep -q forwarder
case $? in

0 )
	APP=$SPLUNK_HOME/etc/apps/TA-nmon ;;
* )
	APP=$SPLUNK_HOME/etc/apps/nmon ;;

esac

if [ -d $SPLUNK_HOME/etc/slave-apps/_cluster ];then
        APP=$SPLUNK_HOME/etc/slave-apps/PA-nmon
fi


# Clean various dir
NMON_REPO=${APP}/var/nmon_repository
CONFIG_REPO=${APP}/var/config_repository
CSV_REPO=${APP}/var/csv_repository
SPOOL=${APP}/var/spool
TEMP=${APP}/var/nmon_temp


# mtime days used for purge, every nmon file older than X days will be purged
# Default to 1 day
mintime="1"


####################################################################
#############		Main Program 			############
####################################################################


# Check SPLUNK_HOME variable is defined, this should be the case when launched by Splunk scheduler
if [ -z ${SPLUNK_HOME} ]; then
	echo "`date`, ERROR, SPLUNK_HOME variable is not defined"
	exit 1
fi


for dir in ${NMON_REPO} ${SPOOL} ${TEMP}; do

	# Search for Nmon files to purge
	for file in `find ${dir} -name "*.nmon" -type f -mtime +${mintime} -print`; do

		echo "`date`, INFO, deleting ${file}"
		rm ${file}
	
	done
	#
done

for dir in ${CONFIG_REPO} ${CSV_REPO}; do

	# Search for Nmon files to purge
	for file in `find ${dir} -name "*.csv" -type f -mtime +${mintime} -print`; do

		echo "`date`, INFO, deleting ${file}"
		rm ${file}
	
	done
	#
done


exit 0
