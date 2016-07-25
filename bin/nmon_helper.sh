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
#										- New Linux system identification to be used with embedded nmon binaries
# 2015/05/14, Guilhem Marchand: 
#										- AIX improvements: If not running topas-nmon, identification may fail, use the splunktag for non topas-nmon instance 
#										- Linux Ubuntu update: added binaries support for older releases
# 2015/06/24, Guilhem Marchand:
#										- All OS: Code improvements to prevent launching multiple nmon instances
# 2015/06/28, Guilhem Marchand:
#										- hotfix for nmon instances duplication: To prevent trouble at Splunk startup at boot time, the nmon_helper.sh uses now the -p option for nmon (AIX, Linux)
#										to retrieve the pid of the launched nmon instance
# 2015/07/08, Guilhem Marchand:
#										- hotfix for nmon instances duplication: Some cases may still lead to multiplicative processes, code improvements will prevent this
#										- hotfix for SUSE Linux: typo error leads to fail identifying best binaries for SUSE clients
# 2015/07/27, Guilhem Marchand:
#										- hotfix for using the PA-nmon to generate Performance data in standalone indexers
# 2015/07/29, Guilhem Marchand:
#										- hotfix for AIX, non protected grep generates -p option to be duplicated and error message in splunkd
# 2015/08/09, Guilhem Marchand: Manage gaps in data due to the time required for nmon to collect data when the current iterations ends:
#										- Estimate time in epoch when the current iteration will end
#										- Start a new nmon process 4 minutes before the current ends to let the new process time to start collecting
#										- Duplicated events management is operated by nmon2csv converters
# 2015/10/14, Guilhem Marchand:         - Use $SPLUNK_HOME/var/run/nmon for temp directory instead of /tmp
#                                       - Removed deactivation of CPUnn for Solaris, Manage UARG Solaris collection (new with Sarmon 1.11)
# 2015/11/11, Guilhem Marchand:         - sarmon binaries are now stored in a dedicated directory under bin
# 2015/12/11, Guilhem Marchand:         - path changes introduced with release 1.3.11 can generates duplicated processes due to ps truncation limits
# 2015/12/29, Guilhem Marchand:         - Evolution to manage sh cluster deployment: prevents text file busy error during bundle publication by running binaries from var instead of app directory
# 2016/02/13, Guilhem Marchand:         - Error in SUSE Linux identification over /etc/SuSE-release (bad pattern)
# 2016/02/14, Guilhem Marchand:         - Support for Archlinux with embedded binaries (x86 & x86_64)
# 2016/04/12, Guilhem Marchand:         - centOS OS and version detection if no os-release available (https://github.com/guilhemmarchand/nmon-for-splunk/issues/31)
# 2016/04/16, Guilhem Marchand:         - Linux binaries management - cp alias on some systems prevents binaries cache upgrade to proceed #32
# 2016/04/23, Guilhem Marchand:         - Improve the PID file age determination by switching from Perl to Python command depending on interpreter available
# 2016/05/19, Guilhem Marchand:         - Fix some situation were the nmon bin in path could be ignored
# 2016/05/31, Guilhem Marchand:         - AIX: Collect in default SEA and WLM stats (-O and -W options)
# 2016/06/12, Guilhem Marchand:         - Linux: Managed unlimited capturation for processes and disks
# 2016/07/11, Guilhem Marchand:         - Linux: Manage the bytes order system to identify if running in big or little endian
# 2016/07/12, Guilhem Marchand:         - Store linux binaries in a tgz archive file that be uncompressed if required
# 2016/07/16, Guilhem Marchand:         - ARM support
# 2016/07/25, Guilhem Marchand:         - Prevent tar error on Solaris OS

# Version 1.3.22

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

elif [ -d "$SPLUNK_HOME/etc/apps/PA-nmon" ];then
        APP=$SPLUNK_HOME/etc/apps/PA-nmon

elif [ -d "$SPLUNK_HOME/etc/slave-apps/_cluster" ];then
        APP=$SPLUNK_HOME/etc/slave-apps/PA-nmon

else
        echo "`date`, ${HOST} ERROR, the APP directory could not be defined, is nmon / TA-nmon / PA-nmon installed ?"
        exit 1

fi

