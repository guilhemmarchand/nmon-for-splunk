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
# - 05/15/2016, V1.0.07: Guilhem Marchand:
#                                         - CPU overhead optimization: Reduce data sent to parsers to optimize overall
#                                           processing costs

# Version 1.0.07

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
rm -f ${APP_VAR}/nmon2csv.sh.temp.*

# Remove old nmon2csv.sh files
find ${APP_VAR} -name "nmon2csv.sh.*" -type f -mtime +7 -exec rm -f {} \;

# Set nmon_temp
nmon_temp=${APP_VAR}/nmon2csv.sh.temp.$$

# Set nmon_final
nmon_final=${APP_VAR}/nmon2csv.sh.temp.final.$$

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

# Which type of OS are we running
UNAME=`uname`

####################################################################
#############		Main Program 			############
####################################################################

# Store arguments sent to script
userargs=$@

# Store stdin
while read line ; do
	echo "$line" >> ${nmon_temp}
done

#####################
# Identify NMON data
#####################

# For optimisation purposes, only GNU grep can stop on first match
case $UNAME in

Linux)
    # Search hostname
    HOST=`grep -m 1 'AAA,host' ${nmon_temp} | awk -F, '{print $3}'`
    # SN: Only AIX hosts report a serial number
    SN=${HOST}
    # set date
    DATE=`grep -m 1 'AAA,date' ${nmon_temp} | awk -F, '{print $3}'`
    # set time
    TIME=`grep -m 1 'AAA,time' ${nmon_temp} | awk -F, '{print $3}'`
;;
SunOS)
    # Search hostname
    HOST=`grep 'AAA,host' ${nmon_temp} | awk -F, '{print $3}'`
    # SN: Only AIX hosts report a serial number
    SN=${HOST}
    # set date
    DATE=`grep 'AAA,date' ${nmon_temp} | awk -F, '{print $3}'`
    # set time
    TIME=`grep 'AAA,time' ${nmon_temp} | awk -F, '{print $3}'`
;;
AIX)
    # Search hostname
    HOST=`grep 'AAA,host' ${nmon_temp} | awk -F, '{print $3}'`
    # SN: Only AIX hosts report a serial number
    SN=`grep 'AAA,SerialNumber' ${nmon_temp} | awk -F, '{print $3}'`
    case ${SN} in
    "")
        SN=${HOST}
    esac
    # set date
    DATE=`grep 'AAA,date' ${nmon_temp} | awk -F, '{print $3}'`
    # set time
    TIME=`grep 'AAA,time' ${nmon_temp} | awk -F, '{print $3}'`
;;
esac

# If the host can't be extracted, the nmon data may not be ready
case ${HOST} in
"")
    exit 0 ;;
esac

# Set partial Nmon ID
NMON_SHORTID="${HOST}_${SN}_${DATE}_${TIME}"

# Set nmon2csv id file
nmon_id=${APP_VAR}/nmon2csv.sh.id.${NMON_SHORTID}.txt

# Remember previous and current number of lines
nmon_curr=${APP_VAR}/nmon2csv.sh.current.${NMON_SHORTID}.txt
nmon_new=${APP_VAR}/nmon2csv.sh.new.${NMON_SHORTID}.txt

# Parsers output
nmon_parser_output=${APP_VAR}/nmon2csv.sh.parser_output.txt

# set nb lines in data
NB_LN=`wc -l ${nmon_temp} | awk '{print $1}'`
echo $NB_LN > ${nmon_new}

# Set long Nmon ID
NMON_LONGID="${HOST}_${SN}_${DATE}_${TIME}_${NB_LN}"

# Initialize MUST_RUN
MUST_RUN="0"

# Known number of lines for this nmon data
if [ ! -f ${nmon_curr} ]; then
    echo "0" > ${nmon_curr}
fi

