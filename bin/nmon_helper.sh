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
# Modified for Mac OS x by Guilhem Marchand 24072014: Prevent Mac OS X users to launch the nmon_helper.sh, this is useless (no nmon for BSD*) and causes splunkd to crash
# Modified by Guilhem Marchand 20082014: Linux: Increased the number of disks to 1500 devices - AIX: Updated nmon command options

# Version 1.1.10

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

* )

	echo "`date`, ERROR, Unsupported system ! Nmon is available only for AIX / Linux / Solaris systems, please check and deactivate nmon data collect"
	exit 2

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
# NOTE: 

# Collecting NFS Statistics:
# - Linux: Add the "-N" option if you want to extract NFS Statistics (NFS V2/V3/V4)
# - AIX: Add the "-N" option for NFS V2/V3, "-NN" for NFS V4

# For AIX, the default command options line "-f -T -A -d -K -L -M -P -^" includes: (see http://www-01.ibm.com/support/knowledgecenter/ssw_aix_61/com.ibm.aix.cmds4/nmon.htm)

# -A	Includes the Asynchronous I/O section in the view.
# -d	Includes the Disk Service Time section in the view.
# -K	Includes the RAW Kernel section and the LPAR section in the recording file. The -K flag dumps the raw numbers
# of the corresponding data structure. The memory dump is readable and can be used when the command is recording the data.
# -L	Includes the large page analysis section.
# -M	Includes the MEMPAGES section in the recording file. The MEMPAGES section displays detailed memory statistics per page size.
# -P	Includes the Paging Space section in the recording file.
# -T	Includes the top processes in the output and saves the command-line arguments into the UARG section. You cannot specify the -t, -T, or -Y flags with each other.
# -^	Includes the Fibre Channel (FC) sections.

# For Linux, the default command options line "-f -T -d 1500" includes:

# -t	include top processes in the output
# -T	as -t plus saves command line arguments in UARG section
# -d <disks>    to increase the number of disks [default 256]

case `uname` in

AIX )
	nmon_command="${NMON} -f -T -A -d -K -L -M -P -^ -s ${interval} -c ${occurence}" ;;

SunOS )
	nmon_command="${NMON} ${interval} ${occurence}" ;;

Linux )
	nmon_command="${NMON} -f -T -d 1500 -s ${interval} -c ${occurence}" ;;

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