# Var directory for data generation
APP_VAR=$SPLUNK_HOME/var/run/nmon

# Create directory if not existing already
[ ! -d $APP_VAR ] && { mkdir -p $APP_VAR; }

# Which type of OS are we running
UNAME=`uname`

# Linux binaries are stored in the bin/linux.tgz archive file
# At first startup only, if the linux directory does not exist, extract the binaries archive file
case $UNAME in

Linux )

if [ ! -d ${APP}/bin/linux ]; then
    cd ${APP}/bin
    tar -xzpf linux.tgz
fi

;;
esac

# Silently update bin content to run directory (see after this)
# Note: on some systems, cp is an alias to cp -i which would prevent this from working as expected
update_var_bin () {
cd ${APP}/bin
case $UNAME in
    Linux )
    tar -xzpf linux.tgz ;;
esac
\cp -pf ${APP}/default/app.conf ${APP_VAR}/app.conf > /dev/null 2>&1
\cp -rpf ${APP}/bin ${APP_VAR}/ > /dev/null 2>&1
}
# Only relevant for Linux and Solaris, binaries caching management
case $UNAME in

Linux | SunOS )

# To prevents binaries overwrites during upgrades and sh cluster deployment issues, cache the bin directory
# Binaries will be launched from the cache directory
if [ -d ${APP_VAR}/bin ]; then

    # the bin directory has been already cached, verify if an update is required
    if [ -f ${APP_VAR}/app.conf ]; then

        diff ${APP}/default/app.conf ${APP_VAR}/app.conf >/dev/null

            # if return code does not equal to 0, update is required
            if [ $? -ne 0 ]; then
                update_var_bin
            fi

    else

        # no app.conf found, force copy of app.conf and update
        update_var_bin
    fi

else

    # the bin directory has not been cached already
    update_var_bin

fi

;;
esac

# set defaults values for interval and snapshot and source nmon.conf

### All these values are defaults values, and will be overcharged by default/nmon.conf and local/nmon.conf if they exists ###

# Refresh interval in seconds, Nmon will this value to refresh data each X seconds
# Default to 60 seconds
interval="60"
	
# Number of Data refresh snapshots, Nmon will refresh data X times
# Default to 120 snapshots
snapshot="120"

# AIX common options default, will be overwritten by nmon.conf (unless the file would not be available)
AIX_options="-f -T -A -d -K -L -M -P -O -W -S -^ -p"

# Linux max devices (-d option), default to 1500
Linux_devices="1500"

# Change the priority applied while looking at nmon binary
# by default, the nmon_helper.sh script will use any nmon binary found in PATH
# Set to "1" to give the priority to embedded nmon binaries
Linux_embedded_nmon_priority="0"

# Change the limit for processes and disks capture of nmon for Linux
# In default configuration, nmon will capture most of the process table by capturing main consuming processes
# You can set nmon to an unlimited number of processes to be captured, and the entire process table will be captured.
# Note this will affect the number of disk devices captured by setting it to an unlimited number.
# This will also increase the volume of data to be generated and may require more cpu overhead to process nmon data
# The default configuration uses the default mode (limited capture), you can set bellow the limit number of capture to unlimited mode
# Change to "1" to set capture of processes and disks to no limit mode
Linux_unlimited_capture="0"

# endtime_margin defines the time in seconds before a new nmon process will be started
# in default configuration, a new process will be spawned 240 seconds before the current process ends
# see nmon.conf (this value will be overwritten by nmon.conf)
endtime_margin="240"

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

##########
#	AIX	#
##########

AIX )

# Use topas_nmon in priority

if [ -x /usr/bin/topas_nmon ]; then
	NMON="/usr/bin/topas_nmon"
	AIX_topas_nmon="true"

else
	NMON=`which nmon 2>&1`

	if [ ! -x "$NMON" ]; then
		echo "`date`, ${HOST} ERROR, Nmon could not be found, cannot continue."
		exit 1
	fi
	AIX_topas_nmon="false"	

fi

;;

##########
#	Linux	#
##########

# Nmon App comes with most of nmon versions available from http://nmon.sourceforge.net/pmwiki.php?n=Site.Download

Linux )

case $Linux_embedded_nmon_priority in

