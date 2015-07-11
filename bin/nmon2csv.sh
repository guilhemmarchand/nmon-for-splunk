#!/bin/sh

# set -x

# Program name: nmon2csv.sh
# Purpose - Frontal script to nmon2csv, will launch Python or Perl script depending on interpreter availability
#				See nmon2csv.py | nmon2csv.pl
# Author - Guilhem Marchand
# Disclaimer:  this provided "as is".  
# Date - February 2015
# Guilhem Marchand 2015/07/07, initial version

# Version 1.0.0

# For AIX / Linux / Solaris

#################################################
## 	Your Customizations Go Here            ##
#################################################

if [ -z "${SPLUNK_HOME}" ]; then
	echo "`date`, ERROR, SPLUNK_HOME variable is not defined"
	exit 1
fi

# tmp directory for data storing
TMP_VAR=${SPLUNK_HOME}/var/run/nmon/tmp

if [ ! -d ${TMP_VAR} ]; then
	mkdir -p ${TMP_VAR}
fi

# silently remove tmp file (testing exists before rm seems to cause trouble on some old OS)
rm -f ${TMP_VAR}/stdin.nmon

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

####################################################################
#############		Main Program 			############
####################################################################

# Store stdin
while read line ; do
	echo "$line" >> ${TMP_VAR}/stdin.nmon
done

# Python is the default choice, if it is not available launch the Perl version
PYTHON=`which python` >/dev/null 2>&1

if [ $? -eq 0 ]; then

	# Check Python version, nmon2csv.py compatibility starts with Python version 2.6.6
	python_subversion=`python --version 2>&1`

	case $python_subversion in
	
	*" 2.6.6"* | *" 2.6.7"* | *" 2.6.8"* | *" 2.6.9"* | *" 2.7"*)
		cat ${TMP_VAR}/stdin.nmon | ${SPLUNK_HOME}/bin/splunk cmd ${APP}/bin/nmon2csv.py ;;
		
	*)
		cat ${TMP_VAR}/stdin.nmon | ${SPLUNK_HOME}/bin/splunk cmd ${APP}/bin/nmon2csv.pl	
	
	esac

else

	cat ${TMP_VAR}/stdin.nmon | ${SPLUNK_HOME}/bin/splunk cmd ${APP}/bin/nmon2csv.pl

fi

# Empty file
> ${TMP_VAR}/stdin.nmon

exit 0