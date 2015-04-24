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
# Modified by Guilhem Marchand 15012015: AIX compatibility fix
# Modified by Guilhem Marchand 08022015: Improvements for Solaris (terminal detaching issue)
# Modified by Guilhem Marchand with the contribution of Flexible 10032015: nmon_cleaner.sh corrective hotfix (collision when nmon is in bin/)
# Modified by Guilhem Marchand 11032015: Migration of main var directory for Nmon App, PID writing step improvement
# Modified by Guilhem Marchand 04032015: Major rewrite of the script:
#													  - Linux improvement, analyse and return error code when launching nmon instance
#													  - Prevents from killing non Application related Nmon instances
#													  - Better management of PID identification and PID file verification
#													  - Moving pid file to $SPLUNK_HOME/var/run/nmon
# Modified by Guilhem Marchand 17042015: Linux maximum number of devices is now overcharged by nmon.conf 
# Modified by Guilhem Marchand 24042015: Solaris update, activate VxVM volumes statistics by nmon.conf, deactivate by default CPUnn statistics (useless in the App context)

# Version 1.2.08

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

# Var directory for data generation
APP_VAR=$SPLUNK_HOME/var/run/nmon

# Which type of OS are we running
UNAME=`uname`

# Nmon Binary
case $UNAME in

AIX )

# Use topas_nmon in priority

if [ -x /usr/bin/topas_nmon ]; then
	NMON="/usr/bin/topas_nmon"

else
	NMON=`which nmon 2>&1`

	if [ ! -x "$NMON" ]; then
		echo "`date`, ERROR, Nmon could not be found, cannot continue."
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
			echo "No nmon installed here"
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

	echo "`date`, ERROR, Unsupported system ! Nmon is available only for AIX / Linux / Solaris systems, please check and deactivate nmon data collect"
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
			echo "`date`, ERROR, nmon binary returned a non 0 code while trying to start, please verify error traces in splunkd log (missing shared libraries?)"
		fi
	;;

	SunOS )
		NMONNOSAFILE=1 # Do not generate useless sa files
		export NMONNOSAFILE
		NMONEXCLUDECPUN=1 # Do not generate CPUnn data, this reduces Nmon volume of data and isn't used in the App
		export NMONEXCLUDECPUN

		# Manage VxVM volume statistics activation
		if [ ${Solaris_VxVM} -eq 1 ]; then
			NMONVXVM=1
			export NMONVXVM
		fi

		${nmon_command} >/dev/null 2>&1 &
	;;

esac

}

# This small function takes a pid in arg and returns currently opened files associated with this pid

verify_pid() {

	givenpid=$1
	
	case $UNAME in
	
		AIX )
			procfiles -n $givenpid ;;
			
		Linux )

			if [ -x /usr/bin/lsof ]; then
			
				LSOF="/usr/bin/lsof"
			
			elif [ -x /sbin/lsof ]; then
			
				LSOF="/sbin/lsof"
				
			else
			
				LSOF=`which lsof 2>&1`
				
			fi
			$LSOF -p $givenpid ;;
		
		SunOS )
			/usr/proc/bin/pfiles $givenpid ;;
			
	esac

}

# Search for running process, ensure it is related to App, and write PID file
write_pid() {

PIDs=`ps -ef | grep ${NMON} | grep -v grep | grep -v nmon_helper.sh | awk '{print $2}'`

for p in ${PIDs}; do
			
	# Verify resources open by the process, if it matches the App directory kill it, else don't touch the process
	verify_pid $p | grep -v grep | grep ${APP_VAR} >/dev/null
					
	if [ $? -eq 0 ]; then
		echo $p > ${PIDFILE}
	fi					

done

}


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
		nmon_command="${NMON} -f -T -d ${Linux_devices} -N -s ${interval} -c ${snapshot}"
	else
		nmon_command="${NMON} -f -T -d ${Linux_devices} -s ${interval} -c ${snapshot}"
	fi
	;;

esac


# Initialize PID variable
PIDs="" 

# who am I
MYUSER=`whoami`

# Initialize nmon status
nmon_isstarted=0

# Check nmon binary exists and is executable
if [ ! -x ${NMON} ]; then
	
	echo "`date`, ERROR, could not find Nmon binary (${NMON}) or execution is unauthorized"
	exit 2
fi	

# Search for any running Nmon instance, stop it if exist and start it, start it if does not
cd ${NMON_REPOSITORY}
PIDs=`ps -ef | grep ${NMON} | grep -v grep | grep -v nmon_helper.sh | awk '{print $2}'`