0)

	# give priority to any nmon binary found in local PATH

	# Nmon BIN full path (including bin name), please update this value to reflect your Nmon installation
	which nmon >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		NMON=`which nmon`

	else

		NMON=""

	fi

;;

1)

	# give priority to embedded binaries
	# if none of embedded binaries can suit the local system, we will switch to local nmon binary, if it's available

	NMON=""

;;

esac

if [ ! -x "$NMON" ];then

	# No nmon found in env, so using prepackaged version

	# First, define the processor architecture, use the arch command in priority, fall back to uname -m if not available
	which arch >/dev/null 2>&1
	if [ $? -eq 0 ]; then

			ARCH=`arch`
			
	else
	
			ARCH=`uname -m`	
	
	fi
	
	# Let's convert some of architecture names to more conventional names, specially used by the nmon community to name binaries (not that ppc32 is more or less clear than power_32...)

	case $ARCH in
	
	i686 )
	
		ARCH_NAME="x86" ;; # x86 32 bits
		
	x86_64 )
	
		ARCH_NAME="x86_64" ;; # x86 64 bits
		
	ia64 )
	
		ARCH_NAME="ia64" ;; # Itanium 64 bits	
	
	ppp32 )
	
		ARCH_NAME="power_32" ;; # powerpc 32 bits
		
	ppp64 )
	
		ARCH_NAME="power_64" ;; # powerpc 64 bits	

	s390 )
	
		ARCH_NAME="mainframe_32" ;; # s390 32 bits mainframe	

	s390x )
	
		ARCH_NAME="mainframe_64" ;; # s390x 64 bits mainframe

    arm* )

        ARCH_NAME="arm" ;; # arm architecture
	
	esac

	### PowerLinux specific ###

	# On PowerLinux arch, some OS can run in Big Endian while most will run in Little Endian
    # On a Little Endian system, the following command will return "1" for a Little Endian arch

    # See this nice article: https://www.mainline.com/linux-on-power-to-be-or-not-to-be-why-should-i-care
    # And specifically "Ubuntu is LE only; SLES 11 is BE only; SLES 12 is LE only; RedHat 6.x is BE only; RedHat 7.1 has two distributions – one LE, the other BE"

    # For convenience, all powerLinux binaries are suffixed by "_le" or "_be"

    case $ARCH in

    ppp32 | ppp64 )

        # Assign default to Little Endian in case of failure
        BYTE_ORDER_STATUS="1"
        BYTE_ORDER="le"

        BYTE_ORDER_STATUS=`echo I | tr -d [:space:] | od -to2 | head -n1 | awk '{print $2}' | cut -c6`
        case ${BYTE_ORDER_STATUS} in

        0 )
        # Big Endian
            BYTE_ORDER="be" ;;

        # Little Endian
        1 )
            BYTE_ORDER="le" ;;

        esac

    ;;
    esac

	# Initialize linux_vendor
	linux_vendor=""
	linux_mainversion=""
	linux_subversion=""
	linux_fullversion=""
	
	# Try to find the better embedded binary depending on Linux version
	
	# Most modern Linux comes with an /etc/os-release, this is (from far) the better scenario for system identification
	
	OSRELEASE="/etc/os-release"	
	
	if [ -f $OSRELEASE ]; then

		# Great, let's try to find the better binary for that system
	
		linux_vendor=`grep '^ID=' $OSRELEASE | awk -F= '{print $2}' | sed 's/\"//g' | sed 's/ //g'`	# The Linux distribution
		linux_mainversion=`grep '^VERSION_ID=' $OSRELEASE | awk -F'"' '{print $2}' | awk -F'.' '{print $1}'`	# The main release (eg. rhel 7) 	
		linux_subversion=`grep '^VERSION_ID=' $OSRELEASE | awk -F'"' '{print $2}' | awk -F'.' '{print $2}'`	# The sub level release (eg. "1" from rhel 7.1)
		linux_fullversion=`grep '^VERSION_ID=' $OSRELEASE | awk -F'"' '{print $2}' | sed 's/\.//g'`	# Concatenated version of the release (eg. 71 for rhel 7.1)	

        case $ARCH in

        # PowerLinux
        ppp32 | ppp64 )

            # Manage Big / Little Endian arch
            case ${BYTE_ORDER} in

            # Big Endian
            0 )

                # Try the most accurate
                if [ -f $APP_VAR/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_fullversion}_be ]; then
                    NMON="$APP_VAR/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_fullversion}_be"

                # try the mainversion
                elif [ -f ${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}_be ]; then
                    NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}_be"

                # try the linux_vendor
                elif [ -f ${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}_be ]; then
                    NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}_be"

                fi

            ;;

            # Little Endian
            1 )

                # Try the most accurate
                if [ -f $APP_VAR/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_fullversion}_le ]; then
                    NMON="$APP_VAR/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_fullversion}_le"

                # try the mainversion
                elif [ -f ${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}_le ]; then
                    NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}_le"

                # try the linux_vendor
                elif [ -f ${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}_le ]; then
                    NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}_le"

                fi

            ;;

            esac

        ;;

        # All other arch
        *)

                # Try the most accurate
                if [ -f $APP_VAR/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_fullversion} ]; then
                    NMON="$APP_VAR/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_fullversion}"

                # try the mainversion
                elif [ -f ${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion} ]; then
                    NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}"

                # try the linux_vendor
                elif [ -f ${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor} ]; then
                    NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}"

                fi

        ;;

        esac


	# So bad, no os-release, probably old linux, things becomes a bit harder

	# centOS, OS and version detection
    elif [ -f /etc/centos-release ]; then

       for version in 5 6 7; do
           if grep "CentOS release $version" /etc/centos-release >/dev/null; then

               linux_vendor="centos"
               linux_mainversion="$version"
               NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}"

           fi

        done

    # rhel, OS and version detection
	elif [ -f /etc/redhat-release ]; then

        # Redhat has some version for PowerLinux that can be Little or Big endian

		for version in 4 5 6 7; do
	
			# search for rhel		
			if grep "Red Hat Enterprise Linux Server release $version" /etc/redhat-release >/dev/null; then
		
				linux_vendor="rhel"
				linux_mainversion="$version"

                case $ARCH in

                # PowerLinux
                ppp32 | ppp64 )

                    # Manage Big / Little Endian arch
                    case ${BYTE_ORDER} in

                    # Big endian
                    0 )
                        NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}_be"

				    ;;

				    # Little endian
				    1)
    				    NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}_le"
				    ;;

				    esac

				;;

				# Other arch
				* )
				    NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}"

                ;;

                esac

			fi
			
		done

	# Second chance for sles and opensuse, /etc/SuSE-release is deprecated and should be removed in future version
	elif [ -f /etc/SuSE-release ]; then
	
		# sles
		
		if grep "SUSE Linux Enterprise Server" /etc/SuSE-release >/dev/null; then
		
			linux_vendor="sles"
			# Get the main version only
			linux_mainversion=`grep 'VERSION =' /etc/SuSE-release | sed 's/ //g' | awk -F= '{print $2}' | awk -F. '{print $1}'`
            linux_subversion=`grep 'PATCHLEVEL =' /etc/SuSE-release | sed 's/ //g' | awk -F= '{print $2}' | awk -F. '{print $1}'`

            case $ARCH in

            # PowerLinux
            ppp32 | ppp64 )

                # Manage Big / Little Endian arch
                case ${BYTE_ORDER} in

                # Big endian
                0 )
                    NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}_be"

                ;;

                # Little endian
                1)
                    NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}_le"
                ;;

                esac

            ;;

            # Other arch
            * )
                NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}"

            ;;

            esac

		elif grep "openSUSE" /etc/SuSE-release >/dev/null; then
		
			linux_vendor="opensuse"
			# Get the main version only
			linux_mainversion=`grep 'VERSION =' /etc/SuSE-release | sed 's/ //g' | awk -F= '{print $2}' | awk -F. '{print $1}'`
            linux_subversion=`grep 'PATCHLEVEL =' /etc/SuSE-release | sed 's/ //g' | awk -F= '{print $2}' | awk -F. '{print $1}'`

            # try the most accurate
            if [ -f ${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}${linux_subversion} ]; then
                    NMON=" ${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}${linux_subversion}"
            else
                    NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}"
            fi

		fi
	
	elif [ -f /etc/issue ]; then

		# search for debian (note: starting debian 7, the /etc/os-release should be available)
		# This shall not be updated in the future as the /etc/os-release is now available by default

		if grep "Debian GNU/Linux" /etc/issue >/dev/null; then

			for version in 5 6 7; do
	
				if grep "Debian GNU/Linux $version" /etc/issue >/dev/null; then
		
					linux_vendor="debian"
					linux_mainversion="$version"
					NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}"

				fi
		
			done

        # Ubuntu is Little Endian only
		elif grep "Ubuntu" /etc/issue >/dev/null; then

			for version in 6 7 8 9 10 11 12 13 14 15; do
	
				if grep "Ubuntu $version" /etc/issue >/dev/null; then
		
					linux_vendor="ubuntu"
					linux_mainversion="$version"

                    case $ARCH in

                    # PowerLinux
                    ppp32 | ppp64 )

                        # Manage Big / Little Endian arch
                        case ${BYTE_ORDER} in

                        # Big endian
                        0 )
                            NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}_be"

                        ;;

                        # Little endian
                        1)
                            NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}_le"
                        ;;

                        esac

                    ;;

                    # Other arch
                    * )
                        NMON="${APP_VAR}/bin/linux/${linux_vendor}/nmon_${ARCH_NAME}_${linux_vendor}${linux_mainversion}"

                    ;;

                    esac

				fi
		
			done

		fi
		
	fi

	# Verify NMON is set and exists, if not, try falling back to generic builds

	case $NMON in
	
	"")
	
		# Look for local binary in PATH
		which nmon >/dev/null 2>&1
		
		if [ $? -eq 0 ]; then
			NMON=`which nmon 2>&1`
		else

            case $ARCH in

            # PowerLinux
            ppp32 | ppp64 )

                # Manage Big / Little Endian arch
                case ${BYTE_ORDER} in

                # Big endian
                0 )
                    NMON="${APP_VAR}/bin/linux/generic/nmon_linux_${ARCH}_be"

                ;;

                # Little endian
                1)
                    NMON="${APP_VAR}/bin/linux/generic/nmon_linux_${ARCH}_le"
                ;;

                esac

            ;;

            # Other arch
            * )
                NMON="${APP_VAR}/bin/linux/generic/nmon_linux_${ARCH}"

            ;;

            esac

		fi
    ;;

    *)
        if [ ! -x ${NMON} ]; then

            # Look for local binary in PATH
            which nmon >/dev/null 2>&1

            if [ $? -eq 0 ]; then
                    NMON=`which nmon 2>&1`
            fi

        fi

    ;;

	esac

	# Finally verify we have a binary that exists and is executable
	
	if [ ! -x ${NMON} ]; then

		if [ -x ${APP_VAR}/bin/linux/generic/nmon_linux_${ARCH} ]; then
		
			# Try switching to embedded generic

            case $ARCH in

            # PowerLinux
            ppp32 | ppp64 )

                # Manage Big / Little Endian arch
                case ${BYTE_ORDER} in

                # Big endian
                0 )
                    NMON="${APP_VAR}/bin/linux/generic/nmon_linux_${ARCH}_be"

                ;;

                # Little endian
                1)
                    NMON="${APP_VAR}/bin/linux/generic/nmon_linux_${ARCH}_le"
                ;;

                esac

            ;;

            # Other arch
            * )
                NMON="${APP_VAR}/bin/linux/generic/nmon_linux_${ARCH}"

            ;;

            esac

		else
			
			echo "`date`, ${HOST} ERROR, could not find an nmon binary suitable for this system, please install nmon manually and set it available in the user PATH"
			exit 1
			
		fi	
	
	fi

