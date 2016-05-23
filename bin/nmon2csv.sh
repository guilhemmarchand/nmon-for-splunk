#!/bin/sh

# set -x

# Program name: nmon2csv.sh
# Purpose - Frontal script to nmon2csv, will launch Python or Perl script depending on interpreter availability
#				See nmon2csv.py | nmon2csv.pl
# Author - Guilhem Marchand
# Disclaimer:  this provided "as is".  
# Date - February 2015
# Guilhem Marchand 2015/07/07, initial version
# - 07/27/2015, V1.0.01: Guilhem Marchand:
#                                         - hotfix for using the PA-nmon to generate Performance data in standalone indexers
# - 09/29/2015, V1.0.02: Guilhem Marchand:
#                                         - Restrict to Python 2.7.x to use nmon2csv.py
# - 10/14/2015, V1.0.03: Guilhem Marchand:
#                                         - Use $SPLUNK_HOME/var/run/nmon for temp directory instead of /tmp
# - 10/28/2015, V1.0.04: Guilhem Marchand:
#                                         - Fixed temp directory lacking creation if dir does not yet exist
# - 01/15/2016, V1.0.05: Guilhem Marchand:
#                                         - Send arguments from sh wrapper to nmon2csv parsers
# - 02/08/2016, V1.0.06: Guilhem Marchand:
#                                         - /dev/null redirection improvement for the which python check


# Version 1.0.06

# For AIX / Linux / Solaris

#################################################
## 	Your Customizations Go Here            ##
#################################################

if [ -z "${SPLUNK_HOME}" ]; then
	echo "`date`, ERROR, SPLUNK_HOME variable is not defined"
	exit 1
fi

# Set tmp directory
APP_VAR=${SPLUNK_HOME}/var/run/nmon

# Verify it exists
if [ ! -d ${APP_VAR} ]; then
    mkdir -p ${APP_VAR}
	exit 1
fi

# silently remove tmp file (testing exists before rm seems to cause trouble on some old OS)
rm -f ${APP_VAR}/nmon2csv.temp.*

# Set nmon_temp
nmon_temp=${APP_VAR}/nmon2csv.temp.$$

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

####################################################################
#############		Main Program 			############
####################################################################

# Store arguments sent to script
userargs=$@

# Store stdin
while read line ; do
	echo "$line" >> ${nmon_temp}
done

# Python is the default choice, if it is not available launch the Perl version
PYTHON=`which python >/dev/null 2>&1`

if [ $? -eq 0 ]; then

	# Check Python version, nmon2csv.py compatibility starts with Python version 2.6.6
	python_subversion=`python --version 2>&1`

	case $python_subversion in
	
	*" 2.7"*)
		cat ${nmon_temp} | ${SPLUNK_HOME}/bin/splunk cmd ${APP}/bin/nmon2csv.py ${userargs} ;;
		
	*)
		cat ${nmon_temp} | ${SPLUNK_HOME}/bin/splunk cmd ${APP}/bin/nmon2csv.pl ${userargs} ;;
	
	esac

else

	cat ${nmon_temp} | ${SPLUNK_HOME}/bin/splunk cmd ${APP}/bin/nmon2csv.pl

fi

# Remove temp
rm -f ${nmon_temp}

exit 0