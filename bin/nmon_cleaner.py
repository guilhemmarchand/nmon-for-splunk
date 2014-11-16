#!/usr/bin/python

# Program name: nmon_cleaner.py
# Compatibility: Python 2.7
# Purpose - Clean csv files when retention expires, tuned for the Coke Company
# Author - Guilhem Marchand
# Date of first publication - November 2014

# Releases Notes:

# - November 2014, V1.0.0: Guilhem Marchand, Initial version

# Load libs

from __future__ import print_function

import sys
import os
import glob
import time
import logging
import platform
import re
import argparse

# Converter version
version = '1.0.0'

# LOGGING INFORMATION:
# - The program uses the standard logging Python module to display important messages in Splunk logs
# - Every message of the script will be indexed and accessible within Splunk splunkd logs

#################################################
##      Functions
#################################################

# Disallow negative value in parser

def check_negative(value):
    ivalue = int(value)
    if ivalue < 0:
        raise argparse.ArgumentTypeError("%s is an invalid positive int value" % value)
    return ivalue

#################################################
##      Arguments Parser
#################################################

# Define Arguments
parser = argparse.ArgumentParser()

parser.add_argument('--maxseconds', action='store', dest='MAXSECONDS', type=check_negative,
                    help='Remove files older than x seconds')

parser.add_argument('--approot', action='store', dest='APP',
                    help='Set the root directory name of Nmon Application')

parser.add_argument('--csvrepo', action='store', dest='CSV_REPOSITORY',
                    help='Set the directory name for CSV Repository (default: csv_repository)')

parser.add_argument('--configrepo', action='store', dest='CONFIG_REPOSITORY',
                    help='Set the directory name for Config Repository (default: config_repository)')

parser.add_argument('--version', action='version', version='%(prog)s ' + version)

args = parser.parse_args()

#################################################
##      Variables
#################################################

# Set logging format
logging.root
logging.root.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(levelname)s %(message)s')
handler = logging.StreamHandler()
handler.setFormatter(formatter)
logging.root.addHandler(handler)

# Current date
now = time.strftime("%c")

# Set maxseconds
maxseconds = args.MAXSECONDS

# If the root directory App is no defined, use empty value (will be set later)
if not args.APP:
    APP = ''
else:
    APP = args.APP

# If the csv_repository is not defined, apply default 'csv_repository' value
if not args.CSV_REPOSITORY:
    csv_repository = "csv_repository"
else:
    csv_repository = args.CSV_REPOSITORY

# If the config_repository is not defined, apply default 'config_repository' value
if not args.CONFIG_REPOSITORY:
    config_repository = "config_repository"
else:
    config_repository = args.CONFIG_REPOSITORY

# Guest Operation System type
ostype = platform.system().lower()

# If running Windows OS (used for directory identification)
is_windows = re.match(r'^win\w+', (platform.system().lower()))

# Python version
python_version = platform.python_version()

# Verify SPLUNK_HOME environment variable is available, the script is expected to be launched by Splunk which
#  will set this for debugging or manual run, please set this variable manually
try:
    os.environ["SPLUNK_HOME"]
except KeyError:
    logging.error('The environment variable SPLUNK_HOME could not be verified, if you want to run this script '
                  'manually you need to export it before processing')
    sys.exit(1)

# SPLUNK_HOME environment variable
SPLUNK_HOME = os.environ['SPLUNK_HOME']

# Set APP root directory
if not APP:

    # APP Directories for standard nmon, TA-nmon, PA-nmon
    if is_windows:
        NMON_APP = SPLUNK_HOME + '\\etc\\apps\\nmon'
    else:
        NMON_APP = SPLUNK_HOME + '/etc/apps/nmon'

    if is_windows:
        TA_NMON_APP = SPLUNK_HOME + '\\etc\\apps\\TA-nmon'
    else:
        TA_NMON_APP = SPLUNK_HOME + '/etc/apps/TA-nmon'

    if is_windows:
        PA_NMON_APP = SPLUNK_HOME + '\\etc\\slave-apps\\PA-nmon'
    else:
        PA_NMON_APP = SPLUNK_HOME + '/etc/slave-apps/PA-nmon'

    # Verify APP exist
    if os.path.exists(NMON_APP):
        APP = NMON_APP
    elif os.path.exists(TA_NMON_APP):
        APP = TA_NMON_APP
    elif os.path.exists(PA_NMON_APP):
        APP = PA_NMON_APP
    else:
        msg = 'The Application root directory could not be found, is nmon / TA-nmon / PA-nmon installed ? We tried: '\
              + str(NMON_APP) + ' ' + str(TA_NMON_APP) + ' ' + str(PA_NMON_APP)
        logging.error(msg)
        sys.exit(1)

