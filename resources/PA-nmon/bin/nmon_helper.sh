#!/bin/sh

# set -x

# Program name: nmon_helper.sh
# Purpose - nmon sample script to start collecting data with a 1mn interval refresh
# Author - Guilhem Marchand
# Disclaimer:  this provided "as is".  
# Date - June 2014

# 2015/05/09, Guilhem Marchand: Rewrite of main program to fix main common troubles with nmon_helper.sh, be simple, effective
# 2015/05/11, Guilhem Marchand: 
#										- Hotfix, improved process identification (All OS)
#										- Improved AIX options management (AIX options can now fully be managed by nmon.conf, corrected NFS V4 options which was incorrectly verified)
# 2015/05/14, Guilhem Marchand: Linux and Solaris corrections and improvements
#										- Linux max default devices missing (in case of nmon.conf not being sourced)
#										- Use a splunktag for process identification for Linux and Solaris hosts

# Version 1.3.02

# For AIX / Linux / Solaris

#################################################
## 	Your Customizations Go Here            ##
#################################################

# hostname
HOST=`hostname`

if [ -z "${SPLUNK_HOME}" ]; then
	echo "`date`, ${HOST} ERROR, SPLUNK_HOME variable is not defined"
	exit 1
fi

# Splunk Home variable: This should automatically defined when this script is being launched by Splunk
# If you intend to run this script out of Splunk, please set your custom value here
SPL_HOME=${SPLUNK_HOME}

# Check SPL_HOME variable is defined, this should be the case when launched by Splunk scheduler
if [ -z "${SPL_HOME}" ]; then
	echo "`date`, ${HOST} ERROR, SPL_HOME (SPLUNK_HOME) variable is not defined"
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
        echo "`date`, ${HOST} ERROR, the APP directory could not be defined, is nmon / TA-nmon / PA-nmon installed ?"
        exit 1

fi

# Var directory for data generation
APP_VAR=$SPLUNK_HOME/var/run/nmon

# Which type of OS are we running
UNAME=`uname`

# set defaults values for interval and snapshot and source nmon.conf 

# Refresh interval in seconds, Nmon will this value to refresh data each X seconds
# Default to 60 seconds
interval="60"
	
# Number of Data refresh snapshots, Nmon will refresh data X times
# Default to 120 snapshots
snapshot="120"

# AIX common options default, will be overwritten by nmon.conf (unless the file would not be available)
AIX_options="-f -T -A -d -K -L -M -P -^"

# Linux max devices (-d option), default to 1500
Linux_devices="1500"

# source default nmon.conf
if [ -f $APP/default/nmon.conf ]; then
	. $APP/default/nmon.conf
fi

# source local nmon.conf, if any

# Search for a local nmon.conf file located in $SPLUNK_HOME/etc/apps/nmon|TA-nmon|PA-nmon/local

if [ -f $APP/local/nmon.conf ]; then
	. $APP/local/nmon.conf
fi

# Nmon Binary
case $UNAME in

AIX )

# Use topas_nmon in priority

if [ -x /usr/bin/topas_nmon ]; then
	NMON="/usr/bin/topas_nmon"

else
	NMON=`which nmon 2>&1`

	if [ ! -x "$NMON" ]; then
		echo "`date`, ${HOST} ERROR, Nmon could not be found, cannot continue."
		exit 1
	fi
fi

;;

Linux )

# Nmon BIN full path (including bin name), please update this value to reflect your Nmon installation
NMON=`which nmon 2>&1`
if [ ! -x "$NMON" ];then
	# No nmon found in env, so using prepackaged version
	case `uname` in 
		Linux)
			NMON="$APP/bin/nmon_`arch`_`uname|tr '[:upper:]' '[:lower:]'`"
			;;
		*)
			echo "`date`, ${HOST} ERROR, No nmon installed here"
			;;	
	esac
fi

;;

SunOS )

# Nmon BIN full path (including bin name), please update this value to reflect your Nmon installation
NMON=`which sadc 2>&1`
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

	echo "`date`, ${HOST} ERROR, Unsupported system ! Nmon is available only for AIX / Linux / Solaris systems, please check and deactivate nmon data collect"
	exit 2

;;

esac

# Nmon file final destination
# Default to nmon_repository of Nmon Splunk App
NMON_REPOSITORY=${APP_VAR}/var/nmon_repository
[ ! -d $NMON_REPOSITORY ] && { mkdir -p $NMON_REPOSITORY; }

#also needed - 
[ -d ${APP_VAR}/var/csv_repository ] || { mkdir -p ${APP_VAR}/var/csv_repository; }
[ -d ${APP_VAR}/var/config_repository ] || { mkdir -p ${APP_VAR}/var/config_repository; }

# Nmon PID file
PIDFILE=${APP_VAR}/nmon.pid

############################################
# functions
############################################

start_nmon () {

case $UNAME in

	AIX )
		${nmon_command} >/dev/null 2>&1
	;;

	Linux )
		${nmon_command}		
		if [ $? -ne 0 ]; then
			echo "`date`, ${HOST} ERROR, nmon binary returned a non 0 code while trying to start, please verify error traces in splunkd log (missing shared libraries?)"
		fi
	;;

	SunOS )
		NMONNOSAFILE=1 # Do not generate useless sa files
		export NMONNOSAFILE
		NMONEXCLUDECPUN=1 # Do not generate CPUnn data, this reduces Nmon volume of data and isn't used in the App
		export NMONEXCLUDECPUN

		# Manage VxVM volume statistics activation, default is off (0)
		NMONVXVM_VALUE=${Solaris_VxVM}
		if [ ! -z ${NMONVXVM_VALUE} ]; then
		
			if [ ${NMONVXVM_VALUE} -eq 1 ]; then
			NMONVXVM=1
			export NMONVXVM
			fi
			
		fi

		${nmon_command} >/dev/null 2>&1 &
	;;

