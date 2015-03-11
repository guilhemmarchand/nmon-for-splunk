#!/usr/bin/python

# Program name: nmon_cleaner.py
# Compatibility: Python 2.7
# Purpose - Clean csv files when retention expires, tuned for the Coke Company
# Author - Guilhem Marchand
# Date of first publication - November 2014

# Releases Notes:

# - November 2014, V1.0.0: Guilhem Marchand, Initial version
# - 12/28/2014, V1.1.0: Guilhem Marchand, Rewritten version for Nmon Splunk App V1.5.0
# - 11/03/2015, V1.1.1: Guilhem Marchand, migration of var directory

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
version = '1.1.1'

# LOGGING INFORMATION:
# - The program uses the standard logging Python module to display important messages in Splunk logs
# - Every message of the script will be indexed and accessible within Splunk splunkd logs

#################################################
#      Functions
#################################################

# Disallow negative value in parser

def check_negative(value):

    ivalue = int(value)
    if ivalue < 0:
        raise argparse.ArgumentTypeError("%s is an invalid positive int value" % value)
    return ivalue

#################################################
#      Arguments Parser
#################################################

# Define Arguments
parser = argparse.ArgumentParser()

parser.add_argument('--cleancsv', action='store_true', default=False, dest='cleancsv',
                    help='Activate the purge of csv files from csv repository and config repository '
                         '(see also options above)')

parser.add_argument('--maxseconds_csv', action='store', dest='MAXSECONDS_CSV', type=check_negative,
                    help='Set the maximum file retention in seconds for csv data, every files older'
                         ' than this value will be permanently removed')

parser.add_argument('--maxseconds_nmon', action='store', dest='MAXSECONDS_NMON', type=check_negative,
                    help='Set the maximum file retention in seconds for nmon files, every files older'
                         ' than this value will be permanently removed')

parser.add_argument('--approot', action='store', dest='APP',
                    help='Set a custom value for the Application root directory '
                         '(default are: nmon / TA-nmon / PA-nmon)')

parser.add_argument('--csv_repository', action='store', dest='CSV_REPOSITORY',
                    help='Set a custom location for directory containing csv data (default: csv_repository)')

parser.add_argument('--config_repository', action='store', dest='CONFIG_REPOSITORY',
                    help='Set a custom location for directory containing config data (default: config_repository)')

parser.add_argument('--nmon_repository', action='store', dest='NMON_REPOSITORY',
                    help='Set a custom location for directory containing nmon raw data (default: nmon_repository)')

parser.add_argument('--version', action='version', version='%(prog)s ' + version)

args = parser.parse_args()

#################################################
#      Variables
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
maxseconds_csv = args.MAXSECONDS_CSV
maxseconds_nmon = args.MAXSECONDS_NMON

# Set cleancsv
cleancsv = args.cleancsv

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

# If the nmon_repository is not defined, apply default 'nmon_repository' value
if not args.NMON_REPOSITORY:
    nmon_repository = "nmon_repository"
else:
    nmon_repository = args.NMON_REPOSITORY

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

# APP_MAINVAR and APP_VAR directories
if is_windows:
    APP_MAINVAR = SPLUNK_HOME + '\\var\\run\\nmon'
    APP_VAR = APP_MAINVAR + '\\var'
else:
    APP_MAINVAR = SPLUNK_HOME + '/var/run/nmon'
    APP_VAR = APP_MAINVAR + '/var'


if not os.path.exists(APP_MAINVAR):
    msg = 'The main var directory ' + APP_VAR + ' has not been found, there is no need to run now.'
    sys.exit(1)

# Repositories definition
if is_windows:
    CSV_DIR = APP_VAR + '\\' + csv_repository
    CONFIG_DIR = APP_VAR + '\\' + config_repository
    NMON_DIR = APP_VAR + '\\' + nmon_repository
else:
    CSV_DIR = APP_VAR + '/' + csv_repository
    CONFIG_DIR = APP_VAR + '/' + config_repository
    NMON_DIR = APP_VAR + '/' + nmon_repository

# Check
if not os.path.exists(NMON_DIR):
    msg = 'The Nmon repository location ' + NMON_DIR + ' could not be found, We tried: ' + str(NMON_DIR)
    logging.error(msg)
    sys.exit(1)

# List of directories to be proceeded
WORKING_DIR = {CSV_DIR, CONFIG_DIR}

# Verify directory exist
for DIR in WORKING_DIR:
    if not os.path.exists(DIR):
        msg = 'The CSV Data directory ' + DIR + ' could not be found, We tried: ' + str(DIR)
        logging.error(msg)
        sys.exit(1)

# Starting time of process
start_time = time.time()

####################################################################
#           Main Program
####################################################################

# Default value for CSV retention
if maxseconds_csv is None:
    maxseconds_csv = 900

# Default value for NMON retention
if maxseconds_nmon is None:
    maxseconds_nmon = 86400

# Show current time
msg = now + " Starting nmon cleaning"
print (msg)

# Display some basic information about us
msg = "Splunk Root Directory ($SPLUNK_HOME): " + str(SPLUNK_HOME) + " nmon_cleaner version: " + str(version) \
      + " Python version: " + str(python_version)
print (msg)

# Proceed to CSV cleaning
if cleancsv:

    for DIR in WORKING_DIR:

        # cd to directory
        os.chdir(DIR)

        # Verify we have data to manage
        counter = len(glob.glob1(DIR, "*.csv"))

        # print (counter)

        if counter == 0:
            msg = 'No files found in directory: ' + str(DIR) + ', no action required.'
            print (msg)

        else:

            # cd to directory
            os.chdir(DIR)

            # counter of files with retention expired
            counter_expired = 0

            curtime = time.time()
            limit = maxseconds_csv

            for xfile in glob.glob('*.csv'):

                filemtime = os.path.getmtime(xfile)

                if curtime - filemtime > limit:

                    counter_expired += 1

                    size_mb = os.path.getsize(xfile)/1000.0/1000.0
                    size_mb = format(size_mb, '.2f')

                    mtime = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(filemtime))  # Human readable datetime

                    msg = 'Max set retention of ' + str(maxseconds_csv) + ' seconds expired for file: ' + xfile + ' size(MB): '\
                          + str(size_mb) + ' mtime: ' + str(mtime)
                    print (msg)

                    os.remove(xfile)  # Permanently remove the file!

            msg = str(counter_expired) + ' files were permanently removed due to retention expired for directory ' + DIR
            print (msg)

# Proceed to NMON cleaning

# cd to directory
DIR = NMON_DIR

os.chdir(DIR)

# Verify we have data to manage
counter = len(glob.glob1(DIR, "*.nmon"))

# print (counter)

if counter == 0:
    msg = 'No files found in directory: ' + str(DIR) + ', no action required.'
    print (msg)

else:

    # cd to directory
    os.chdir(DIR)

    # counter of files with retention expired
    counter_expired = 0

    curtime = time.time()
    limit = maxseconds_csv

    for xfile in glob.glob('*.nmon'):

        filemtime = os.path.getmtime(xfile)

        if curtime - filemtime > limit:

            counter_expired += 1

            size_mb = os.path.getsize(xfile)/1000.0/1000.0
            size_mb = format(size_mb, '.2f')

            mtime = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(filemtime))  # Human readable datetime

            msg = 'Max set retention of ' + str(maxseconds_nmon) + ' seconds expired for file: ' + xfile + ' size(MB): '\
                  + str(size_mb) + ' mtime: ' + str(mtime)
            print (msg)

            os.remove(xfile)  # Permanently remove the file!

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