else:

    if is_windows:
        NMON_APP = SPLUNK_HOME + '\\etc\\apps\\' + APP
    else:
        NMON_APP = SPLUNK_HOME + '/etc/apps/' + APP

    # Verify APP exist
    if os.path.exists(NMON_APP):
        APP = NMON_APP
    else:
        msg = 'The Application root directory could not be found, is nmon / TA-nmon / PA-nmon installed ? We tried: '\
              + str(NMON_APP)
        logging.error(msg)
        sys.exit(1)

# APP_VAR directory
if is_windows:
    APP_VAR = APP + '\\var'
else:
    APP_VAR = APP + '/var'
if not os.path.exists(APP_VAR):
    os.mkdir(APP_VAR)

# Perf data csv repository
CSV_DIR = APP_VAR + '/' + csv_repository

# Perf data csv repository
CONFIG_DIR = APP_VAR + '/' + config_repository

# List of directories to be proceeded
WORKING_DIR = {CSV_DIR, CONFIG_DIR}

# Verify directory exist
for DIR in WORKING_DIR:
    if not os.path.exists(DIR):
        msg = 'The Application Data directory ' + DIR + ' could not be found, We tried: ' + str(DIR)
        logging.error(msg)
        sys.exit(1)

# Starting time of process
start_time = time.time()

####################################################################
#############           Main Program
####################################################################

# Check Arguments
if len(sys.argv) < 1:
    print ("\n%s" % os.path.basename(sys.argv[0]))
    print ("\nFiles cleaner:\n")
    print ("- run the script with the argument --maxseconds x where x will be the file retention in seconds")
    print ("Any csv file older than x days will be definitively removed")
    sys.exit(0)

if maxseconds is None:
    logging.error('No retention value were provided, please run with --help for more information')
    sys.exit(1)

# Show current time
msg = now + "Starting File cleaning"
print (msg)

# Display some basic information about us
msg = "Splunk Root Directory ($SPLUNK_HOME): " + str(SPLUNK_HOME) + " nmon_cleaner version: " + str(version) \
      + " Python version: " + str(python_version)
print (msg)

# Proceed

for DIR in WORKING_DIR:

    # cd to directory
    os.chdir(DIR)

    # Verify we have data to manage
    counter = len(glob.glob1(DIR, "*.csv"))

    # print (counter)

    if counter == 0:
        msg = 'No csv files found in directory: ' + str(DIR) + ', no action required.'
        print (msg)

    else:

        # cd to directory
        os.chdir(DIR)

        # counter of files with retention expired
        counter_expired = 0

        curtime = time.time()
        limit = maxseconds

        for xfile in glob.glob('*.csv'):

            filemtime = os.path.getmtime(xfile)

            if curtime - filemtime > limit:

                counter_expired += 1

                size_mb = os.path.getsize(xfile)/1000.0/1000.0
                size_mb = format(size_mb, '.2f')

                mtime = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(filemtime))  # Human readable datetime

                msg = 'Max set retention of ' + str(maxseconds) + ' seconds expired for file: ' + xfile + ' size(MB): '\
                      + str(size_mb) + ' mtime: ' + str(mtime)
                print (msg)

                os.remove(xfile)  # Permanently remove the file!

        if counter_expired == 0:
            msg = 'No file(s) found with retention expired in directory: ' + DIR + ', no action required'
            print (msg)

        else:

            msg = str(counter_expired) + ' files were permanently removed due to retention expired for directory ' + DIR
            print (msg)

###################
# End
###################

# Time required to process
end_time = time.time()
result = "Elapsed time was: %g seconds" % (end_time - start_time)
print (result)

# exit
sys.exit(0)