fi

;;

##########
#	SunOS	#
##########

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
		NMON="$APP_VAR/bin/sarmon_bin_sparc/sadc" ;;
	* )
		# arch is x86
		NMON="$APP_VAR/bin/sarmon_bin_i386/sadc" ;;
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

# For AIX / Linux, the -p option when launching nmon will output the instance pid in stdout

start_nmon () {

case $UNAME in

	AIX )
		${nmon_command} > ${PIDFILE}
	;;

	Linux )
		${nmon_command} > ${PIDFILE}
		if [ $? -ne 0 ]; then
			echo "`date`, ${HOST} ERROR, nmon binary returned a non 0 code while trying to start, please verify error traces in splunkd log (missing shared libraries?)"
		fi
	;;

	SunOS )
		NMONNOSAFILE=1 # Do not generate useless sa files
		export NMONNOSAFILE

		# Manage UARG activation, default is on (1)
		NMONUARG_VALUE=${Solaris_UARG}
		if [ ! -z ${NMONUARG_VALUE} ]; then

			if [ ${NMONUARG_VALUE} -eq 1 ]; then
			NMONUARG=1
			export NMONUARG
			fi

		fi

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

# Only SunOS will look for running processes to identify nmon instances
# AIX and Linux will save the pid at launch time

case $UNAME in 

	SunOS)

        # In main priority, use pgrep (no truncation trouble), pgrep should always be available
        # whether running on Solaris 10 or 11
        if [ -x /usr/bin/pgrep ]; then
            PIDs=`pgrep -f ${NMON}`
        # Second priority, use BSD ps command with the appropriated syntax (mainly for Solaris 10)
        elif [ -x /usr/ucb/ps ]; then
            PIDs=`/usr/ucb/ps auxww | grep ${NMON} | grep -v grep | grep -v nmon_helper.sh | awk '{print $2}'`
        # Last, use the ps command with BSD style syntax (no -) for Solaris 11 and later
        # Solaris 10 cannot use BSD syntax with native ps, hopefully previous options should have been found !
        else
            if grep 'Solaris 10' /etc/release >/dev/null; then
                PIDs=`/usr/ucb/ps -ef | grep sarmon | grep -v grep | grep -v nmon_helper.sh | awk '{print $2}'`
            else
                PIDs=`/usr/ucb/ps auxww | grep ${NMON} | grep -v grep | grep -v nmon_helper.sh | awk '{print $2}'`
            fi
        fi

		for p in ${PIDs}; do

			verify_pid $p | grep -v grep | grep ${APP_VAR} >/dev/null

			if [ $? -eq 0 ]; then
				echo ${PIDs} > ${PIDFILE}
			fi

		done
	;;		
		
	esac
			
}

