#!/bin/sh

# set -x

# Program name: nmon_cleaner.sh
# Purpose - clean empty csv files that Splunk could let untouched within repositories
# Author - Guilhem Marchand
# Disclaimer:  this provided "as is".  
# Date - July 2014

# Version 1.0.0


#################################################
## 	Your Customizations Go Here            ##
#################################################

if [ -z "${SPLUNK_HOME}" ]; then
	echo "`date`, ERROR, SPLUNK_HOME variable is not defined"
	exit 1
fi

# Splunk Home variable: This should automatically defined when this script is being launched by Splunk
# If you intend to run this script out of Splunk, please set your custom value here
SPL_HOME=${SPLUNK_HOME}

# Check SPL_HOME variable is defined, this should be the case when launched by Splunk scheduler
if [ -z "${SPL_HOME}" ]; then
	echo "`date`, ERROR, SPL_HOME (SPLUNK_HOME) variable is not defined"
	exit 1
fi

echo $SPLUNK_HOME|grep forwarder >/dev/null
case $? in

0 )
	APP=$SPLUNK_HOME/etc/apps/TA-nmon ;;
* )
	APP=$SPLUNK_HOME/etc/apps/nmon ;;

esac

if [ -d "$SPLUNK_HOME/etc/slave-apps/_cluster" ];then
        APP=$SPLUNK_HOME/etc/slave-apps/PA-nmon
fi

# csv repository

REPO=${APP}/var/csv_repository

####################################################################
#############		Main Program 			############
####################################################################


# Clean any empty file (eg. csv files with only the csv header)

# count

count=0

for file in `ls ${REPO}/*.csv >/dev/null 2>&1`; do

	line_nbr=`wc -l $file | awk '{print $1}'`

	case $line_nbr in

		0)	
			rm -f ${file}
			count=`expr $count + 1`
		;;

	esac

done

echo "`date`, INFO, ${count} files with empty body were found and deleted in ${REPO}"

exit 0
