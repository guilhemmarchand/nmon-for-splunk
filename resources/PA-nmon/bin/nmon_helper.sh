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
# Modified by Guilhem Marchand 25082014: Avoid deleting existing nmon files in nmon_repository, this is now taken in charge by Splunk itself using batch mode instead monitor mode
#													  This prevents from having local nmon data missing when indexing large volume of nmon files from central shares
# Modified by Guilhem Marchand 26102014: Improved APP dir definition (are we running nmon / TA-nmon / PA-nmon)
# Modified by Guilhem Marchand 22122014: Modification of default values for interval and snapshot, added override features by default and local nmon.conf, kill evolution for TA upgrade management

# Version 1.2.0

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

# Defined which APP we are running from (nmon / TA-nmon / PA-nmon)
if [ -d "$SPLUNK_HOME/etc/apps/nmon" ]; then
        APP=$SPLUNK_HOME/etc/apps/nmon

elif [ -d "$SPLUNK_HOME/etc/apps/TA-nmon" ]; then
        APP=$SPLUNK_HOME/etc/apps/TA-nmon

elif [ -d "$SPLUNK_HOME/etc/slave-apps/_cluster" ];then
        APP=$SPLUNK_HOME/etc/slave-apps/PA-nmon

else
        echo "`date`, ERROR, the APP directory could not be defined, is nmon / TA-nmon / PA-nmon installed ?"
        exit 1

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

# Nmon file final destination
# Default to nmon_repository of Nmon Splunk App
NMON_REPOSITORY=${APP}/var/nmon_repository
[ ! -d $NMON_REPOSITORY ] && { mkdir -p $NMON_REPOSITORY; }

#also needed - 
[ -d ${APP}/var/csv_repository ] || { mkdir -p ${APP}/var/csv_repository; }
[ -d ${APP}/var/config_repository ] || { mkdir -p ${APP}/var/config_repository; }

# Nmon PID file
PIDFILE=/tmp/nmon.pid

############################################
# Defaults values for interval and snapshot
############################################

# In first option, search for a local nmon.conf file located in $SPLUNK_HOME/etc/apps/nmon|TA-nmon|PA-nmon/local

if [ -f $APP/local/nmon.conf ]; then
	. $APP/local/nmon.conf

# In second option, search for the main nmon.conf file located in $SPLUNK_HOME/etc/apps/nmon|TA-nmon|PA-nmon/default

elif [ -f $APP/default/nmon.conf ]; then
	. $APP/default/nmon.conf

else

	# if none of above options worked for some unexpected reasons, use these values

	# Refresh interval in seconds, Nmon will this value to refresh data each X seconds
	# Default to 240 seconds
	interval="240"
	
	# Number of Data refresh snapshots, Nmon will refresh data X times
	# Default to 340 snapshots to provide a full day data measure
	snapshot="340"

fi

# Set interval and snapshot values depending on mode of collect

case $mode in

	shortperiod_low)
			interval="60"
			snapshot="10"
	;;
	
	shortperiod_middle)
			interval="30"
			snapshot="20"
	;;
	
	shortperiod_high)
			interval="20"
			snapshot="30"
	;;		

	longperiod_low)
			interval="240"
			snapshot="120"
	;;

	longperiod_middle)
			interval="120"
			snapshot="120"
	;;

	longperiod_high)
			interval="60"
			snapshot="120"
	;;

	custom)
			interval=${custom_interval}
			snapshot=${custom_snapshot}
	;;

esac	

####################################################################
#############		Main Program 			############
####################################################################

# Set Nmon command line
# NOTE: 

# Collecting NFS Statistics:

# --> Since Nmon App Version 1.5.0, NFS activation can be controlled by the nmon.conf file in default/local directories

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
# -^	Includes the Fiber Channel (FC) sections.

# For Linux, the default command options line "-f -T -d 1500" includes:

# -t	include top processes in the output
# -T	as -t plus saves command line arguments in UARG section
# -d <disks>    to increase the number of disks [default 256]

case `uname` in

AIX )

	if [ ${AIX_NFS23} -eq 1 ]; then
		nmon_command="${NMON} -f -T -A -d -K -L -M -P -^ -N -s ${interval} -c ${snapshot}"
	elif [ ${AIX_NFS23} -eq 1 ]; then
		nmon_command="${NMON} -f -T -A -d -K -L -M -P -^ -NN -s ${interval} -c ${snapshot}"
	else
		nmon_command="${NMON} -f -T -A -d -K -L -M -P -^ -s ${interval} -c ${snapshot}"
	fi
	;;

