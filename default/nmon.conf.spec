# nmon.conf.spec

# This file contains possibles attributes and values you can use to configure nmon processes generation.

# There is an nmon.conf in $SPLUNK_HOME/etc/[nmon|TA-nmon|PA-nmon]/default/.  To set custom configurations,
# place an nmon.conf in $SPLUNK_HOME/etc/[nmon|TA-nmon|PA-nmon]/default/.

# *** FILE ENCODING: UTF-8 ! ***
# When creating a local/nmon.conf, pay attention to file encoding specially when working under Windows.
# The file must be UTF-8 encoded or you may run in trouble.

# *** DON'T MODIFY THIS FILE ***

########################################################################################################################
### NMON COLLECT OPTIONS ###
########################################################################################################################

# The nmon_helper.sh input script is set by default to run every 60 seconds
# If Nmon is not running, the script will start Nmon using the configuration above

# The default mode for Nmon data generation is set to "longperiod_low" which is the most preservative mode to limit the CPU usage due the Nmon/Splunk processing steps
# Feel free to test available modes or custom mode to set better options that answer your needs and requirements

# The "longperiod_high" mode is a good compromise between accuracy, CPU / licensing cost and operational intelligence, and should relevant for very large deployment in Production environments

# Available modes for proposal bellow:

#	shortperiod_low)
#			interval="60"
#			snapshot="10"

#	shortperiod_middle)
#			interval="30"
#			snapshot="20"

#	shortperiod_high)
#			interval="20"
#			snapshot="30"

#	longperiod_low)
#			interval="240"
#			snapshot="120"

#	longperiod_middle)
#			interval="120"
#			snapshot="120"

#	longperiod_high)
#			interval="60"
#			snapshot="120"

# Benchmarking of January 2015 with Version 1.5.0 shows that:

# longperiod_middle --> CPU usage starts to notably increase after 4 hours of Nmon runtime


# custom --> Set a custom interval and snapshot value, if unset short default values will be used (see custom_interval and custom_snapshot)

# Default is longperiod_high
mode=<string>

# Refresh interval in seconds, Nmon will this value to refresh data each X seconds
# UNUSED IF NOT SET TO custom MODE
custom_interval=<value>

# Number of Data refresh occurrences, Nmon will refresh data X times
# UNUSED IF NOT SET TO custom MODE
custom_snapshot=<value>

########################################################################################################################
### VARIOUS COMMON OPTIONS ###
########################################################################################################################

# Time in seconds of margin before running a new iteration of Nmon process to prevent data gaps between 2 iterations of Nmon
# the nmon_helper.sh script will spawn a new Nmon process when the age in seconds of the current process gets higher than this value

# The endtime is evaluated the following way:
# endtime=$(( ${interval} * ${snapshot} - ${endtime_margin} ))

# When the endtime gets higher than the endtime_margin, a new Nmon process will be spawned
# default value to 240 seconds which will start a new process 4 minutes before the current process ends

# Setting this value to "0" will totally disable this feature

# Default value:
# endtime_margin="240"

endtime_margin=<value>

### NFS OPTIONS ###

# Change to "1" to activate NFS V2 / V3 (option -N) for AIX hosts
# Default value:
# AIX_NFS23="0"

AIX_NFS23=<string>

# Change to "1" to activate NFS V4 (option -NN) for AIX hosts
# Default value:
# AIX_NFS4="0"

AIX_NFS4=<string>

# Change to "1" to activate NFS V2 / V3 / V4 (option -N) for Linux hosts
# Note: Some versions of Nmon introduced a bug that makes Nmon to core when activating NFS, ensure your version is not outdated
# Default value:
# Linux_NFS="0"

Linux_NFS=<string>

########################################################################################################################
### LINUX OPTIONS ###
########################################################################################################################

# Change the priority applied while looking at nmon binary
# by default, the nmon_helper.sh script will use any nmon binary found in PATH
# Set to "1" to give the priority to embedded nmon binaries
# Note: Since release 1.6.07, priority is given by default to embedded binaries

# Default value:
# Linux_embedded_nmon_priority="1"

Linux_embedded_nmon_priority=<string>

# Change the limit for processes and disks capture of nmon for Linux
# In default configuration, nmon will capture most of the process table by capturing main consuming processes
# You can set nmon to an unlimited number of processes to be captured, and the entire process table will be captured.
# Note this will affect the number of disk devices captured by setting it to an unlimited number.
# This will also increase the volume of data to be generated and may require more cpu overhead to process nmon data
# The default configuration uses the default mode (limited capture), you can set bellow the limit number of capture to unlimited mode
# Change to "1" to set capture of processes and disks to no limit mode
Linux_unlimited_capture="0"

# Set the maximum number of devices collected by Nmon, default is set to 1500 devices
# Increase this value if you have systems with more devices
# Up to 3000 devices will be taken in charge by the Application (hard limit in nmon2csv.py / nmon2csv.pl)

# Default value:
# Linux_devices="1500"

Linux_devices=<value>

########################################################################################################################
### SOLARIS OPTIONS ###
########################################################################################################################

# Change to "1" to activate VxVM volumes IO statistics
# Default value:

# Solaris_VxVM="0"

Solaris_VxVM=<string>

# UARG collection (new in Version 1.11), Change to "0" to deactivate, "1" to activate (default is activate)
# Default value:

# Solaris_UARG="1"

Solaris_UARG=<string>

########################################################################################################################
### AIX OPTIONS ###
########################################################################################################################

# Change this line if you add or remove common options for AIX, do not change NFS options here (see NFS options)
# the -p option is mandatory as it is used at launch time to save instance pid

# Default value:
# AIX_options="-f -T -A -d -K -L -M -P -^ -p"

AIX_options=<string>