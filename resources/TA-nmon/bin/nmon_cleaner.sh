#!/bin/sh

# set -x

# Program name: nmon_cleaner.sh
# Purpose - Frontal script to nmon_cleaner.py and nmon_cleaner.pl, will launch Python or Perl script depending on interpreter availability
#				See nmon_cleaner.py | nmon_cleaner.pl
# Author - Guilhem Marchand
# Disclaimer:  this provided "as is".  
# Date - February 2015
# Guilhem Marchand 2015/02/08, initial version
# Guilhem Marchand 2015/03/03, correction for script calling execution

# Version 1.0.01

# For AIX / Linux / Solaris

#################################################
## 	Your Customizations Go Here            ##
#################################################

if [ -z "${SPLUNK_HOME}" ]; then
	echo "`date`, ERROR, SPLUNK_HOME variable is not defined"
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

####################################################################
#############		Main Program 			############
####################################################################

# Store arguments sent to script
userargs=$@

# Python is the default choice, if it is not available launch the Perl version
PYTHON=`which python` >/dev/null 2>&1

if [ $? -eq 0 ]; then

	$APP/bin/nmon_cleaner.py ${userargs}
	
else

	$APP/bin/nmon_cleaner.pl ${userargs}

fi

exit 0