case ${PIDs} in

	# CASE 1: Could not found any running Nmon instances
	
	"" )

		# In case for some reason the running nmon instance could not be identified, first verify pid from file if it exists
		if [ -f ${PIDFILE} ]; then
		
			SAVED_PID=`cat ${PIDFILE}`
			
			case ${SAVED_PID} in
			
			# CASE 1.1: Could not identify a running process, but a pid file exists
			
			"" )
				# CASE 1.1.1: PID file is empty
				
				# Set the nmon status (Needs to start)
				nmon_isstarted=1
				
				echo "`date`, removing stale pid file"
			;;
			* )

				# CASE 1.1.2: PID file is not empty, very the process is App related

				for p in ${SAVED_PID}; do
			
					# Verify resources opened by the process
					verify_pid $p | grep -v grep | grep ${APP_VAR} >/dev/null

					if [ $? -eq 0 ]; then
						echo "`date`, Nmon is running (PID ${p})"

						# CASE 1.1.2.1: OK, PID file is fine, process is running and App related, for some reason we did not correctly identified it

						# Set the nmon status (don't start)
						nmon_isstarted=0

					else

						# CASE 1.1.2.2: KO, Nmon needs to be started

						# Set the nmon status (start)
						nmon_isstarted=1
						
					fi		
				done			
			
			;;
			esac

		else
		
			# CASE 1.2: KO, No process running were found AND no pid file were found, remove the stale pid file and set the status to ask for nmon start
		
			# Set the nmon status (ask to start)
			nmon_isstarted=1
			
			echo "`date`, removing stale pid file"
			
		fi			

	;;

	# CASE 2: We found Nmon instances running, there may be multiple instances that are App related or not
	
	* )
		
		if [ -f ${PIDFILE} ]; then

			# CASE 2.1: Nmon instances running, found an existing pid file 
			
			SAVED_PID=`cat ${PIDFILE}`

			case $SAVED_PID in
			
			# CASE 2.1.1: Nmon instances running, but pid file is empty			
			
			"")
			
				# Set the nmon status (ask to start)
				nmon_isstarted=1
			
				echo "`date`, removing stale pid file"
			
				for p in ${PIDs}; do
				
					echo "`date`, Found Nmon instance running with PID ${p}, will verify if it is App related"

					if [ $? -eq 0 ]; then

							# CASE 2.1.1.1: Process is ours, running but orphan, kill it and save this information
					
							kill $p
							echo "`date`, Nmon PID (${p}) related to Nmon App did not matched pid file, instance with PID ${p} were softly killed"
					fi
				done
			
			;;
			
			# CASE 2.1.2: Nmon instances running, pid file not empty
			
			*)

				# for each process running, check if it matches the saved pid, if not, verify it matches an App related nmon instance and kill it
			
				for p in ${PIDs}; do
			
					if [ $p -eq ${SAVED_PID} ]; then
				
						# CASE 2.1.2.1, OK: Found an App related process AND it matches the PID file, save this information and set the Nmon status				
				
						echo "`date`, Nmon is running (PID ${p})"

						# Set the nmon status
						nmon_isstarted=0

					else
				
						# CASE 2.1.2.2, KO: Found a running Process that does not match the pid file, verify if it is App related, kill it if it does, don't touch if if doesn't

						verify_pid $p | grep -v grep | grep ${APP_VAR} >/dev/null

						echo "`date`, Found Nmon instance running with PID ${p}, will verify if it is App related"

						if [ $? -eq 0 ]; then

							# CASE 2.1.2.2.1: Process is ours, running but orphan, kill it and save this information
					
							kill $p
							echo "`date`, Nmon PID (${p}) related to Nmon App did not matched pid file, instance with PID ${p} were softly killed"
						fi
										
					fi
			
				done

			;;
			esac

		else
		
			# CASE 2.2: Nmon instances running but none could match the pid file as it does not exist, Set the nmon status, verify each process, if app related let's kill it, don't touch if does not
		
			# Set the nmon status
			nmon_isstarted=1		
		
			# Don't let App related Nmon instances running if it does not match pid file
			# If the nmon instance is not App related, don't touch it

			for p in ${PIDs}; do
		
				# Verify resources open by the process, if it matches the App directory kill it, else don't touch the process
				verify_pid $p | grep -v grep | grep ${APP_VAR} >/dev/null
					
				if [ $? -eq 0 ]; then
	
					# CASE 2.2.1: Process is ours and orphan, kill it				
				
					kill $p
					echo "`date`, Detected orphan Nmon PID (${p}) related to Nmon App, instance with PID ${p} were softly killed"
				fi
							
			done
			
		fi	
			
	;;
	esac

# Start Nmon if required

# nmon_is_started=0 --> Don't start
# nmon_is_started=1 --> start and save pid file

if [ $nmon_isstarted -eq 1 ]; then

	echo "`date`, starting nmon : ${nmon_command} in ${NMON_REPOSITORY}"
	start_nmon
	write_pid
	exit 0

fi

####################################################################
#############		End of Main Program 			############
####################################################################