# START
if [ -f ${nmon_id} ]; then

    grep "${NMON_SHORTID}" ${nmon_id} >/dev/null

    # This nmon file has been already proceeded, but it may have been update since the last time we saw it.
    if [ $? -eq 0 ]; then

        # If config data has not yet been stored (but it should!), store it
        egrep '^AAA|BBB' ${nmon_temp} > ${nmon_final}

        # Has the nmon file been updated ?
        grep "${NMON_LONGID}" ${nmon_id} >/dev/null

        if [ $? -ne 0 ]; then

            # File updated since last read
            MUST_RUN="1"

            # Previous processing number of lines
            case $UNAME in
            AIX | Linux )
                PREV_NB_LN=`tail -n 1 ${nmon_id} | awk -F_ '{print $5}'` ;;
            SunOS )
                PREV_NB_LN=`tail +2 ${nmon_id} | awk -F_ '{print $5}'` ;;
            esac

            # Store IDs
            echo ${NMON_SHORTID} > ${nmon_id}
            echo ${NMON_LONGID} >> ${nmon_id}
            # Store previous umber of lines
            echo ${PREV_NB_LN} > ${nmon_curr}
            # find headers
            egrep -v 'AAA|BBB|T0+' ${nmon_temp} >> ${nmon_final}
            # Send data
            case $UNAME in
            AIX | Linux )

                nmon_curr_nb_ln=`cat ${nmon_curr}`
                first_ln_in_data=`tail -n +${nmon_curr_nb_ln} ${nmon_temp} | egrep -E 'T[0-9]{4,}' | head -1`
                last_ln_in_data=`tail -n +${nmon_curr_nb_ln} ${nmon_temp} | egrep -E 'T[0-9]{4,}' | tail -1`

                echo ${first_ln_in_data} | egrep -E "^(TOP|UARG)" >/dev/null
                if [ $? -eq 0 ]; then
                    first_time_in_data=`echo ${first_ln_in_data} | awk -F, '{print $3}' | sed 's/T//g'`
                else
                    first_time_in_data=`echo ${first_ln_in_data} | awk -F, '{print $2}' | sed 's/T//g'`
                fi

                echo ${last_ln_in_data} | egrep -E "^(TOP|UARG)" >/dev/null
                if [ $? -eq 0 ]; then
                    last_time_in_data=`echo ${last_ln_in_data} | awk -F, '{print $3}' | sed 's/T//g'`
                else
                    last_time_in_data=`echo ${last_ln_in_data} | awk -F, '{print $2}' | sed 's/T//g'`
                fi

                # always keep the first timestamp in data
                egrep -E "^ZZZZ,T" ${nmon_temp} | head -1 >> ${nmon_final}

                # Extract only required timestamps
                x=${first_time_in_data}
                while [ $x -ge ${first_time_in_data} ]; do

                    tail -n +${nmon_curr_nb_ln} ${nmon_temp} | egrep -E "^ZZZZ,T[0-9]{0,}${x}" >> ${nmon_final}
                    # increment
                    x=`expr $x + 1`

                    if [ $x -gt ${last_time_in_data} ]; then
                        break
                    fi

                done

                # Extract raw data
                tail -n +${PREV_NB_LN} ${nmon_temp} | egrep -E 'T[0-9]{4,}' >> ${nmon_final}

                ;;
            SunOS )

                nmon_curr_nb_ln=`cat ${nmon_curr}`
                first_ln_in_data=`tail +${nmon_curr_nb_ln} ${nmon_temp} | egrep -e 'T[0-9]{4,}' | head -1`
                last_ln_in_data=`tail +${nmon_curr_nb_ln} ${nmon_temp} | egrep -e 'T[0-9]{4,}' | tail -1`

                echo ${first_ln_in_data} | egrep -e "^(TOP|UARG)" >/dev/null
                if [ $? -eq 0 ]; then
                    first_time_in_data=`echo ${first_ln_in_data} | awk -F, '{print $3}' | sed 's/T//g'`
                else
                    first_time_in_data=`echo ${first_ln_in_data} | awk -F, '{print $2}' | sed 's/T//g'`
                fi

                echo ${last_ln_in_data} | egrep -e "^(TOP|UARG)" >/dev/null
                if [ $? -eq 0 ]; then
                    last_time_in_data=`echo ${last_ln_in_data} | awk -F, '{print $3}' | sed 's/T//g'`
                else
                    last_time_in_data=`echo ${last_ln_in_data} | awk -F, '{print $2}' | sed 's/T//g'`
                fi

                # always keep the first timestamp in data
                egrep -e "^ZZZZ,T" ${nmon_temp} | head -1 >> ${nmon_final}

                # Extract only required timestamps
                x=${first_time_in_data}

                while [ $x -ge ${first_time_in_data} ]; do

                    tail +${nmon_curr_nb_ln} ${nmon_temp} | egrep -e "^ZZZZ,T[0-9]{0,}${x}" >> ${nmon_final}
                    # increment
                    x=`expr $x + 1`

                    if [ $x -gt ${last_time_in_data} ]; then
                        break
                    fi

                done

                tail +${PREV_NB_LN} ${nmon_temp} >> ${nmon_final} ;;
            esac
        fi

    # This nmon file is unknown

    else

        # Send all data
        mv ${nmon_temp} ${nmon_final}
        # Store IDs
        echo ${NMON_SHORTID} > ${nmon_id}
        echo ${NMON_LONGID} >> ${nmon_id}

        # Must run
        MUST_RUN="1"

    fi

# First time we start or unknown file
else

        # Send all data
        mv ${nmon_temp} ${nmon_final}
        # Store IDs
        echo ${NMON_SHORTID} > ${nmon_id}
        echo ${NMON_LONGID} >> ${nmon_id}

        # Must run
        MUST_RUN="1"

fi

case ${MUST_RUN} in

1)

    # Python is the default choice, if it is not available launch the Perl version
    PYTHON=`which python >/dev/null 2>&1`

    if [ $? -eq 0 ]; then

        # Check Python version, nmon2csv.py compatibility starts with Python version 2.6.6
        python_subversion=`python --version 2>&1`

        case $python_subversion in

        *" 2.7"*)
            cat ${nmon_final} | ${SPLUNK_HOME}/bin/splunk cmd ${APP}/bin/nmon2csv.py ${userargs} | tee ${nmon_parser_output} ;;

        *)
            cat ${nmon_final} | ${SPLUNK_HOME}/bin/splunk cmd ${APP}/bin/nmon2csv.pl ${userargs} | tee ${nmon_parser_output} ;;

        esac

    else

        cat ${nmon_final} | ${SPLUNK_HOME}/bin/splunk cmd ${APP}/bin/nmon2csv.pl > ${nmon_parser_output}

    fi

    # Remove temp
    rm -f ${APP_VAR}/nmon2csv.sh.temp.*

    ;;

0)
    cat ${nmon_parser_output}
    exit 0
    ;;

esac

