#!/bin/sh

# set -x

# Program name: nmon_helper.sh
# Purpose - nmon sample script to start collecting data with a 1mn interval refresh
# Author - Guilhem Marchand
# Disclaimer:  this provided "as is".  
# Date - June 2014
# Modified for AIX by Barak Griffis 03052014
# Unified for Solaris/Linux/AIX by Barak Griffis 03072014
# Modified for Solaris by Guilhem Marchand 20072014

# Version 1.1.8

# For AIX / Linux / Solaris


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


# Nmon Binary

case `uname` in

AIX | Linux )

# Nmon BIN full path (including bin name), please update this value to reflect your Nmon installation
NMON=`which nmon` >/dev/null 2>&1
if [ ! -x "$NMON" ];then
	# No nmon found in env, so using prepackaged version
	case `uname` in 
		Linux)
			NMON="$APP/bin/nmon_`arch`_`uname|tr '[:upper:]' '[:lower:]'`"
			;;
		*)
			echo "No nmon installed here"
			;;	
	esac
fi

;;

SunOS )

# Nmon BIN full path (including bin name), please update this value to reflect your Nmon installation
NMON=`which sadc` >/dev/null 2>&1
if [ ! -x "$NMON" ];then

	# No nmon found in env, so using prepackaged version
	sun_arch=`uname -a`
	
	echo ${sun_arch} | grep sparc >/dev/null
	case $? in
	0 )
		# arch is sparc
		NMON="$APP/bin/sarmon_bin_sparc/sadc" ;;
	* )
		# arch is x86
		NMON="$APP/bin/sarmon_bin_i386/sadc" ;;
	esac

fi

;;

esac

# Nmon working directory, Nmon will produce the nmon csv file here
# Default to spool directory of Nmon Splunk App
WORKDIR=${APP}/var/nmon_temp
[ ! -d $WORKDIR ] && { mkdir -p $WORKDIR; }

# Nmon file final destination
# Default to nmon_repository of Nmon Splunk App
NMON_REPOSITORY=${APP}/var/nmon_repository
[ ! -d $NMON_REPOSITORY ] && { mkdir -p $NMON_REPOSITORY; }

#also needed - 
[ -d ${APP}/var/csv_repository ] || { mkdir -p ${APP}/var/csv_repository; }
[ -d ${APP}/var/config_repository ] || { mkdir -p ${APP}/var/config_repository; }

# Refresh interval in seconds, Nmon will this value to refresh data each X seconds
# Default to 10 seconds
interval="10"

# Number of Data refresh occurences, Nmon will refresh data X times
# Default to 6 occurences to provide 1 minute data measure
occurence="6"

####################################################################
#############		Main Program 			############
####################################################################

# Clean nmon_repository
rm $NMON_REPOSITORY/*.nmon >/dev/null 2>&1

# Set Nmon command line
case `uname` in

AIX )
	nmon_command="${NMON} -ft -s ${interval} -c ${occurence}" ;;

SunOS )
	nmon_command="${NMON} ${interval} ${occurence}" ;;

Linux )
	nmon_command="${NMON} -ft -s ${interval} -c ${occurence}" ;;

esac


# Initialize PID variable
PIDs="" 


# Check nmon binary exists and is executable
if [ ! -x ${NMON} ]; then
	
	echo "`date`, ERROR, could not find Nmon binary (${NMON}) or execution is unauthorized"
	exit 2
fi	

# Search for any running Nmon instance, stop it if exist and start it, start it if does not
cd ${WORKDIR}
PIDs=`ps -ef| grep "${nmon_command}" | grep -v grep |grep splunk| awk '{print $2}'`

case ${PIDs} in

	"" )
    	# Start NMON
		mv *.nmon ${NMON_REPOSITORY}/ >/dev/null 2>&1
		echo "starting nmon : ${nmon_command} in ${WORKDIR}"
		${nmon_command} >/dev/null 2>&1
	;;
	
	* )
		# Soft kill
		kill ${PIDs}
	
		mv *.nmon ${NMON_REPOSITORY}/ >/dev/null 2>&1
		# Start Nmon
		echo "starting nmon : ${nmon_command} in ${WORKDIR}"
		${nmon_command} >/dev/null 2>&1
	;;
	
esac