SunOS )
	nmon_command="${NMON} ${interval} ${snapshot}" 
	;;

Linux )

	if [ ${Linux_NFS} -eq 1 ]; then
		nmon_command="${NMON} -f -T -d 1500 -N -s ${interval} -c ${snapshot}"
	else
		nmon_command="${NMON} -f -T -d 1500 -s ${interval} -c ${snapshot}"
	fi
	;;

esac


# Initialize PID variable
PIDs="" 

# who am I
MYUSER=`whoami`

# Check nmon binary exists and is executable
if [ ! -x ${NMON} ]; then
	
	echo "`date`, ERROR, could not find Nmon binary (${NMON}) or execution is unauthorized"
	exit 2
fi	

# Search for any running Nmon instance, stop it if exist and start it, start it if does not
cd ${NMON_REPOSITORY}
PIDs=`ps -ef | grep ${NMON} | grep ${MYUSER} | grep -v grep | awk '{print $2}'`

case ${PIDs} in

	"" )
    	# Start NMON
		echo "`date`, starting nmon : ${nmon_command} in ${NMON_REPOSITORY}"
		${nmon_command} >/dev/null 2>&1
		ps -ef | grep "${nmon_command}" | grep -v grep | awk '{print $2}' > ${PIDFILE}
		exit 0
	;;
	
	* )
		# Nmon is running, verify we have at least one nmon file in nmon repository
		# In case of a TA upgraded by the deployment server, the var directory will have been deleted but nmon binary will still be alive with no where to write to
		# In such as case, we need to kill nmon then relaunch it
		# The following count using find is compatible with any *nix OS		
		nbr_files=`find .  \(  -name . -o -prune \) -name "*.nmon" -type f -exec ls -l {} \; | wc -l`
		
		case ${nbr_files} in

		0)
			# Soft kill
			kill ${PIDs}
			echo "`date`, Detected orphan nmon instance(s) running (probably TA-nmon upgrade), instance(s) with PID(s) ${PIDs} were killed"
			echo "starting nmon : ${nmon_command} in ${NMON_REPOSITORY}"
			${nmon_command} >/dev/null 2>&1
			ps -ef | grep "${nmon_command}" | grep -v grep | awk '{print $2}' > ${PIDFILE}
			exit 0
			;;
			
		*)
			# Don't allow multiple execution of Nmon
			NBR_PIDs=`echo ${PIDs} | wc -l`
			
			if [ ${NBR_PIDs} -gt 1 ]; then

				kill ${PIDs}				
				echo "`date`, Detected multiple nmon instances running, instances with PIDs ${PIDs} were killed"				
				echo "starting nmon : ${nmon_command} in ${NMON_REPOSITORY}"
				${nmon_command} >/dev/null 2>&1
				ps -ef | grep "${nmon_command}" | grep -v grep | awk '{print $2}' > ${PIDFILE}
				exit 0
			fi		
		
		
		
			# Nmon is running, ensure current PID matches the saved PID
			if [ -f ${PIDFILE} ]; then
			
				SAVED_PID=`cat ${PIDFILE}`
				
				echo ${PIDs} | grep ${SAVED_PID}	>/dev/null 2>&1
				
				case $? in
				0)
					echo "`date`, Nmon is running (PID ${PIDs})"	
				;;
				*)
					kill ${PIDs}
					echo "`date`, Nmon PID (${PIDs}) did not matched pid file, instance(s) with PID(s) ${PIDs} were killed"
					echo "starting nmon : ${nmon_command} in ${NMON_REPOSITORY}"
					${nmon_command} >/dev/null 2>&1
					ps -ef | grep "${nmon_command}" | grep -v grep | awk '{print $2}' > ${PIDFILE}
					exit 0
				;;
				
				esac
				
			else
				kill ${PIDs}
				echo "`date`, Nmon PID (${PIDs}) did not matched pid file, instance(s) with PID(s) ${PIDs} were killed"
				echo "starting nmon : ${nmon_command} in ${NMON_REPOSITORY}"
				${nmon_command} >/dev/null 2>&1
				ps -ef | grep "${nmon_command}" | grep -v grep | awk '{print $2}' > ${PIDFILE}
				exit 0
			
			fi			
			
			;;
		esac
		
	;;
	
esac