# Just Search for running process
search_nmon_instances() {

case $UNAME in 

	Linux)

		PIDs=`ps -ef | grep ${NMON} | grep -v grep | grep -v nmon_helper.sh | awk '{print $2}'`
		
	;;
	
	SunOS)

		PIDs=`ps -ef | grep ${NMON} | grep -v grep | grep -v nmon_helper.sh | awk '{print $2}'`

		for p in ${PIDs}; do

			verify_pid $p | grep -v grep | grep ${APP_VAR} >/dev/null

		done
	;;		
		
	AIX)

		case ${AIX_topas_nmon} in
	
		true )	
			PIDs=`ps -ef | grep ${NMON} | grep -v grep | grep -v nmon_helper.sh | grep ${NMON_REPOSITORY} | awk '{print $2}'`
		;;
		
		false)
			PIDs=`ps -ef | grep ${NMON} | grep -v grep | grep -v nmon_helper.sh | awk '{print $2}'`
		;;
		
		esac

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

# For AIX, the default command options line "-f -T -A -d -K -L -M -P -O -W -S -^" includes: (see http://www-01.ibm.com/support/knowledgecenter/ssw_aix_61/com.ibm.aix.cmds4/nmon.htm)

# AIX options can be managed using local/nmon.conf, do not modify options here

