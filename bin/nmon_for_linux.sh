#!/bin/sh

# set -x

# Program name: nmon_start_for_linux.sh
# Purpose - nmon sample script to start collecting data with a 1mn interval refresh
# Author - Guilhem Marchand
# Disclaimer:  this provided "as is".  
# Date - April 2014

#################################################
## 	Your Customizations Go Here            ##
#################################################

# Nmon BIN full path (including bin name), please update this value to reflect your Nmon installation
NMON="/usr/bin/nmon"

# Splunk Home variable: This should automatically defined when this script is being launched by Splunk
# If you intend to run this script out of Splunk, please set your custom value here
SPL_HOME=${SPLUNK_HOME}

# Nmon working directory, Nmon will produce the nmon csv file here
# Default to spool directory of Nmon Splunk App
WORKDIR=${SPL_HOME}/etc/apps/nmon/var/nmon_temp

# Nmon file final destination
# Default to nmon_repository of Nmon Splunk App
NMON_REPOSITORY=${SPL_HOME}/etc/apps/nmon/var/nmon_repository

# Refresh interval in seconds, Nmon will this value to refresh data each X seconds
# Default to 30 seconds
interval="30"

# Number of Data refresh occurences, Nmon will refresh data X times
# Default to 3
occurence="3"

####################################################################
#############		Main Program 			############
####################################################################

# Set Nmon command line
nmon_command="${NMON} -ft -s ${interval} -c ${occurence}"

# Initialize PID variable
PIDs="" 

# Check SPLUNK_HOME variable is defined, this should be the case when launched by Splunk scheduler
if [ -z ${SPL_HOME} ]; then

	echo "`date`, ERROR, SPL_HOME (SPLUNK_HOME) variable is not defined"
	exit 1
fi

# Check nmon binary exists and is executable
if [ ! -x ${NMON} ]; then
	
	echo "`date`, ERROR, could not find Nmon binary (${NMON}) or execution is unauthorized"
	exit 2
fi	

# Search for any running Nmon instance, stop it if exist and start it, start it if does not
cd ${WORKDIR}
PIDs=$(ps -ef| grep "${nmon_command}" | grep -v grep |awk '{print $2}')

case ${PIDs} in

	"" )
	
	 mv *.nmon ${NMON_REPOSITORY}/ >/dev/null
		
    # Start NMON
    ${nmon_command} ;;
	
	* )
	
	# Soft kill
	kill ${PIDs}
	sleep 2
	
	mv *.nmon ${NMON_REPOSITORY}/ >/dev/null	
	
	# Start Nmon
	${nmon_command} ;;
	
esac