esac

}

verify_pid() {

	givenpid=$1	

	# Verify proc fs before checking PID
	if [ -d /proc/${givenpid} ]; then
	
		case $UNAME in
	
			AIX )
			
				ps -ef | grep ${NMON} | grep -v grep | grep -v nmon_helper.sh | grep $givenpid ;;
		
			Linux )

				ps -ef | grep ${NMON} | grep -v grep | grep -v nmon_helper.sh | grep $givenpid ;;
				
			SunOS )
			
				/usr/bin/pwdx $givenpid ;;
							
		esac
		
	else
	
		# Just return nothing		
		echo ""
		
	fi

}

# Search for running process and write PID file
write_pid() {

case $UNAME in 

	Linux)

		PIDs=`ps -ef | grep ${NMON} | grep -v grep | grep -v nmon_helper.sh | grep splunktag | awk '{print $2}'`
		
		if [ $? -eq 0 ]; then
			echo ${PIDs} > ${PIDFILE}
		fi

	;;
	
	SunOS)

		PIDs=`ps -ef | grep ${NMON} | grep -v grep | grep -v nmon_helper.sh | awk '{print $2}'`

		for p in ${PIDs}; do

			verify_pid $p | grep -v grep | grep ${APP_VAR} >/dev/null

			if [ $? -eq 0 ]; then
				echo ${PIDs} > ${PIDFILE}
			fi

		done
	;;		
		
	AIX)
	
		PIDs=`ps -ef | grep ${NMON} | grep -v grep | grep -v nmon_helper.sh | grep ${NMON_REPOSITORY} | awk '{print $2}'`
		
		if [ $? -eq 0 ]; then
			echo ${PIDs} > ${PIDFILE}
		fi

	;;
			
	esac
			
}


############################################
# Defaults values for interval and snapshot
############################################

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

# AIX options can be managed using local/nmon.conf, do not modify options here

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

case $UNAME in

AIX )

	if [ ${AIX_NFS23} -eq 1 ]; then
		nmon_command="${NMON} ${AIX_options} -N -s ${interval} -c ${snapshot}"
	elif [ ${AIX_NFS4} -eq 1 ]; then
		nmon_command="${NMON} ${AIX_options} -NN -s ${interval} -c ${snapshot}"
	else
		nmon_command="${NMON} ${AIX_options} -s ${interval} -c ${snapshot}"
	fi
	;;

SunOS )
	nmon_command="${NMON} ${interval} ${snapshot}"
	;;

Linux )

	if [ ${Linux_NFS} -eq 1 ]; then
		nmon_command="${NMON} -f -T -d ${Linux_devices} -N -s ${interval} -c ${snapshot} splunktag"
	else
		nmon_command="${NMON} -f -T -d ${Linux_devices} -s ${interval} -c ${snapshot} splunktag"
	fi
	;;

esac


# Initialize PID variable
PIDs="" 

# Initialize nmon status
nmon_isstarted=0

# Check nmon binary exists and is executable
if [ ! -x ${NMON} ]; then
	
	echo "`date`, ${HOST} ERROR, could not find Nmon binary (${NMON}) or execution is unauthorized"
	exit 2
fi	

# cd to root dir
cd ${NMON_REPOSITORY}

# Check PID file, if no PID file is found, start nmon
if [ ! -f ${PIDFILE} ]; then

	echo "`date`, ${HOST} INFO: Removing staled pid file"
	rm -f ${PIDFILE}
	
	echo "`date`, ${HOST} INFO: starting nmon : ${nmon_command} in ${NMON_REPOSITORY}"
	start_nmon
	sleep 5 # Let nmon time to start
	write_pid
	exit 0

else

	# No PID file

	SAVED_PID=`cat ${PIDFILE} | awk '{print $1}'`

	case ${SAVED_PID} in
	
	# PID file is empty
	"")

	echo "`date`, ${HOST} INFO: Removing staled pid file"
	rm -f ${PIDFILE}

	echo "`date`, ${HOST} INFO: starting nmon : ${nmon_command} in ${NMON_REPOSITORY}"
	start_nmon
	sleep 5 # Let nmon time to start
	write_pid
	exit 0
	
	;;

	*)
	
	case $UNAME in

	Linux)
		ps -ef | grep ${NMON} | grep -v grep | grep -v nmon_helper.sh | grep splunktag | awk '{print $2}' | grep ${SAVED_PID} >/dev/null ;;

	SunOS)
		verify_pid ${SAVED_PID} | grep -v grep | grep ${NMON_REPOSITORY} >/dev/null ;;
				
	AIX)
		ps -ef | grep ${NMON} | grep -v grep | grep -v nmon_helper.sh | grep ${NMON_REPOSITORY} | awk '{print $2}' | grep ${SAVED_PID} >/dev/null ;;

	esac	
	
	if [ $? -eq 0 ]; then
		# Process found	
		echo "`date`, ${HOST} INFO: found Nmon running with PID ${SAVED_PID}"
		exit 0
	
	else	
	
		# Process not found, Nmon has terminated or is not yet started
		
		echo "`date`, ${HOST} INFO: Removing staled pid file"
		rm -f ${PIDFILE}

		echo "`date`, ${HOST} INFO: starting nmon : ${nmon_command} in ${NMON_REPOSITORY}"
		start_nmon
		sleep 5 # Let nmon time to start
		write_pid
		exit 0
	
	fi	
	
	;;
	
	esac

fi

####################################################################
#############		End of Main Program 			############
####################################################################