# -A	Includes the Asynchronous I/O section in the view.
# -d	Includes the Disk Service Time section in the view.
# -K	Includes the RAW Kernel section and the LPAR section in the recording file. The -K flag dumps the raw numbers
# of the corresponding data structure. The memory dump is readable and can be used when the command is recording the data.
# -L	Includes the large page analysis section.
# -M	Includes the MEMPAGES section in the recording file. The MEMPAGES section displays detailed memory statistics per page size.
# -O    Includes the Shared Ethernet adapter (SEA) VIOS sections in the recording file.
# -W    Includes the WLM sections into the recording file.
# -S	Includes WLM sections with subclasses in the recording file.
# -P	Includes the Paging Space section in the recording file.
# -T	Includes the top processes in the output and saves the command-line arguments into the UARG section. You cannot specify the -t, -T, or -Y flags with each other.
# -^	Includes the Fiber Channel (FC) sections.
# -p  print pid in stdout

# For Linux, the default command options line "-f -T -d 1500" includes:

# -t	include top processes in the output
# -T	as -t plus saves command line arguments in UARG section
# -d <disks>    to increase the number of disks [default 256]
# -p  print pid in stdout

case $UNAME in

AIX )

	# -p option is mandatory to get the pid of the launched instances, ensure it has been set
	
	echo ${AIX_options} | grep '\-p' >/dev/null
	if [ $? -ne 0 ]; then
		AIX_options="${AIX_options} -p"
	fi

	case ${AIX_topas_nmon} in
	
	true )
	
		if [ ${AIX_NFS23} -eq 1 ]; then
			nmon_command="${NMON} ${AIX_options} -N -s ${interval} -c ${snapshot}"
		elif [ ${AIX_NFS4} -eq 1 ]; then
			nmon_command="${NMON} ${AIX_options} -NN -s ${interval} -c ${snapshot}"
		else
			nmon_command="${NMON} ${AIX_options} -s ${interval} -c ${snapshot}"
		fi
	;;
	
	false )
	
		if [ ${AIX_NFS23} -eq 1 ]; then
			nmon_command="${NMON} ${AIX_options} -N -s ${interval} -c ${snapshot}"
		elif [ ${AIX_NFS4} -eq 1 ]; then
			nmon_command="${NMON} ${AIX_options} -NN -s ${interval} -c ${snapshot}"
		else
			nmon_command="${NMON} ${AIX_options} -s ${interval} -c ${snapshot}"
		fi
	;;	
	
	esac	
	
;;

SunOS )
	nmon_command="${NMON} ${interval} ${snapshot}"
;;

Linux )

	if [ ${Linux_NFS} -eq 1 ]; then

        # Verify the limit configuration for processes and disks capture
	    if [ ${Linux_unlimited_capture} -eq 1 ]; then
	        nmon_command="${NMON} -f -T -N -s ${interval} -c ${snapshot} -I -1 -p"
        else
            nmon_command="${NMON} -f -T -d ${Linux_devices} -N -s ${interval} -c ${snapshot} -p"
        fi

	else

        # Verify the limit configuration for processes and disks capture
	    if [ ${Linux_unlimited_capture} -eq 1 ]; then
	        nmon_command="${NMON} -f -T -s ${interval} -c ${snapshot} -I -1 -p"
        else
		    nmon_command="${NMON} -f -T -d ${Linux_devices} -s ${interval} -c ${snapshot} -p"
        fi
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

	# PID file not found

	echo "`date`, ${HOST} INFO: Removing staled pid file"
	rm -f ${PIDFILE}
	
	# search for any App related instances
	search_nmon_instances

	case ${PIDs} in
	
	"")
	
		echo "`date`, ${HOST} INFO: starting nmon : ${nmon_command} in ${NMON_REPOSITORY}"
		start_nmon
		sleep 5 # Let nmon time to start
		write_pid
		exit 0
	;;
	
	*)

		echo "`date`, ${HOST} INFO: found Nmon running with PID ${PIDs}"
		# Retry to write pid file
		write_pid
		exit 0
	;;
	
	esac

else

	# PID file found

	SAVED_PID=`cat ${PIDFILE} | awk '{print $1}'`

	if [ ${endtime_margin} -gt 0 ]; then
	
		# Initialize PIDAGE to 01 Jan 2000 00:00:00 GMT for later failure verification
		EPOCHTEST="946684800"
		PIDAGE=$EPOCHTEST

        # Verify Perl availability (Perl will be more commonly available than Python)
        PERL=`which perl >/dev/null 2>&1`

        if [ $? -eq 0 ]; then

            # Use Perl to get PID file age in seconds
            perl -e "\$mtime=(stat(\"$PIDFILE\"))[9]; \$cur_time=time();  print \$cur_time - \$mtime;" > ${APP_VAR}/nmon_helper.sh.tmp.$$

        else

            # Use Python to get PID file age in seconds
            python -c "import os; import time; now = time.strftime(\"%s\"); print(int(int(now)-(os.path.getmtime('$PIDFILE'))))" > ${APP_VAR}/nmon_helper.sh.tmp.$$

        fi

		PIDAGE=`cat ${APP_VAR}/nmon_helper.sh.tmp.$$`
		rm ${APP_VAR}/nmon_helper.sh.tmp.$$

        case $PIDAGE in
        "")
                echo "`date`, ${HOST} WARN: failed to eval the age of the current pid file, gaps may occur between nmon processes run."
                PIDAGE=0
                ;;
        esac

		# Estimate the end time of current Nmon binary less 4 minutes (enough time for new nmon process to start collecting)
		# Use expr for portability with sh
		endtime=`expr ${interval} \* ${snapshot}`
		endtime=`expr ${endtime} - ${endtime_margin}`
	
	fi

	case ${SAVED_PID} in
	
	# PID file is empty
	"")

		echo "`date`, ${HOST} INFO: Removing staled pid file"
		rm -f ${PIDFILE}

		# search for any App related instances
		search_nmon_instances

		case ${PIDs} in
	
		"")

			echo "`date`, ${HOST} INFO: starting nmon : ${nmon_command} in ${NMON_REPOSITORY}"
			start_nmon
			sleep 5 # Let nmon time to start
			# Relevant for Solaris Only
			write_pid
			exit 0
		;;
	
		*)

			echo "`date`, ${HOST} INFO: found Nmon running with PID ${PIDs}"
			# Relevant for Solaris Only
			write_pid
			exit 0
		;;
	
		esac

	;;

	# PID file is not empty
	*)
	
	case $UNAME in

	Linux)
		if [ -d /proc/${SAVED_PID} ]; then
			istarted="true"
		else
			istarted="false"
		fi
		;;

	SunOS)
		verify_pid ${SAVED_PID} | grep -v grep | grep ${NMON_REPOSITORY} >/dev/null
		if [ $? -eq 0 ]; then
			istarted="true"
		else
			istarted="false"
		fi
		;;
				
	AIX)
	
		if [ -d /proc/${SAVED_PID} ]; then
			istarted="true"
		else
			istarted="false"
		fi
		;;		
		
	esac	

	case $istarted in
	
	"true")

		if [ ${endtime_margin} -gt 0 ]; then

			# If the current age of the Nmon process requires starting a new one to prevent data gaps between collections
			# Note that the pidfile will be overwritten, for a few minutes 2 Nmon binaries are running in the same time
			# Data duplication will be managed by nmon2csv files	
		
			# Prevent any failure in determining nmon process age
			if [ $PIDAGE -gt $EPOCHTEST ]; then
				echo "`date`, ${HOST} ERROR: Failed to determine age in seconds of current Nmon process, gaps may occur between Nmon collections"
		
			else		
				case $PIDAGE in
			
				"")
					echo "`date`, ${HOST} ERROR: Failed to determine age in seconds of current Nmon process, gaps may occur between Nmon collections"
				;;
				*)
					if [ $PIDAGE -gt $endtime ]; then
						echo "`date`, ${HOST} INFO: To prevent data gaps between 2 Nmon collections, a new process will be started, its PID will be available on next execution"
						start_nmon
						sleep 5 # Let nmon time to start
						# Relevant for Solaris Only		
						write_pid
					fi
				;;
				esac
			fi

			# Process found	
			echo "`date`, ${HOST} INFO: Nmon process is $PIDAGE sec old, a new process will be spawned when this value will be greater than estimated end in seconds ($endtime sec based on parameters)"
	
		fi

		echo "`date`, ${HOST} INFO: found Nmon running with PID ${SAVED_PID}"
		exit 0
		;;
		
	"false")
	
		# Process not found, Nmon has terminated or is not yet started		
		echo "`date`, ${HOST} INFO: Removing staled pid file"
		rm -f ${PIDFILE}

		echo "`date`, ${HOST} INFO: starting nmon : ${nmon_command} in ${NMON_REPOSITORY}"
		start_nmon
		sleep 5 # Let nmon time to start
		# Relevant for Solaris Only		
		write_pid
		exit 0
		;;
	
	esac
	
	;;
	
	esac

fi

####################################################################
#############		End of Main Program 			############
####################################################################
