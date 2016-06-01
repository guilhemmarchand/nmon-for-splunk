#!/usr/bin/env python

# Program name: nmon2csv.py
# Compatibility: Python 2x
# Purpose - convert nmon files into csv data for Splunk Nmon App, see https://apps.splunk.com/app/1753
# Author - Guilhem Marchand
# Disclaimer: This script has been designed to be used by the Splunk Archive Processor in the context of the
# Nmon Splunk App, see above
# Date of first publication - July 2014

# Licence:

# Copyright 2014 Guilhem Marchand

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Releases Notes:

# - July 2014, V1.0.0: Guilhem Marchand, Initial version
# - 08/04/2014, V1.0.1: Guilhem Marchand, Added the nmon2csv converter version in output processing,
# minor regex optimizations
# - 08/08/2014, V1.0.2: Guilhem Marchand, Code cleaning
# - 08/10/2014, V1.0.3: Guilhem Marchand, Added Windows Compatibility, Added Guest OS and Python version in
# output processing
# - 08/12/2014, V1.0.4: Guilhem Marchand, Added SNAPSHOTS and INTERVAL fields in csv creation to allow a more accurate
# autospan feature within Splunk
# - 08/14/2014, V1.0.5: Guilhem Marchand:
# - Changed Open file mode for writing from text to binary mode to avoid blank line creation under Windows OS
# (does not affect other OS)
# - Added a supplementary data sanity check for static sections to avoid creating csv fields with extra fields if data
# is inconsistent (more fields in data than header)
# - Added NFS Statistics extraction if any: Sections NFSSVRV2 / NFSSVRV3 / NFSSVRV4 for NFS server,
# NFSCLIV2 / NFSCLIV3 / NFSCLIV4 for NFS client
# - Added UARG data extraction if any
# - 08/26/2014, V1.0.6: Guilhem Marchand:
#                       - UARG section correction for AIX systems
#                       - Inconsistency data prevention for static and dynamic sections by comparing headers fields vs
# data fields
#                       - Logging improvements (some functional errors we logged in Splunk logged instead of
# nmon_processing, other messages improvements)
# - 09/04/2014, V1.0.7: Guilhem Marchand:
#								- Re-indent according to PEP-8 compliance, various PEP-8 compliance corrections
#                               - Added the Parameters section to facilitate customization of what is being extracted
# - 09/17/2014, V1.0.8: Guilhem Marchand: Improved compliance with Splunk Python events logging, portable
# shebang correction
# - 09/27/2014, V1.0.9: Guilhem Marchand: Added the file size in bytes to the Nmon ID and csv filename to prevent log
# detected as truncated
# - 10/16/2014, V1.0.10: Guilhem Marchand:
#                               - Corrected bad header identification than could happen due to unexpected blank space
# before comma in header data
#                               - Corrected % string replacement that could lead to unwanted replacement when part of
# a word at end of header line (ex: LPAR section when no pool)
# - 10/29/2014, V1.0.11: Guilhem Marchand:
#                               - Fix compatibility issue with old Nmon Linux release (example with 11f), sometimes
# the csv header will contain the first timestamp reference (T0001)
#                               which was leading to header identification failure, applicant only for static standard
# sections (VM,CPu_ALL...)
#                               - Code cleaning: Removing redundant escaped characters
# - 12/26/2014, V1.1.0: Guilhem Marchand: Major release
#                               - This is a major release of the nmon2csv converter that introduces real time capacity,
# the converter will now identify if it is
#											dealing with real time or coldata
#										  - If real time is detected, only newer events that the last run will be
# proceeded such that the converter can manage a running nmon file all along its runtime
# - 02/08/2015, V1.1.1: Guilhem Marchand: Arguments options to overwrite mode detection, DATA and CONFIG DIR, correction
#  of sections data availability detection (count => 1)
# - 02/10/2015, V1.1.2: Guilhem Marchand: Hotfix for Windows, string to epoch time conversion (%s) failing issue
# - 11/10/2015, V1.1.3: Guilhem Marchand: Migration of var nmon directory
# - 04/17/2015, V1.1.4: Guilhem Marchand:
#                                         - Number of maximum devices taken in charge increased to 3000 devices
# (20 x 150 devices per section)
#                                         - Prevents in Real time mode a failing configuration extraction if the
# BBB configuration occurs lately, especially for large systems
# - 04/23/2015, V1.1.5: Guilhem Marchand:
#                                         - Code improvement, Analyse type of Operating System and prevent from search
# for not applicable sections
#                                         - Solaris update, Added Solaris specific sections, specially for Zone analysis
# - 05/01/2015, V1.1.6: Guilhem Marchand:
#                                         - Added support for FC* sections (Fiber Channel)
# - 05/09/2015, V1.1.7: Guilhem Marchand:
#                                         - Added support for SEA* sections (Shared Ethernet Adapters for AIX Vios)
# - 05/21/2015, V1.1.8: Guilhem Marchand:
#                                         - Windows hotfix: corrected broken directory creation
# - 07/27/2015, V1.1.9: Guilhem Marchand:
#                                         - hotfix for using the PA-nmon to generate Performance data in
# standalone indexers
# - 08/05/2015, V1.1.10: Guilhem Marchand:
#                                         - hotfix: In Splunk 6.2.4, instance crash may happen if we delete an empty
# file while Splunk is watching for it
#                                           The script uses now an intermediate directory for Perf csv data creation
# - 08/05/2015, V1.1.11: Guilhem Marchand:
#                                         - hotfix for real time data management: Use epoch time identification
# per section instead of globally yo solve gaps in data
#										  - Corrected and improved optional arguments and help script
#										  - Added support for DISKREADSERV and DISKWRITESERV
# - 09/12/2015, V1.1.12: Guilhem Marchand:
#                                         - Per section status are now stored per hostname, section, this allows
# managing realtime data from central shares (eg. Nmon data stored in a central place and periodically updated by a
# third party software such as rsync
#										  - Manage ref, config id and per section status files per host to allow
# managing hot data from central shares
#                                         - Added support for CPUnn (CPU usage per logical core)
# - 10/17/2015, V1.1.13: Guilhem Marchand:
#                                         - Manage CPUnn update for Sarmon, allows taking in charge CPUnn in all cases
#                                         - Manage UARG for Sarmon (new in V1.11)
# - 12/14/2015, V1.1.14: Guilhem Marchand:
#                                         - Added support for POOL monitor (AIX only)
# - 01/16/2016, V1.1.15: Guilhem Marchand:
#                                         - OStype is now generated at parsing level for immediate
#                                           availability in Splunk
# - 04/21/2016, V1.1.16: Guilhem Marchand:
#                                         - PowerLinux update: manage the LPAR section
# - 04/28/2016, V1.1.17: Guilhem Marchand:
#                                         - Add new option to enforce host name value recovered from system host name
#                                           instead of nmon value
# (https://answers.splunk.com/answers/395601/nmon-performance-monitor-for-unix-and-linux-system-4.html)
# - 05/05/2016, V1.1.18: Guilhem Marchand:
#                                         - Manage Python datetime failure while parsing to epochtime, in some cases
#                                           the epoch conversion fails, if it is the case we'll use time module.
# - 05/05/2016, V1.1.19: Guilhem Marchand:
#                                         - Manage AIX WLM data

# Load libs

from __future__ import print_function

import sys
import re
import os
import time
import datetime
import csv
import logging
import cStringIO
import platform
import optparse
import glob
import socket

# Converter version
nmon2csv_version = '1.1.19'

# LOGGING INFORMATION:
# - The program uses the standard logging Python module to display important messages in Splunk logs
# - When we want messages to be indexed within Splunk nmon_processing sourcetype, display the message
# in stdout. (splunk won't index logging messages)
# Typically, functional errors will be displayed in stdout while technical failure will be logged

#################################################
#      Parameters
#################################################

# Customizations goes here:

# Sections of Performance Monitors with standard dynamic header but no "device" notion that would require the data
# to be transposed.
# You can add or remove any section depending on your needs
static_section = ["CPUnn", "CPU_ALL", "FILE", "MEM", "PAGE", "MEMNEW", "MEMUSE", "PROC", "VM", "NFSSVRV2",
                  "NFSSVRV3", "NFSSVRV4", "NFSCLIV2", "NFSCLIV3", "NFSCLIV4"]

# Some specific sections per OS
Solaris_static_section = ["PROCSOL"]

# Some specfic sections for micro partitions (AIX or Power Linux)
LPAR_static_section = ["LPAR", "POOLS"]

# This is the TOP section which contains Performance data of top processes
# It has a specific structure and requires specific treatment
top_section = ["TOP"]

# This is the UARG section which contains full command line arguments with some other information such as PID, user,
# group and so on.
# It has a specific structure and requires specific treatment
uarg_section = ["UARG"]

# Sections of Performance Monitors with "device" notion, data needs to be transposed by time to be fully exploitable
# This particular section will check for up to 10 subsection per Performance Monitor
# By default, Nmon create a new subsection (add an increment from 1 to x) per step of 150 devices
# 1500 devices (disks) will be taken in charge in default configuration
dynamic_section1 = ["DISKBUSY", "DISKBSIZE", "DISKREAD", "DISKWRITE", "DISKXFER", "DISKRIO", "DISKWIO", "DISKREADSERV",
                    "DISKWRITESERV"]

# Sections of Performance Monitors with "device" notion, data needs to be transposed by time to be fully exploitable
dynamic_section2 = ["IOADAPT", "NETERROR", "NET", "NETPACKET", "JFSFILE", "JFSINODE", "FCREAD", "FCWRITE", "FCXFERIN",
                    "FCXFEROUT"]

# Sections of Performance Monitors for Solaris

# Zone, Project, Task... performance
solaris_WLM = ["WLMPROJECTCPU", "WLMZONECPU", "WLMTASKCPU", "WLMUSERCPU", "WLMPROJECTMEM", "WLMZONEMEM", "WLMTASKMEM",
               "WLMUSERMEM"]

# Veritas Storage Manager
solaris_VxVM = ["VxVMREAD", "VxVMWRITE", "VxVMXFER", "VxVMBSIZE", "VxVMBUSY", "VxVMSVCTM", "VxVMWAITTM"]

solaris_dynamic_various = ["DISKSVCTM", "DISKWAITTM"]

# AIX only dynamic sections
AIX_dynamic_various = ["SEA", "SEAPACKET", "SEACHPHY"]

# AIX Workload Management
AIX_WLM = ["WLMCPU", "WLMMEM", "WLMBIO"]

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

# Initial states for Analysis
realtime = False
colddata = False

# Starting time of process
start_time = time.time()

# Verify SPLUNK_HOME environment variable is available, the script is expected to be launched by Splunk
# which will set this.
# for debugging or manual run, please set this variable manually
try:
    os.environ["SPLUNK_HOME"]
except KeyError:
    logging.error(
        'The environment variable SPLUNK_HOME could not be verified, if you want to run this script manually you need'
        ' to export it before processing')
    sys.exit(1)

# Guest Operation System type
ostype = platform.system().lower()

# If running Windows OS (used for directory identification)
is_windows = re.match(r'^win\w+', (platform.system().lower()))

# Current date
now = time.strftime("%d-%m-%Y %H:%M:%S")

# Current date in epoch time
if is_windows:
    now_epoch = int(time.time())
else:
    now_epoch = time.strftime("%s")

    # in case datetime fails
    if now_epoch == "%s":
        now_epoch = int(time.time())

# timestamp used to name csv files
csv_timestamp = time.strftime("%Y%m%d%H%M%S")

# Python version
python_version = platform.python_version()

# SPLUNK_HOME environment variable
SPLUNK_HOME = os.environ['SPLUNK_HOME']

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

if is_windows:
    PA_NMON_APP_STANDALONE = SPLUNK_HOME + '\\etc\\apps\\PA-nmon'
else:
    PA_NMON_APP_STANDALONE = SPLUNK_HOME + '/etc/apps/PA-nmon'

# Empty APP
APP = ''

# Verify APP exist
if os.path.exists(NMON_APP):
    APP = NMON_APP
elif os.path.exists(TA_NMON_APP):
    APP = TA_NMON_APP
elif os.path.exists(PA_NMON_APP):
    APP = PA_NMON_APP
elif os.path.exists(PA_NMON_APP_STANDALONE):
    APP = PA_NMON_APP_STANDALONE
else:
    msg = 'The Application root directory could not be found, is nmon / TA-nmon / PA-nmon installed ? We tried: ' + str(
        NMON_APP) + ' ' + str(TA_NMON_APP) + ' ' + str(PA_NMON_APP)
    logging.error(msg)
    sys.exit(1)

# APP_VAR directory
if is_windows:
    APP_MAINVAR = SPLUNK_HOME + '\\var\\run\\nmon'
    APP_VAR = SPLUNK_HOME + '\\var\\run\\nmon\\var'
else:
    APP_MAINVAR = SPLUNK_HOME + '/var/run/nmon'
    APP_VAR = SPLUNK_HOME + '/var/run/nmon/var'
if not os.path.exists(APP_MAINVAR):
    os.mkdir(APP_MAINVAR)
if not os.path.exists(APP_VAR):
    os.mkdir(APP_VAR)

# ID reference file, will be used to temporarily store the last execution result for a given nmon file,
# and prevent Splunk from generating duplicates by relaunching the conversion process
# Splunk when using a custom archive mode, launches twice the custom script

# Supplementary note: Since V1.1.0, the ID_REF is overwritten if running real time mode
if is_windows:
    ID_REF = APP_VAR + '\\id_reference.txt'
else:
    ID_REF = APP_VAR + '/id_reference.txt'

# Config Reference file
if is_windows:
    CONFIG_REF = APP_VAR + '\\config_reference.txt'
else:
    CONFIG_REF = APP_VAR + '/config_reference.txt'

# BBB extraction flag
if is_windows:
    BBB_FLAG = APP_VAR + '\\BBB_status.flag'
else:
    BBB_FLAG = APP_VAR + '/BBB_status.flag'

# CSV Perf data repository
if is_windows:
    DATA_DIR = APP_VAR + '\\csv_workingdir\\'
else:
    DATA_DIR = APP_VAR + '/csv_workingdir/'
if not os.path.exists(DATA_DIR):
    os.mkdir(DATA_DIR)

# CSV Perf data working directory (files are moved at the end from DATA_DIR to DATAWORKING_DIR)
if is_windows:
    DATAFINAL_DIR = APP_VAR + '\\csv_repository\\'
else:
    DATAFINAL_DIR = APP_VAR + '/csv_repository/'
if not os.path.exists(DATA_DIR):
    os.mkdir(DATA_DIR)

# CSV output repository
if is_windows:
    CONFIG_DIR = APP_VAR + '\\config_repository\\'
else:
    CONFIG_DIR = APP_VAR + '/config_repository/'
if not os.path.exists(CONFIG_DIR):
    os.mkdir(CONFIG_DIR)

# Initialize some default values
day = "-1"
month = "-1"
year = "-1"
hour = "-1"
minute = "-1"
second = "-1"
ZZZZ_timestamp = "-1"
INTERVAL = "-1"
SNAPSHOTS = "-1"
sanity_check = "-1"

#################################################
#      Arguments
#################################################

parser = optparse.OptionParser(usage='usage: %prog [options]', version='%prog '+nmon2csv_version)

parser.set_defaults(mode='auto', datadir=DATA_DIR, configdir=CONFIG_DIR, dumpargs=False)

parser.add_option('-d', '--datadir', action='store', type='string', dest='datadir',
                  help='sets the output directory for data CSV files (Default: %default)')
opmodes = ['auto', 'realtime', 'colddata']
parser.add_option('-m', '--mode', action='store', type='choice', dest='mode', choices=opmodes,
                  help='sets the operation mode (Default: %default); supported modes: ' + ', '.join(opmodes))
parser.add_option('--use_fqdn', action='store_true', dest='use_fqdn', help='Use the host fully qualified '
                                                                           'domain name (fqdn) as the '
                                                                           'hostname value instead of the'
                                                                           ' value returned by nmon.\n'
                                                                           '**CAUTION:** This option must not be used'
                                                                           ' when managing nmon data generated out'
                                                                           ' of Splunk'
                                                                           ' (eg. central repositories)')
parser.add_option('--dumpargs', action='store_true', dest='dumpargs',
                  help='only dump the passed arguments and exit (for debugging purposes only)')
parser.add_option('--debug', action='store_true', dest='debug', help='Activate debug for testing purposes')

(options, args) = parser.parse_args()

if options.dumpargs:
    print("options: ", options)
    print("args: ", args)
    sys.exit(0)

# Set debug mode
if options.debug:
    debug = True
else:
    debug = False

# Set hostname mode
if options.use_fqdn:
    use_fqdn = True
else:
    use_fqdn = False

DATA_DIR = options.datadir
CONFIG_DIR = options.configdir

if not os.path.exists(DATA_DIR):
    try:
        os.makedirs(DATA_DIR)
    except Exception as ex:
        logging.error("Unable to create data output directory '%s': %s" % (DATA_DIR, ex))
        sys.exit(1)

if not os.path.exists(DATAFINAL_DIR):
    try:
        os.makedirs(DATAFINAL_DIR)
    except Exception as ex:
        logging.error("Unable to create data output directory '%s': %s" % (DATAFINAL_DIR, ex))
        sys.exit(1)

if not os.path.exists(CONFIG_DIR):
    try:
        os.makedirs(CONFIG_DIR)
    except Exception as ex:
        logging.error("Unable to create config output directory '%s': %s" % (CONFIG_DIR, ex))
        sys.exit(1)

#################################################
#      Functions
#################################################

# Return current time stamp in Nmon fashion


def currenttime():
    now = time.strftime("%d-%m-%Y %H:%M:%S")

    return now


# Replace % for common sections
def subpctreplace(line):
    # Replace bank char followed by %
    line = re.sub(r'\s%', '_PCT', line)

    # Replace % if part of a word
    line = re.sub(r'(?<=[a-zA-Z0-9])%', '_PCT', line)

    # Replace % at beginning of a word
    line = re.sub(r'(?<=[a-zA-Z0-9,])%(?=[a-zA-Z0-9]+|$)', 'PCT', line)

    # Replace any other %
    line = re.sub(r'%', '_PCT', line)

    return line


# Replace % for TOP section only
def subpcttopreplace(line):
    # Replace % (specific for TOP)
    line = re.sub(r'%', 'pct_', line)

    return line


# Replace others for all sections
def subreplace(line):
    # Replace blank space between 2 groups of chars
    line = re.sub(r'(?<=[a-zA-Z0-9]) (?=[a-zA-Z0-9]+|$)', '_', line)

    # Replace +
    line = re.sub(r'\+', '', line)

    # Replace "(" by "_"
    line = re.sub(r'\(', '_', line)

    # Replace ")" by nothing
    line = re.sub(r'\)', '', line)

    # Replace =0 by nothing
    line = re.sub(r'=0', '', line)

    return line


# Convert month names (eg. JANV) to month numbers (eg. 01)
def monthtonumber(mydate):
    month_to_numbers = {'JAN': '01', 'FEB': '02', 'MAR': '03', 'APR': '04', 'MAY': '05', 'JUN': '06', 'JUL': '07',
                        'AUG': '08', 'SEP': '09', 'OCT': '10', 'NOV': '11', 'DEC': '12'}

    for k, v in month_to_numbers.items():
        mydate = mydate.replace(k, v)

    return mydate


# Convert month numbers (eg. 01) to month names (eg. JANV)
def numbertomonth(month):
    numbers_to_month = {'01': 'JAN', '02': 'FEB', '03': 'MAR', '04': 'APR', '05': 'MAY', '06': 'JUN', '07': 'JUL',
                        '08': 'AUG', '09': 'SEP', '10': 'OCT', '11': 'NOV', '12': 'DEC'}

    for k, v in numbers_to_month.items():
        month = month.replace(k, v)

    return month


# Open ID_REF, global to be used in function or current scope
def openRef():
    global ref
    ref = open(ID_REF, "w")

####################################################################
#           Main Program
####################################################################

#################################
# Retrieve NMON data from stdin #
#################################

# Read nmon data from stdin
data = sys.stdin.readlines()

# Number of lines read
nbr_lines = len(data)

# Size of data read
bytes_total = len(''.join(data))

# Show current time and number of lines
msg = currenttime() + " Reading NMON data: " + str(nbr_lines) + " lines" + " " + str(bytes_total) + " bytes"
print(msg)

# Show Splunk Root Directory
msg = 'Splunk Root Directory ($SPLUNK_HOME): ' + str(SPLUNK_HOME)
print(msg)

# Show program version
msg = "nmon2csv version: " + str(nmon2csv_version)
print(msg)

# Show type of OS we are running
print('Guest Operating System:', ostype)

# Show Python Version
print('Python version:', python_version)

# Prevent managing empty file
count = 0

# Exit if empty with error message
for line in data:
    count += 1

if count < 1:
    logging.error('Empty Nmon file!')
    sys.exit(1)

##################################################
# Extract Various data from AAA and BBB sections #
##################################################

# Set some default values
SN = "-1"
HOSTNAME = "-1"
DATE = "-1"
TIME = "-1"
logical_cpus = "-1"
virtual_cpus = "-1"
OStype = "Unknown"

for line in data:

    # Set HOSTNAME

    # if the option --use_fqdn has been set, use the fully qualified domain name by the running OS
    # The value will be equivalent to the stdout of the os "hostname -f" command
    # CAUTION: This option must not be used to manage nmon data out of Splunk ! (eg. central repositories)
    if use_fqdn:
        host=socket.getfqdn()
        if host:
            HOSTNAME = host
    else:
        host = re.match(r'^(AAA),(host),(.+)\n', line)
        if host:
            HOSTNAME = host.group(3)
            print("HOSTNAME:", HOSTNAME)

    # Set VERSION
    version = re.match(r'^(AAA),(version),(.+)\n', line)
    if version:
        VERSION = version.group(3)
        print("NMON VERSION:", VERSION)

    # Set SN
    sn = re.match(r'^(BBB.+)(systemid.+)(IBM,)(\w+)(.+)\n', line)
    if sn:
        SN = sn.group(4)
        print("SerialNumber:", SN)

    # Set DATE
    date = re.match(r'^(AAA),(date),(.+)\n', line)
    if date:
        DATE = date.group(3)
        print("DATE of Nmon data:", DATE)

    # Set date details
    date_details = re.match(r'(AAA,date,)([0-9]+)[/|\-]([a-zA-Z-0-9]+)[/|\-]([0-9]+)', line)
    if date_details:
        day = date_details.group(2)
        month = date_details.group(3)
        year = date_details.group(4)

    # Set TIME
    time_match = re.match(r'^(AAA),(time),(.+)\n', line)
    if time_match:
        TIME = time_match.group(3)
        print("TIME of Nmon Data:", TIME)

    # Set TIME DETAILS
    time_details = re.match(r'(AAA,time,)([0-9]+).([0-9]+).([0-9]+)', line)
    if time_details:
        hour = time_details.group(2)
        minute = time_details.group(3)
        second = time_details.group(4)

    # Set INTERVAL
    interval = re.match(r'^(AAA),(interval),(.+)\n', line)
    if interval:
        INTERVAL = interval.group(3)
        print("INTERVAL:", INTERVAL)

    # Set SNAPSHOTS
    snapshots = re.match(r'^(AAA),(snapshots),(.+)\n', line)
    if snapshots:
        SNAPSHOTS = snapshots.group(3)
        print("SNAPSHOTS:", SNAPSHOTS)

    # Set logical_cpus (Note: AIX systems for example will have values behind AAA,cpus - should use the second
    # by default if it exists)
    LOGICAL_CPUS = re.match(r'^(AAA),(cpus),(.+),(.+)\n', line)
    if LOGICAL_CPUS:
        logical_cpus = LOGICAL_CPUS.group(4)
        print("logical_cpus:", logical_cpus)
    else:
        # If not defined in second position, set it from first
        LOGICAL_CPUS = re.match(r'^(AAA),(cpus),(.+)\n', line)
        if LOGICAL_CPUS:
            logical_cpus = LOGICAL_CPUS.group(3)
            print("logical_cpus:", logical_cpus)

    # Set virtual_cpus
    VIRTUAL_CPUS = re.match(r'^BBB[a-zA-Z].+Online\sVirtual\sCPUs.+:\s([0-9]+)\"\n', line)
    if VIRTUAL_CPUS:
        virtual_cpus = VIRTUAL_CPUS.group(1)
        print("virtual_cpus:", virtual_cpus)

    # Identify Linux hosts
    OStype_Linux = re.search(r'AAA,OS,Linux', line)
    if OStype_Linux:
        OStype = "Linux"

    # Identify Solaris hosts
    OStype_Solaris = re.match(r'^AAA,OS,Solaris,.+', line)
    if OStype_Solaris:
        OStype = "Solaris"

    # Identify AIX hosts
    AIX_LEVEL_match = re.match(r'^AAA,AIX,(.+)', line)
    if AIX_LEVEL_match:
        OStype = "AIX"

# Show NMON OStype
print("NMON OStype:", OStype)

# If HOSTNAME could not be defined
if HOSTNAME == '-1':
    print("ERROR: The hostname could not be extracted from Nmon data !")
    sys.exit(1)

# If DATE could not be defined
if DATE == '-1':
    print("date could not be extracted from Nmon data !")
    sys.exit(1)

# If TIME could not be defined
if TIME == '-1':
    print("time could not be extracted from Nmon data !")
    sys.exit(1)

# If logical_cpus could not be defined
if logical_cpus == '-1':
    print("The number of logical cpus (logical_cpus) could not be extracted from Nmon data !")
    sys.exit(1)

# If virtual_cpus could not be defined, set it equal to logical_cpus
if virtual_cpus == '-1':
    virtual_cpus = logical_cpus
    print("virtual_cpus: " + virtual_cpus)

# If SN could not be defined, not an AIX host, SN == HOSTNAME
if SN == '-1':
    SN = HOSTNAME

###############################
# NMON Structure Verification #
###############################

# The purpose of this section is to achieve some structure verification of the Nmon file
# to prevent data inconsistency

for line in data:

    # Verify we do not have any line that contain ZZZZ without beginning the line by ZZZZ
    # In such case, the nmon data is bad and buggy, converting it would generate data inconsistency

    # Search for ZZZZ truncated lines (eg. line containing ZZZZ pattern BUT not beginning the line)

    ZZZZ_truncated = re.match(r'.+ZZZZ,', line)
    if ZZZZ_truncated:
        # We do not use logging to be able to access this messages within Splunk (Splunk won't index error
        #  logging messages)

        msg = 'ERROR: hostname: ' + HOSTNAME + ' Detected Bad Nmon structure, found ZZZZ lines truncated! ' \
                                               '(ZZZZ lines contains the event timestamp and should always ' \
                                               'begin the line)'
        print(msg)
        msg = 'ERROR: hostname: ' + HOSTNAME + ' Ignoring nmon data'
        print(msg)
        sys.exit(1)

    # Search for old time format (eg. Nmon version V9 and prior)
    time_oldformat = re.match(r'(AAA,date,)([0-9]+)/([0-9]+)/([0-9]+)', line)
    if time_oldformat:
        msg = 'INFO: hostname: ' + HOSTNAME + ' Detected old Nmon version using old Date format (dd/mm/yy)'
        print(msg)

        day = time_oldformat.group(2)
        month = time_oldformat.group(3)
        year = time_oldformat.group(4)

        # Convert %y to %Y
        year = datetime.datetime.strptime(year, '%y').strftime('%Y')

        # Convert from months numbers to months name for compatibility with later Nmon versions
        # Note: we won't use here datetime to avoid issues with locale names of months

        month = numbertomonth(month)

        DATE = day + '-' + month + '-' + year

        msg = 'INFO: hostname: ' + HOSTNAME + ' Date converted to: ' + DATE
        print(msg)

# End for

################################
# Data status store #
################################

# Various status are stored in different files
# This includes the id check file, the config check file and status per section containing last epochtime proceeded
# These items will be stored in a per host dedicated directory

# create a directory under APP_VAR
# This directory will used to store per section last epochtime status
if is_windows:
    HOSTNAME_VAR = APP_VAR + '\\' + HOSTNAME + '_' + SN
else:
    HOSTNAME_VAR = APP_VAR + '/' + HOSTNAME + '_' + SN

if not os.path.isdir(HOSTNAME_VAR):
    try:
        os.mkdir(HOSTNAME_VAR)
    except Exception, e:
        msg = 'Error encountered during directory creation has failed due to:'
        msg = (msg, '%s' % e.__class__)
        logging.error(msg)

#####################
    # Migration from 1.1.11 #
#####################

def migrate():


    for src in glob.glob('*.txt'):
        if is_windows:
            dst = HOSTNAME_VAR + '\\' + HOSTNAME + '.' + src
        else:
            dst = HOSTNAME_VAR + '/' + HOSTNAME + '.' + src
        os.rename(src, dst)
    for src in glob.glob('*.flag'):
        if is_windows:
            dst = HOSTNAME_VAR + '\\' + HOSTNAME + '.' + src
        else:
            dst = HOSTNAME_VAR + '/' + HOSTNAME + '.' + src
        os.rename(src, dst)

# Migrate the location and file names if we detected a version prior to V1.1.11
current_dir = os.getcwd()
os.chdir(APP_VAR)
if os.path.isfile('id_reference.txt') or os.path.isfile('id_reference_realtime.txt'):
        print('INFO: Detected migration from V1.1.11 or previous, migrating status store file')
        migrate()
os.chdir(current_dir)

###############
# ID Check #
###############

# This section prevents Splunk from generating duplicated data for the same Nmon file
# While using the archive mode, Splunk may opens twice the same file sequentially
# If the Nmon file id is already present in our reference file, then we have already proceeded this Nmon and
# nothing has to be done
# Last execution result will be extracted from it to stdout

# Set default value for the last known epochtime
last_known_epochtime = 0

# Set the value in epochtime of the starting nmon
NMON_DATE = DATE + ' ' + TIME

# For Nmon V10 and more
timestamp_match = re.match(r'\d*-\w*-\w*\s\d*:\d*:\d*', NMON_DATE)
if timestamp_match:

    if is_windows:
        starting_epochtime = int(time.mktime(time.strptime(NMON_DATE, '%d-%b-%Y %H:%M:%S')))
    else:
        starting_epochtime = datetime.datetime.strptime(NMON_DATE, '%d-%b-%Y %H:%M:%S').strftime('%s')
        
        # in case datetime fails
        if starting_epochtime == "%s":
            starting_epochtime = int(time.mktime(time.strptime(NMON_DATE, '%d-%b-%Y %H:%M:%S')))
        
    starting_time = datetime.datetime.strptime(NMON_DATE, '%d-%b-%Y %H:%M:%S').strftime('%d-%m-%Y %H:%M:%S')

else:
    # For Nmon v9 and prior

    if is_windows:
        starting_epochtime = int(time.mktime(time.strptime(NMON_DATE, '%d-%b-%Y %H:%M.%S')))
    else:
        starting_epochtime = datetime.datetime.strptime(NMON_DATE, '%d-%b-%Y %H:%M.%S').strftime('%s')

        # in case datetime fails
        if starting_epochtime == "%s":
            starting_epochtime = int(time.mktime(time.strptime(NMON_DATE, '%d-%b-%Y %H:%M.%S')))

    starting_time = datetime.datetime.strptime(NMON_DATE, '%d-%b-%Y %H:%M.%S').strftime('%d-%m-%Y %H:%M:%S')

# Search for last epochtime in data
for line in data:

    # Extract timestamp

    # Nmon V9 and prior do not have date in ZZZZ
    # If unavailable, we'll use the global date (AAA,date)
    ZZZZ_DATE = '-1'
    ZZZZ_TIME = '-1'

    # For Nmon V10 and more

    timestamp_match = re.match(r'^ZZZZ,(.+),(.+),(.+)\n', line)
    if timestamp_match:
        ZZZZ_TIME = timestamp_match.group(2)
        ZZZZ_DATE = timestamp_match.group(3)

        # Replace month names with numbers
        ZZZZ_DATE = monthtonumber(ZZZZ_DATE)

        # Compose final timestamp
        ZZZZ_timestamp = ZZZZ_DATE + ' ' + ZZZZ_TIME

        # Convert in epochtime
        if is_windows:
            ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))
        else:
            ZZZZ_epochtime = datetime.datetime.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S').strftime('%s')

            # in case datetime fails
            if ZZZZ_epochtime == "%s":
                ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))

    # For Nmon V9 and less

    if ZZZZ_DATE == '-1':
        ZZZZ_DATE = DATE

        # Replace month names with numbers
        ZZZZ_DATE = monthtonumber(ZZZZ_DATE)

        timestamp_match = re.match(r'^ZZZZ,(.+),(.+)\n', line)
        if timestamp_match:
            ZZZZ_TIME = timestamp_match.group(2)
            ZZZZ_timestamp = ZZZZ_DATE + ' ' + ZZZZ_TIME

            # Convert in epochtime
            if is_windows:
                ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))
            else:
                ZZZZ_epochtime = datetime.datetime.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S').strftime('%s')

                # in case datetime fails
                if ZZZZ_epochtime == "%s":
                    ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))

# Set ending epochtime
# noinspection PyBroadException
try:
    if ZZZZ_epochtime:
        ending_epochtime = ZZZZ_epochtime
    else:
        ZZZZ_epochtime = starting_epochtime
except NameError:
    logging.info("The ending period of this Nmon file could not be determined, most probably the nmon process has not "
                 "yet generated any performance data, this should be resolved on next occurrence.")
    sys.exit(0)
except:
    logging.error("Encountered an Unexpected error while parsing this Nmon file Nmon, cannot continue")
    sys.exit(1)

# Evaluate if we are dealing with real time data or cold data
# This feature can be overriden by the --mode option
# Windows guest is not concerned
if options.mode == 'colddata':
    colddata = True
elif options.mode == 'realtime':
    realtime = True
elif is_windows:
    colddata = True
else:
    # options.mode is 'auto', therefore:
    # Evaluate if we are dealing with real time data or cold data
    if (int(start_time) - (4 * int(INTERVAL))) > int(ending_epochtime):
        colddata = True
    else:
        realtime = True

if realtime:
    # Override ID_REF & CONFIG_REF
    if is_windows:
        ID_REF = HOSTNAME_VAR + '\\' + HOSTNAME + '.id_reference_realtime.txt'
        CONFIG_REF = HOSTNAME_VAR + '\\' + HOSTNAME + '.config_reference_realtime.txt'
        BBB_FLAG = HOSTNAME_VAR + '\\' + HOSTNAME + '.BBB_status.flag'
    else:
        ID_REF = HOSTNAME_VAR + '/' + HOSTNAME + '.id_reference_realtime.txt'
        CONFIG_REF = HOSTNAME_VAR + '/' + HOSTNAME + '.config_reference_realtime.txt'
        BBB_FLAG = HOSTNAME_VAR + '/' + HOSTNAME + '.BBB_status.flag'
else:
    # Override ID_REF & CONFIG_REF
    if is_windows:
        ID_REF = HOSTNAME_VAR + '\\' + HOSTNAME + '.id_reference.txt'
        CONFIG_REF = HOSTNAME_VAR + '\\' + HOSTNAME + '.config_reference.txt'
        BBB_FLAG = HOSTNAME_VAR + '\\' + HOSTNAME + '.BBB_status.flag'
    else:
        ID_REF = HOSTNAME_VAR + '/' + HOSTNAME + '.id_reference.txt'
        CONFIG_REF = HOSTNAME_VAR + '/' + HOSTNAME + '.config_reference.txt'
        BBB_FLAG = HOSTNAME_VAR + '/' + HOSTNAME + '.BBB_status.flag'

# NMON file id (concatenation of ids)
idnmon = DATE + ':' + TIME + ',' + HOSTNAME + ',' + SN + ',' + str(bytes_total) + ',' + str(starting_epochtime) + ',' +\
         str(ending_epochtime)

# Partial idnmon that won't contain ending_epochtime for compare operation, to used for cold data
partial_idnmon = DATE + ':' + TIME + ',' + HOSTNAME + ',' + SN + ',' + str(bytes_total) + ',' + str(starting_epochtime)

# Show Nmon ID
print("NMON ID:", idnmon)

# Show real time / cold data message
if realtime:
    if options.mode == 'realtime':
        msg = "ANALYSIS: Enforcing realtime mode using --mode option"
    else:
        msg = 'ANALYSIS: Assuming Nmon realtime data'
    print(msg)
elif colddata:
    if options.mode == 'colddata':
        msg = "ANALYSIS: Enforcing colddata mode using --mode option"
    else:
        msg = 'ANALYSIS: Assuming Nmon cold data'
    print(msg)

# Open reference file for reading, if exists already
if os.path.isfile(ID_REF):

    with open(ID_REF, "r") as ref:

        for line in ref:

            if realtime:

                # Search for this ID
                idmatch = re.match(idnmon, line)
                if idmatch:

                    # If ID matches, then the file has been previously proceeded, let's show last result of execution
                    for k in ref:
                        k = k.rstrip("\n").split(";")
                        print(k)

                    sys.exit(0)

                # If id does not match, recover the last known ending epoch time to proceed only new data
                else:

                    last_known_epochtime_match = re.match(r'.*Ending_epochtime:\s(\d+)', line)
                    if last_known_epochtime_match:
                        last_known_epochtime = last_known_epochtime_match.group(1)

            elif colddata:

                # Search for this ID
                idmatch = re.match(partial_idnmon, line)
                if idmatch:

                    # If ID matches, then the file has been previously proceeded, let's show last result of execution
                    for k in ref:
                        k = k.rstrip("\n").split(";")
                        print(k)

                    sys.exit(0)

                # If id does not match, recover the last known ending epoch time to proceed only new data
                else:
                    last_known_epochtime = starting_epochtime

# If we here, then this file has not been previously proceeded

# Open reference file for writing
msg = now + " Reading NMON data: " + str(nbr_lines) + " lines" + " " + str(bytes_total) + " bytes"
openRef()

# write id
ref.write(msg + '\n')
ref.write(idnmon + '\n')

# write starting epoch
msg = "Starting_epochtime: " + str(starting_epochtime)
print(msg)
ref.write(msg + '\n')

# write last epochtime of Nmon data
msg = "Ending_epochtime: " + str(ZZZZ_epochtime)
print(msg)
ref.write(msg + '\n')

# Show and save last known epoch time
msg = 'last known epoch time: ' + str(last_known_epochtime)
print(msg)
ref.write(msg + '\n')

# Set last known epochtime equal to starting epochtime if the nmon has not been yet proceeded
if last_known_epochtime == 0:
    last_known_epochtime = starting_epochtime

####################
# Write CONFIG csv #
####################

# Extraction of the AAA and BBB sections with a supplementary header to allow Splunk identifying the host and
# timestamp as a multi-lines event
# In any case, the Configuration extraction will not be executed more than once per hour
# In the case of Real Time data, the extraction will only be achieved once per Nmon file

# Update 04/17/2015: In real time mode with very large system, the performance collect may starts before the
# configuration ends (eg. an AAA section, followed by Perf metrics and later the BBB section)
# This would implies partial configuration extraction to be proceeded
# The script now verifies that the BBB section has been successfully extracted before setting the status to
# do not extract

# Set section
section = "CONFIG"

# Set output file
config_output = CONFIG_DIR + HOSTNAME + '_' + day + '_' + month + '_' + year + '_' + hour + minute + second + '_' + str(
    bytes_total) + '_' + csv_timestamp + '.nmon.config.csv'

# Set default for config_run:
# 0 --> Extract configuration
# 1 --> Don't Extract configuration
# default is extract
config_run = 0

# Search in ID_REF for a last matching execution
if os.path.isfile(CONFIG_REF):

    with open(CONFIG_REF, "rb") as f:

        for line in f:

            # Only proceed if hostname has the same value
            if HOSTNAME in line:

                CONFIG_REFDETAILS = re.match(r'^.+:\s(\d+)', line)
                config_lastepoch = CONFIG_REFDETAILS.group(1)

                if config_lastepoch:

                    time_delta = (int(now_epoch) - int(config_lastepoch))

                    if time_delta < 3600:

                        # Only set the status to do not extract is the BBB_FLAG is not present
                        if not os.path.isfile(BBB_FLAG):
                            config_run = 1
                        else:
                            config_run = 0

                    elif time_delta > 3600:

                        config_run = 0

if config_run == 0:

    if realtime:

        # Only allow one extraction of the config section per nmon file
        limit = (int(starting_epochtime) + (4 * int(INTERVAL)))

        if int(last_known_epochtime) < int(limit):

            msg = "CONFIG section will be extracted"
            print(msg)
            ref.write(msg + "\n")

            # Initialize BBB_count
            BBB_count = 0

            # Open config output for writing
            with open(config_output, "wb") as config:

                # counter
                count = 0

                # Write header
                config.write('CONFIG' + ',' + DATE + ':' + TIME + ',' + HOSTNAME + ',' + SN + '\n')

                for line in data:

                    # Extract AAA and BBB sections, and write to config output
                    AAABBB = re.match(r'^[AAA|BBB].+', line)

                    if AAABBB:
                        # Increment
                        count += 1

                        # Increment the BBB counter
                        if "BBB" in line:
                            BBB_count += 1

                        # Write
                        config.write(line)

                # Under 10 lines of data in BBB, estimate extraction is not complete
                if BBB_count < 10:
                    with open(BBB_FLAG, "wb") as bbb_flag:
                        bbb_flag.write("BBB_status KO")
                else:
                    if os.path.isfile(BBB_FLAG):
                        os.remove(BBB_FLAG)

                # Show number of lines extracted
                result = "CONFIG section: Wrote" + " " + str(count) + " lines"
                print(result)
                ref.write(result + '\n')

                # Save the a combo of HOSTNAME: current_epochtime in CONFIG_REF
                with open(CONFIG_REF, "wb") as f:
                    f.write(HOSTNAME + ": " + str(now_epoch) + "\n")

        else:

            msg = "CONFIG section: Assuming we already extracted for this file"
            print(msg)
            ref.write(msg + "\n")

    elif colddata:

        msg = "CONFIG section will be extracted"
        print(msg)
        ref.write(msg + "\n")

        # Open config output for writing
        with open(config_output, "wb") as config:

            # counter
            count = 0

            # write header
            config.write('CONFIG' + ',' + DATE + ':' + TIME + ',' + HOSTNAME + ',' + SN + '\n')

            for line in data:

                # Extract AAA and BBB sections, and write to config output
                AAABBB = re.match(r'^[AAA|BBB].+', line)

                if AAABBB:
                    # Increment
                    count += 1

                    # Write
                    config.write(line)

            # Show number of lines extracted
            result = "CONFIG section: Wrote" + " " + str(count) + " lines"
            print(result)
            ref.write(result + '\n')

            # Save the a combo of HOSTNAME: current_epochtime in CONFIG_REF
            with open(CONFIG_REF, "wb") as f:
                f.write(HOSTNAME + ": " + str(now_epoch) + "\n")

elif config_run == 1:
    # Show number of lines extracted
    result = "CONFIG section: will not be extracted (time delta of " + str(time_delta) +\
             " seconds is inferior to 1 hour)"
    print(result)
    ref.write(result + '\n')

##########################
# Write PERFORMANCE DATA #
##########################

###################
# Static Sections : Header is dynamic but no devices context (drives, interfaces...) and there is
# no need to transpose the data
###################


def standard_section_fn(section):


    # Set output file
    currsection_output = DATA_DIR + HOSTNAME + '_' + day + '_' + month + '_' + year + '_' + hour + minute + second +\
                         '_' + section + '_' + str(bytes_total) + '_' + csv_timestamp + '.nmon.csv'

    # Store last epochtime if in real time mode
    keyref = HOSTNAME_VAR + '/' + HOSTNAME + '.' + section + '_lastepoch.txt'

    if realtime:
        if not os.path.exists(keyref):
            if debug:
                print ("DEBUG, no keyref file for this " + section +
                       " section (searched for " + keyref + "), no data or first execution")
        else:
            with open(keyref, "r") as f:
                for line in f:
                    myregex = 'last_epoch:\s(\d+)'
                    myregex_match = re.search(myregex, line)

                    # Standard header extraction
                    if myregex_match:
                        last_epoch_persection = myregex_match.group(1)

                        if debug:
                            print("DEBUG, Last known timestamp for " + section +
                                  " section is " + last_epoch_persection)

        # In realtime mode, in case no per section information is available, let's use global epoch time
        try:
            last_epoch_persection
        except NameError:
            if debug:
                print ("DEBUG: no last epoch information were found for " + section +
                       " , using global last epoch time (gaps in data may occur if not the first time we run)")
            last_epoch_filter = last_known_epochtime
        else:
            if debug:
                print ("DEBUG: Using per section last epoch time for event filtering (no gaps in data should occur)")
            last_epoch_filter = last_epoch_persection

    # counter
    count = 0

    # sanity_check
    sanity_check = 1

    # Initialize num_cols_header to 0 (see sanity_check)
    num_cols_header = 0

    # Sequence to search for
    seq = str(section) + ',' + 'T'

    for line in data:

        # Extract sections
        if str(seq) in line:  # Don't use regex here for more performance

            # increment
            count += 1

    # Virtually always activates CPUnn
    if section == 'CPUnn':
        # increment
        count += 1

    if count >= 1:

        # Open output for writing
        with open(currsection_output, "wb") as currsection:

            # counter
            count = 0

            for line in data:

                # Extract sections (manage specific case of CPUnn), and write to output
                if section == "CPUnn":
                    myregex = r'^' + 'CPU\d*' + '|ZZZZ.+'
                else:
                    myregex = r'^' + section + '|ZZZZ.+'

                find_section = re.match(myregex, line)
                if find_section:

                    # Replace trouble strings
                    line = subpctreplace(line)
                    line = subreplace(line)

                    # csv header

                    # Extract header excluding data that always has Txxxx for timestamp reference
                    # For CPUnn, search for first core
                    if section == "CPUnn":
                        myregex = '(' + 'CPU01' + ')\,([^T].+)'
                    else:
                        myregex = '(' + section + ')\,([^T].+)'

                    # Search for header
                    fullheader_match = re.search(myregex, line)

                    # Standard header extraction

                    # For CPUnn, if first core were not found using CPU01, search for CPU000 (Solaris) and
                    # CPU001 (Linux)
                    if section == "CPUnn":
                        if not fullheader_match:
                            myregex = '(' + 'CPU000' + ')\,([^T].+)'
                            fullheader_match = re.search(myregex, line)

                        if not fullheader_match:
                            myregex = '(' + 'CPU001' + ')\,([^T].+)'
                            fullheader_match = re.search(myregex, line)

                    if fullheader_match:
                        fullheader = fullheader_match.group(2)

                        # Replace "." by "_" only for header
                        fullheader = re.sub("\.", '_', fullheader)

                        # Replace any blank space before comma only for header
                        fullheader = re.sub(", ", ',', fullheader)

                        header_match = re.search(r'([a-zA-Z\-/_0-9]+,)([a-zA-Z\-/_0-9,]*)', fullheader)

                        if header_match:
                            header = header_match.group(2)

                            # increment
                            count += 1

                            # Write header
                            final_header = 'type' + ',' + 'serialnum' + ',' + 'hostname' + ',' + 'OStype' + ',' +\
                                           'logical_cpus' + ',' + 'virtual_cpus' + ',' + 'ZZZZ' +\
                                           ',' + 'interval' + ',' + 'snapshots' + ',' + header + '\n'

                            # Number of separators in final header
                            num_cols_header = final_header.count(',')

                            # Write header
                            currsection.write(final_header)

                    # Old Nmon version sometimes incorporates a Txxxx reference in the header, this is unclean
                    # but we want to try getting the header anyway

                    elif not fullheader_match:
                        # Assume the header may start with Txxx, then 1 non alpha char
                        myregex = '(' + section + ')\,(T\d+),([a-zA-Z]+.+)'
                        fullheader_match = re.search(myregex, line)

                        if fullheader_match:
                            fullheader = fullheader_match.group(3)

                            # Replace "." by "_" only for header
                            fullheader = re.sub("\.", '_', fullheader)

                            # Replace any blank space before comma only for header
                            fullheader = re.sub(", ", ',', fullheader)

                            header_match = re.search(r'([a-zA-Z\-/_0-9,]*)', fullheader)

                            if header_match:
                                header = header_match.group(1)

                                # increment
                                count += 1

                                # Write header
                                final_header = 'type' + ',' + 'serialnum' + ',' + 'hostname' + ',' + 'OStype' + ',' +\
                                               'logical_cpus' + ',' + 'virtual_cpus' + ',' + 'ZZZZ' + ',' +\
                                               'interval' + ',' + 'snapshots' + ',' + header + '\n'

                                # Number of separators in final header
                                num_cols_header = final_header.count(',')

                                # Write header
                                currsection.write(final_header)

                    # Extract timestamp

                    # Nmon V9 and prior do not have date in ZZZZ
                    # If unavailable, we'll use the global date (AAA,date)
                    ZZZZ_DATE = '-1'
                    ZZZZ_TIME = '-1'

                    # For Nmon V10 and more

                    timestamp_match = re.match(r'^ZZZZ,(.+),(.+),(.+)\n', line)
                    if timestamp_match:
                        ZZZZ_TIME = timestamp_match.group(2)
                        ZZZZ_DATE = timestamp_match.group(3)

                        # Replace month names with numbers
                        ZZZZ_DATE = monthtonumber(ZZZZ_DATE)

                        # Compose final timestamp
                        ZZZZ_timestamp = ZZZZ_DATE + ' ' + ZZZZ_TIME

                        if is_windows:
                            ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))
                        else:
                            ZZZZ_epochtime = datetime.datetime.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')\
                                .strftime('%s')

                            # in case datetime fails
                            if ZZZZ_epochtime == "%s":
                                ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))

                    # For Nmon V9 and less

                    if ZZZZ_DATE == '-1':
                        ZZZZ_DATE = DATE

                        # Replace month names with numbers
                        ZZZZ_DATE = monthtonumber(ZZZZ_DATE)

                        timestamp_match = re.match(r'^ZZZZ,(.+),(.+)\n', line)
                        if timestamp_match:
                            ZZZZ_TIME = timestamp_match.group(2)
                            ZZZZ_timestamp = ZZZZ_DATE + ' ' + ZZZZ_TIME

                            if is_windows:
                                ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))
                            else:
                                ZZZZ_epochtime = datetime.datetime.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')\
                                    .strftime('%s')

                                # in case datetime fails
                                if ZZZZ_epochtime == "%s":
                                    ZZZZ_epochtime = int(
                                        time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))

                    # Extract Data
                    if section == "CPUnn":
                        myregex = r'^' + '(CPU\d*)' + '\,(T\d+)\,(.+)\n'
                    else:
                        myregex = r'^' + section + '\,(T\d+)\,(.+)\n'
                    perfdata_match = re.match(myregex, line)

                    if perfdata_match:
                        if section == 'CPUnn':
                            perfdatatype = perfdata_match.group(1)
                            perfdata = perfdata_match.group(3)
                        else:
                            perfdata = perfdata_match.group(2)

                        if realtime:

                            if ZZZZ_epochtime > last_epoch_filter:

                                # increment
                                count += 1

                                # final_perfdata
                                if section == 'CPUnn':
                                    final_perfdata = perfdatatype + ',' + SN + ',' + HOSTNAME + ',' +\
                                                     OStype + ',' + logical_cpus + ',' + virtual_cpus + ',' +\
                                                     ZZZZ_timestamp + ',' + INTERVAL + ',' + SNAPSHOTS + ',' +\
                                                     perfdata + '\n'
                                else:
                                    final_perfdata = section + ',' + SN + ',' + HOSTNAME + ',' +\
                                                     OStype + ',' + logical_cpus + ',' + virtual_cpus + ',' +\
                                                     ZZZZ_timestamp + ',' + INTERVAL + ',' + SNAPSHOTS + ',' +\
                                                     perfdata + '\n'

                                # Analyse the first line of data: Compare number of fields in data with number of fields
                                # in header
                                # If the number of fields is higher than header, we assume this section is not
                                # consistent and will be entirely dropped
                                # This happens in rare times (mainly with old buggy nmon version) that the header is bad
                                # formatted (for example missing comma between fields identification)
                                # For performance purposes, we will test this only with first line of data and assume
                                # the data sanity based on this result
                                if count == 2:

                                    # Number of separators in final header
                                    num_cols_perfdata = final_perfdata.count(',')

                                    if num_cols_perfdata > num_cols_header:

                                        msg = 'ERROR: hostname: ' + HOSTNAME + ' :' + section +\
                                              ' section data is not consistent: ' + str(num_cols_perfdata) +\
                                              ' fields in data, ' + str(num_cols_header) \
                                              + ' fields in header, extra fields detected (more fields in data ' \
                                                'than header), dropping this section to prevent data inconsistency'
                                        print(msg)
                                        ref.write(msg + "\n")

                                        # Affect a sanity check to 1, bad data
                                        sanity_check = 1

                                    else:

                                        # Affect a sanity check to 0, good data
                                        sanity_check = 0

                                # Write perf data
                                currsection.write(final_perfdata)
                            else:
                                if debug:
                                    print ("DEBUG, " + section + " ignoring event " + ZZZZ_timestamp +
                                    " ( " + ZZZZ_epochtime + " is lower than last known epoch time for this section " +
                                           last_epoch_filter + " )")

                        elif colddata:

                            # increment
                            count += 1

                            # final_perfdata
                            if section == 'CPUnn':
                                final_perfdata = perfdatatype + ',' + SN + ',' + HOSTNAME + ',' +\
                                                 OStype + ',' + logical_cpus + ',' + virtual_cpus + ',' +\
                                                 ZZZZ_timestamp + ',' + INTERVAL + ',' + SNAPSHOTS + ',' +\
                                                 perfdata + '\n'
                            else:
                                final_perfdata = section + ',' + SN + ',' + HOSTNAME + ',' +\
                                                 OStype + ',' + logical_cpus + ',' + virtual_cpus + ',' +\
                                                 ZZZZ_timestamp + ',' + INTERVAL + ',' + SNAPSHOTS + ',' +\
                                                 perfdata + '\n'

                            # Analyse the first line of data: Compare number of fields in data with number of fields
                            # in header
                            # If the number of fields is higher than header, we assume this section is not consistent
                            # and will be entirely dropped
                            # This happens in rare times (mainly with old buggy nmon version) that the header is bad
                            # formatted (for example missing comma between fields identification)
                            # For performance purposes, we will test this only with first line of data and assume the
                            # data sanity based on this result
                            if count == 2:

                                # Number of separators in final header
                                num_cols_perfdata = final_perfdata.count(',')

                                if num_cols_perfdata > num_cols_header:

                                    msg = 'ERROR: hostname: ' + HOSTNAME + ' :' + section +\
                                          ' section data is not consistent: ' + str(num_cols_perfdata) +\
                                          ' fields in data, ' + str(num_cols_header) \
                                          + ' fields in header, extra fields detected (more fields in data ' \
                                            'than header), dropping this section to prevent data inconsistency'
                                    print(msg)
                                    ref.write(msg + "\n")

                                    # Affect a sanity check to 1, bad data
                                    sanity_check = 1

                                else:

                                    # Affect a sanity check to 0, good data
                                    sanity_check = 0

                            # Write perf data
                            currsection.write(final_perfdata)

        # Verify sanity check
        # Verify that the number of lines is at least 2 lines which should be the case if we are here (header + data)
        # In any case, don't allow empty files to kept in repository

        if sanity_check == 1:
            if os.path.isfile(currsection_output):
                os.remove(currsection_output)
        elif count < 1:
            if os.path.isfile(currsection_output):
                os.remove(currsection_output)
        else:
            # Show number of lines extracted
            result = section + " section: Wrote" + " " + str(count) + " lines"
            print(result)
            ref.write(result + "\n")

        # In realtime, Store last epoch time for this section
        if realtime:
            with open(keyref, "wb") as f:
                f.write("last_epoch: " + str(ZZZZ_epochtime) + "\n")

    # End for


# These are standard static sections common for all OS
for section in static_section:
    standard_section_fn(section)

# These sections are specific for Micro Partitions, can be AIX or PowerLinux
if OStype in ("AIX", "Linux", "Unknown"):
    for section in LPAR_static_section:
        standard_section_fn(section)

# Solaris specific
if OStype in ("Solaris", "Unknown"):
    for section in Solaris_static_section:
        standard_section_fn(section)

###################
# TOP section: has a specific structure with uncommon fields, needs to be treated separately
###################


def top_section_fn(section):

    # Set output file
    currsection_output = DATA_DIR + HOSTNAME + '_' + day + '_' + month + '_' + year + '_' + hour + minute + second +\
                         '_' + section + '_' + str(bytes_total) + '_' + csv_timestamp + '.nmon.csv'

    # Store last epochtime if in real time mode
    keyref = HOSTNAME_VAR + '/' + HOSTNAME + '.' + section + '_lastepoch.txt'

    if realtime:
        if not os.path.exists(keyref):
            if debug:
                print ("DEBUG, no keyref file for this " + section +
                       " section (searched for " + keyref + "), no data or first execution")
        else:
            with open(keyref, "r") as f:
                for line in f:
                    myregex = 'last_epoch:\s(\d+)'
                    myregex_match = re.search(myregex, line)

                    # Standard header extraction
                    if myregex_match:
                        last_epoch_persection = myregex_match.group(1)

                        if debug:
                            print("DEBUG, Last known timestamp for " + section +
                                  " section is " + last_epoch_persection)

        # In realtime mode, in case no per section information is available, let's use global epoch time
        try:
            last_epoch_persection
        except NameError:
            if debug:
                print ("DEBUG: no last epoch information were found for " + section +
                       " , using global last epoch time (gaps in data may occur if not the first time we run)")
            last_epoch_filter = last_known_epochtime
        else:
            if debug:
                print ("DEBUG: Using per section last epoch time for event filtering (no gaps in data should occur)")
            last_epoch_filter = last_epoch_persection

    # counter
    count = 0

    # Sequence to search for
    seq = str(section) + ','

    for line in data:

        # Extract sections
        if str(seq) in line:  # Don't use regex here for more performance

            # increment
            count += 1

    if count >= 1:

        # Open output for writing
        with open(currsection_output, "wb") as currsection:

            # counter
            count = 0

            for line in data:

                # Extract sections, and write to output
                myregex = r'^' + 'TOP,.PID' + '|ZZZZ.+'
                find_section = re.match(myregex, line)
                if find_section:

                    line = subpcttopreplace(line)
                    line = subreplace(line)

                    # csv header

                    # Extract header excluding data that always has Txxxx for timestamp reference
                    myregex = '(' + section + ')\,([^T].+)'
                    fullheader_match = re.search(myregex, line)

                    if fullheader_match:
                        fullheader = fullheader_match.group(2)

                        # Replace "." by "_" only for header
                        fullheader = re.sub("\.", '_', fullheader)

                        # Replace any blank space before comma only for header
                        fullheader = re.sub(", ", ',', fullheader)

                        header_match = re.search(r'([a-zA-Z\-/_0-9]+,)([a-zA-Z\-/_0-9]+,)([a-zA-Z\-/_0-9,]*)',
                                                 fullheader)

                        if header_match:
                            header_part1 = header_match.group(1)
                            header_part2 = header_match.group(3)
                            header = header_part1 + header_part2

                            # increment
                            count += 1

                            # Write header
                            currsection.write(
                                'type' + ',' + 'serialnum' + ',' + 'hostname' + ',' + 'OStype' + ',' +
                                'logical_cpus' + ',' + 'virtual_cpus' + ',' + 'ZZZZ' + ',' + 'interval' + ',' +
                                'snapshots' + ',' + header + '\n'),

                    # Extract timestamp

                    # Nmon V9 and prior do not have date in ZZZZ
                    # If unavailable, we'll use the global date (AAA,date)
                    ZZZZ_DATE = '-1'
                    ZZZZ_TIME = '-1'

                    # For Nmon V10 and more

                    timestamp_match = re.match(r'^ZZZZ,(.+),(.+),(.+)\n', line)
                    if timestamp_match:
                        ZZZZ_TIME = timestamp_match.group(2)
                        ZZZZ_DATE = timestamp_match.group(3)

                        # Replace month names with numbers
                        ZZZZ_DATE = monthtonumber(ZZZZ_DATE)

                        ZZZZ_timestamp = ZZZZ_DATE + ' ' + ZZZZ_TIME

                        if is_windows:
                            ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))
                        else:
                            ZZZZ_epochtime = datetime.datetime.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')\
                                .strftime('%s')

                            # in case datetime fails
                            if ZZZZ_epochtime == "%s":
                                ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))

                    # For Nmon V9 and less

                    if ZZZZ_DATE == '-1':
                        ZZZZ_DATE = DATE
                        timestamp_match = re.match(r'^ZZZZ,(.+),(.+)\n', line)

                        if timestamp_match:
                            ZZZZ_TIME = timestamp_match.group(2)

                            # Replace month names with numbers
                            ZZZZ_DATE = monthtonumber(ZZZZ_DATE)

                            ZZZZ_timestamp = ZZZZ_DATE + ' ' + ZZZZ_TIME
                            if is_windows:
                                ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))
                            else:
                                ZZZZ_epochtime = datetime.datetime.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')\
                                    .strftime('%s')

                                # in case datetime fails
                                if ZZZZ_epochtime == "%s":
                                    ZZZZ_epochtime = int(
                                        time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))

                # Extract Data
                perfdata_match = re.match('^TOP,([0-9]+),(T\d+),(.+)\n', line)
                if perfdata_match:
                    perfdata_part1 = perfdata_match.group(1)
                    perfdata_part2 = perfdata_match.group(3)
                    perfdata = perfdata_part1 + ',' + perfdata_part2

                    if realtime:

                        if ZZZZ_epochtime > last_epoch_filter:

                            # increment
                            count += 1

                            # Write perf data
                            currsection.write(
                                section + ',' + SN + ',' + HOSTNAME + ',' + OStype + ',' + logical_cpus +
                                ',' + virtual_cpus + ',' + ZZZZ_timestamp + ',' + INTERVAL + ',' +
                                SNAPSHOTS + ',' + perfdata + '\n'),
                        else:
                            if debug:
                                print ("DEBUG, " + section + " ignoring event " + ZZZZ_timestamp +
                                       " ( " + ZZZZ_epochtime + " is lower than last known epoch time for this"
                                                                " section " + last_epoch_filter + " )")

                    elif colddata:

                        # increment
                        count += 1

                        # Write perf data
                        currsection.write(
                            section + ',' + SN + ',' + HOSTNAME + ',' + OStype + ',' + logical_cpus +
                            ',' + virtual_cpus + ',' + ZZZZ_timestamp + ',' + INTERVAL + ',' +
                            SNAPSHOTS + ',' + perfdata + '\n'),

        # Verify that the number of lines is at least 2 lines which should be the case if we are here (header + data)
        # In any case, don't allow empty files to kept in repository
        if count < 1:
            if os.path.isfile(currsection_output):
                os.remove(currsection_output)
        else:
            # Show number of lines extracted
            result = section + " section: Wrote" + " " + str(count) + " lines"
            print(result)
            ref.write(result + "\n")

            # In realtime, Store last epoch time for this section
            if realtime:
                with open(keyref, "wb") as f:
                    f.write("last_epoch: " + str(ZZZZ_epochtime) + "\n")

# End for

# Run
for section in top_section:

    top_section_fn(section)

###################
# UARG section: has a specific structure with uncommon fields, needs to be treated separately
###################

# Note: UARG is not continuously collected as progs arguments may not always change (mainly for real time)
# For this section specifically write from membuffer only

# UARG is applicable only for AIX and Linux hosts


def uarg_section_fn(section):

    # Set output file
    currsection_output = DATA_DIR + HOSTNAME + '_' + day + '_' + month + '_' + year + '_' + hour + minute + second +\
                         '_' + section + '_' + str(bytes_total) + '_' + csv_timestamp + '.nmon.csv'

    # Store last epochtime if in real time mode
    keyref = HOSTNAME_VAR + '/' + HOSTNAME + '.' + section + '_lastepoch.txt'

    if realtime:
        if not os.path.exists(keyref):
            if debug:
                print ("DEBUG, no keyref file for this " + section +
                       " section (searched for " + keyref + "), no data or first execution")
        else:
            with open(keyref, "r") as f:
                for line in f:
                    myregex = 'last_epoch:\s(\d+)'
                    myregex_match = re.search(myregex, line)

                    # Standard header extraction
                    if myregex_match:
                        last_epoch_persection = myregex_match.group(1)

                        if debug:
                            print("DEBUG, Last known timestamp for " + section +
                                  " section is " + last_epoch_persection)

        # In realtime mode, in case no per section information is available, let's use global epoch time
        try:
            last_epoch_persection
        except NameError:
            if debug:
                print ("DEBUG: no last epoch information were found for " + section +
                       " , using global last epoch time (gaps in data may occur if not the first time we run)")
            last_epoch_filter = last_known_epochtime
        else:
            if debug:
                print ("DEBUG: Using per section last epoch time for event filtering (no gaps in data should occur)")
            last_epoch_filter = last_epoch_persection

    # counter
    count = 0

    # set oslevel default
    oslevel = "Unknown"

    # Sequence to search for
    seq = str(section) + ','

    for line in data:

        # Extract sections
        if str(seq) in line:  # Don't use regex here for more performance

            # increment
            count += 1

    if count >= 1:

        # Open StringIO for temp in memory
        membuffer = cStringIO.StringIO()

        # counter
        count = 0

        for line in data:

            # Extract sections, and write to output
            myregex = r'^' + 'UARG,.Time' + '|ZZZZ.+'
            find_section = re.match(myregex, line)
            if find_section:
                line = subpcttopreplace(line)
                line = subreplace(line)

                # csv header

                # Extract header excluding data that always has Txxxx for timestamp reference
                myregex = '(' + section + ')\,(.+)'
                fullheader_match = re.search(myregex, line)

                if fullheader_match:
                    fullheader = fullheader_match.group(2)

                    # Replace "." by "_" only for header
                    fullheader = re.sub("\.", '_', fullheader)

                    header_match = re.search(r'([a-zA-Z\-/_0-9]+,)([a-zA-Z\-/_0-9]+,)([a-zA-Z\-/_0-9,]*)',
                                             fullheader)

                    if header_match:
                        header_part1 = header_match.group(2)
                        header_part2 = header_match.group(3)
                        header = header_part1 + header_part2

                        # Specifically for UARG, set OS type based on header fields
                        os_match = re.search(r'PID,PPID,COMM,THCOUNT,USER,GROUP,FullCommand', header)

                        # Since V1.11, sarmon for Solaris implements UARG the same way Linux does
                        if os_match:
                            oslevel = 'AIX_or_Solaris'
                        else:
                            oslevel = 'Linux'

                        # increment
                        count += 1

                        # Write header
                        membuffer.write(
                            'type' + ',' + 'serialnum' + ',' + 'hostname' + ',' + 'OStype' + ',' +
                            'logical_cpus' + ',' + 'virtual_cpus' + ',' + 'ZZZZ' + ',' + 'interval' + ',' +
                            'snapshots' + ',' + header + '\n'),

                # Extract timestamp

                # Nmon V9 and prior do not have date in ZZZZ
                # If unavailable, we'll use the global date (AAA,date)
                ZZZZ_DATE = '-1'
                ZZZZ_TIME = '-1'

                # For Nmon V10 and more

                timestamp_match = re.match(r'^ZZZZ,(.+),(.+),(.+)\n', line)
                if timestamp_match:
                    ZZZZ_TIME = timestamp_match.group(2)
                    ZZZZ_DATE = timestamp_match.group(3)

                    # Replace month names with numbers
                    ZZZZ_DATE = monthtonumber(ZZZZ_DATE)

                    ZZZZ_timestamp = ZZZZ_DATE + ' ' + ZZZZ_TIME

                    if is_windows:
                        ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))
                    else:
                        ZZZZ_epochtime = datetime.datetime.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S').strftime('%s')

                        # in case datetime fails
                        if ZZZZ_epochtime == "%s":
                            ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))

                # For Nmon V9 and less

                if ZZZZ_DATE == '-1':
                    ZZZZ_DATE = DATE
                    timestamp_match = re.match(r'^ZZZZ,(.+),(.+)\n', line)

                    if timestamp_match:
                        ZZZZ_TIME = timestamp_match.group(2)

                        # Replace month names with numbers
                        ZZZZ_DATE = monthtonumber(ZZZZ_DATE)

                        ZZZZ_timestamp = ZZZZ_DATE + ' ' + ZZZZ_TIME

                        if is_windows:
                            ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))
                        else:
                            ZZZZ_epochtime = datetime.datetime.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')\
                                .strftime('%s')

                            # in case datetime fails
                            if ZZZZ_epochtime == "%s":
                                ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))

            if oslevel == 'Linux':  # Linux OS specific header

                # Extract Data
                perfdata_match = re.match('^UARG,T\d+,([0-9]*),([a-zA-Z\-/_:\.0-9]*),(.+)\n', line)

                if perfdata_match:
                    # In this section, we statically expect 3 fields: PID,ProgName,FullCommand
                    # The FullCommand may be very problematic as it may almost contain any kind of char, comma included
                    # Let's separate groups and insert " delimiter

                    perfdata_part1 = perfdata_match.group(1)
                    perfdata_part2 = perfdata_match.group(2)
                    perfdata_part3 = perfdata_match.group(3)
                    perfdata = perfdata_part1 + ',' + perfdata_part2 + ',"' + perfdata_part3 + '"'

                    if realtime:

                        if ZZZZ_epochtime > last_known_epochtime:

                            # increment
                            count += 1

                            # Write perf data
                            membuffer.write(
                                section + ',' + SN + ',' + HOSTNAME + ',' + OStype + ',' + logical_cpus + ',' +
                                virtual_cpus + ',' + ZZZZ_timestamp + ',' + INTERVAL + ',' + SNAPSHOTS + ',' +
                                perfdata + '\n'),

                    elif colddata:

                        # increment
                        count += 1

                        # Write perf data
                        membuffer.write(
                            section + ',' + SN + ',' + HOSTNAME + ',' + OStype + ',' + logical_cpus + ',' +
                            virtual_cpus + ',' + ZZZZ_timestamp + ',' + INTERVAL + ',' + SNAPSHOTS + ',' +
                            perfdata + '\n'),

            if oslevel == 'AIX_or_Solaris':  # AIX and Solaris OS specific header

                # Extract Data
                perfdata_match = re.match(
                    '^UARG,T\d+,\s*([0-9]*)\s*,\s*([0-9]*)\s*,\s*([a-zA-Z-/_:\.0-9]*)\s*,\s*([0-9]*)\s*,\s*([a-zA-Z-/_:'
                    '\.0-9]*\s*),\s*([a-zA-Z-/_:\.0-9]*)\s*,(.+)\n',
                    line)

                if perfdata_match:
                    # In this section, we statically expect 7 fields: PID,PPID,COMM,THCOUNT,USER,GROUP,FullCommand
                    # The FullCommand may be very problematic as it may almost contain any kind of char, comma included
                    # This field will have " separator added

                    perfdata_part1 = perfdata_match.group(1)
                    perfdata_part2 = perfdata_match.group(2)
                    perfdata_part3 = perfdata_match.group(3)
                    perfdata_part4 = perfdata_match.group(4)
                    perfdata_part5 = perfdata_match.group(5)
                    perfdata_part6 = perfdata_match.group(6)
                    perfdata_part7 = perfdata_match.group(7)

                    perfdata = perfdata_part1 + ',' + perfdata_part2 + ',' + perfdata_part3 + ',' + perfdata_part4 +\
                               ',' + perfdata_part5 + ',' + perfdata_part6 + ',"' + perfdata_part7 + '"'

                    if realtime:

                        if ZZZZ_epochtime > last_epoch_filter:

                            # increment
                            count += 1

                            # Write perf data
                            membuffer.write(
                                section + ',' + SN + ',' + HOSTNAME + ',' + OStype + ',' + logical_cpus + ',' +
                                virtual_cpus + ',' + ZZZZ_timestamp + ',' + INTERVAL + ',' + SNAPSHOTS + ',' +
                                perfdata + '\n'),
                        else:
                            if debug:
                                print ("DEBUG, " + section + " ignoring event " + ZZZZ_timestamp +
                                " ( " + ZZZZ_epochtime + " is lower than last known epoch time "
                                                        "for this section " + last_epoch_filter + " )")

                    elif colddata:

                        # increment
                        count += 1

                        # Write perf data
                        membuffer.write(
                            section + ',' + SN + ',' + HOSTNAME + ',' + OStype + ',' + logical_cpus + ',' +
                            virtual_cpus + ',' + ZZZZ_timestamp + ',' + INTERVAL + ',' + SNAPSHOTS + ',' +
                            perfdata + '\n'),

        # Verify that the number of lines is at least 2 lines which should be the case if we are here (header + data)
        # In any case, don't allow empty files to kept in repository
        if count >= 1:
            # Show number of lines extracted
            result = section + " section: Wrote" + " " + str(count) + " lines"
            print(result)
            ref.write(result + "\n")

            # In realtime, Store last epoch time for this section
            if realtime:
                with open(keyref, "wb") as f:
                    f.write("last_epoch: " + str(ZZZZ_epochtime) + "\n")

            # Open output for writing
            with open(currsection_output, "wb") as currsection:

                # Rewind temp
                membuffer.seek(0)

                # write
                for line in membuffer:
                    currsection.write(line)

                # close membuffer
                membuffer.close()

# End for

if OStype in ('AIX', 'Linux', 'Solaris', 'Unknown'):
    for section in uarg_section:
        uarg_section_fn(section)

###################
# Dynamic Sections : data requires to be transposed to be exploitable within Splunk
###################


def dynamic_section_fn(section):

    # Set output file (will be opened for writing after data transposition)
    currsection_output = DATA_DIR + HOSTNAME + '_' + day + '_' + month + '_' + year + '_' + hour + minute + second +\
                         '_' + section + '_' + str(bytes_total) + '_' + csv_timestamp + '.nmon.csv'

    # Sequence to search for
    seq = str(section) + ',' + 'T'

    # Store last epochtime if in real time mode
    keyref = HOSTNAME_VAR + '/' + HOSTNAME + '.' + section + '_lastepoch.txt'

    if realtime:
        if not os.path.exists(keyref):
            if debug:
                print ("DEBUG, no keyref file for this " + section +
                       " section (searched for " + keyref + "), no data or first execution")
        else:
            with open(keyref, "r") as f:
                for line in f:
                    myregex = 'last_epoch:\s(\d+)'
                    myregex_match = re.search(myregex, line)

                    # Standard header extraction
                    if myregex_match:
                        last_epoch_persection = myregex_match.group(1)

                        if debug:
                            print("DEBUG, Last known timestamp for " + section +
                                  " section is " + last_epoch_persection)

        # In realtime mode, in case no per section information is available, let's use global epoch time
        try:
            last_epoch_persection
        except NameError:
            if debug:
                print ("DEBUG: no last epoch information were found for " + section +
                       " , using global last epoch time (gaps in data may occur if not the first time we run)")
            last_epoch_filter = last_known_epochtime
        else:
            if debug:
                print ("DEBUG: Using per section last epoch time for event filtering (no gaps in data should occur)")
            last_epoch_filter = last_epoch_persection

    # counter
    count = 0

    # sanity_check
    sanity_check = 1

    # Initialize num_cols_header to 0 (see sanity_check)
    num_cols_header = 0

    for line in data:

        # Extract sections
        if str(seq) in line:  # Don't use regex here for more performance

            # increment
            count += 1

    if count >= 1:

        # Open StringIO for temp in memory
        membuffer = cStringIO.StringIO()

        # counter
        count = 0

        for line in data:

            # Extract sections, and write to output
            myregex = r'^' + section + '[0-9]*' + '|ZZZZ.+'
            find_section = re.match(myregex, line)

            if find_section:

                line = subpctreplace(line)
                line = subreplace(line)

                # csv header

                # Extract header excluding data that always has Txxxx for timestamp reference
                myregex = '(' + section + ')\,([^T].+)'
                fullheader_match = re.search(myregex, line)

                if fullheader_match:
                    fullheader = fullheader_match.group(2)

                    # Replace "." by "_" only for header
                    fullheader = re.sub("\.", '_', fullheader)

                    # Replace any blank space before comma only for header
                    fullheader = re.sub(", ", ',', fullheader)

                    # Remove any blank space still present in header
                    fullheader = re.sub(" ", '', fullheader)

                    header_match = re.match(r'([a-zA-Z\-/_0-9]+,)([a-zA-Z\-/_0-9,]*)', fullheader)

                    if header_match:
                        header = header_match.group(2)

                        final_header = 'ZZZZ' + ',' + header + '\n'

                        # increment
                        count += 1

                        # Number of separators in final header
                        num_cols_header = final_header.count(',')

                        # Write header
                        membuffer.write(final_header),

                # Extract timestamp

                # Nmon V9 and prior do not have date in ZZZZ
                # If unavailable, we'll use the global date (AAA,date)
                ZZZZ_DATE = '-1'
                ZZZZ_TIME = '-1'

                # For Nmon V10 and more

                timestamp_match = re.match(r'^ZZZZ,(.+),(.+),(.+)\n', line)
                if timestamp_match:
                    ZZZZ_TIME = timestamp_match.group(2)
                    ZZZZ_DATE = timestamp_match.group(3)

                    # Replace month names with numbers
                    ZZZZ_DATE = monthtonumber(ZZZZ_DATE)

                    ZZZZ_timestamp = ZZZZ_DATE + ' ' + ZZZZ_TIME

                    if is_windows:
                        ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))
                    else:
                        ZZZZ_epochtime = datetime.datetime.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S').strftime('%s')

                        # in case datetime fails
                        if ZZZZ_epochtime == "%s":
                            ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))

                # For Nmon V9 and less

                if ZZZZ_DATE == '-1':
                    ZZZZ_DATE = DATE
                    timestamp_match = re.match(r'^ZZZZ,(.+),(.+)\n', line)

                    if timestamp_match:
                        ZZZZ_TIME = timestamp_match.group(2)

                        # Replace month names with numbers
                        ZZZZ_DATE = monthtonumber(ZZZZ_DATE)

                        ZZZZ_timestamp = ZZZZ_DATE + ' ' + ZZZZ_TIME

                        if is_windows:
                            ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))
                        else:
                            ZZZZ_epochtime = datetime.datetime.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')\
                                .strftime('%s')

                            # in case datetime fails
                            if ZZZZ_epochtime == "%s":
                                ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))

                # Extract Data
                myregex = r'^' + section + '\,(T\d+)\,(.+)\n'
                perfdata_match = re.match(myregex, line)
                if perfdata_match:
                    perfdata = perfdata_match.group(2)

                    # final perfdata
                    final_perfdata = ZZZZ_timestamp + ',' + perfdata + '\n'

                    if realtime:

                        if ZZZZ_epochtime > last_epoch_filter:

                            # increment
                            count += 1

                            # Analyse the first line of data: Compare number of fields in data with number of fields
                            # in header
                            # If the number of fields is higher than header, we assume this section is not consistent
                            # and will be entirely dropped
                            # This happens in rare times (mainly with old buggy nmon version) that the header is bad
                            # formatted (for example missing comma between fields identification)
                            # For performance purposes, we will test this only with first line of data and assume
                            # the data sanity based on this result
                            if count == 2:

                                # Number of separators in final header
                                num_cols_perfdata = final_perfdata.count(',')

                                if num_cols_perfdata > num_cols_header:

                                    msg = 'ERROR: hostname: ' + HOSTNAME + ' :' + section +\
                                          ' section data is not consistent: ' + str(num_cols_perfdata) +\
                                          ' fields in data, ' + str(num_cols_header) +\
                                          ' fields in header, extra fields detected (more fields in data than header)' \
                                          ', dropping this section to prevent data inconsistency'
                                    print(msg)
                                    ref.write(msg + "\n")

                                    if debug:
                                        print("\nDebug information: header content:\n")
                                        print(final_header)
                                        print("\nDebug information: data sample:\n")
                                        print(final_perfdata +"\n")

                                    # Affect a sanity check to 1, bad data
                                    sanity_check = 1

                                else:

                                    # Affect a sanity check to 0, good data
                                    sanity_check = 0

                            # Write perf data
                            membuffer.write(ZZZZ_timestamp + ',' + perfdata + '\n'),
                        else:
                            if debug:
                                print ("DEBUG, " + section + " ignoring event " + ZZZZ_timestamp +
                                " ( " + ZZZZ_epochtime + " is lower than last known epoch time for this section " +
                                       last_epoch_filter + " )")

                    elif colddata:

                        # increment
                        count += 1

                        # Analyse the first line of data: Compare number of fields in data with number of fields
                        # in header
                        # If the number of fields is higher than header, we assume this section is not consistent and
                        # will be entirely dropped
                        # This happens in rare times (mainly with old buggy nmon version) that the header is bad
                        # formatted (for example missing comma between fields identification)
                        # For performance purposes, we will test this only with first line of data and assume the data
                        # sanity based on this result
                        if count == 2:

                            # Number of separators in final header
                            num_cols_perfdata = final_perfdata.count(',')

                            if num_cols_perfdata > num_cols_header:

                                msg = 'ERROR: hostname: ' + HOSTNAME + ' :' + section +\
                                      ' section data is not consistent: ' + str(num_cols_perfdata) +\
                                      ' fields in data, ' + str(num_cols_header) +\
                                      ' fields in header, extra fields detected (more fields in data than header),' \
                                      ' dropping this section to prevent data inconsistency'
                                print(msg)
                                ref.write(msg + "\n")

                                if debug:
                                    print("\nDebug information: header content:")
                                    print(final_header)
                                    print("Debug information: data sample:")
                                    print(final_perfdata)

                                # Affect a sanity check to 1, bad data
                                sanity_check = 1

                            else:

                                # Affect a sanity check to 0, good data
                                sanity_check = 0

                        # Write perf data
                        membuffer.write(ZZZZ_timestamp + ',' + perfdata + '\n'),

        if sanity_check == 0:

            # Reset counter
            count = 0

            # Open final for writing
            with open(currsection_output, "wb") as currsection:

                # Rewind temp
                membuffer.seek(0)

                writer = csv.writer(currsection)
                writer.writerow(
                    ['type', 'serialnum', 'hostname', 'OStype', 'interval', 'snapshots', 'ZZZZ', 'device',
                     'value'])

                # increment
                count += 1

                for d in csv.DictReader(membuffer):
                    ZZZZ = d.pop('ZZZZ')
                    for device, value in sorted(d.items()):
                        # increment
                        count += 1

                        row = [section, SN, HOSTNAME, OStype, INTERVAL, SNAPSHOTS, ZZZZ, device, value]
                        writer.writerow(row)

                        # End for

            # Verify that the number of lines is at least 2 lines which should be the case if
            #  we are here (header + data)
            # In any case, don't allow empty files to kept in repository
            if count < 1:
                if os.path.isfile(currsection_output):
                    os.remove(currsection_output)
            else:
                # Show number of lines extracted
                result = section + " section: Wrote" + " " + str(count) + " lines"
                print(result)
                ref.write(result + "\n")

            # In realtime, Store last epoch time for this section
            if realtime:
                with open(keyref, "wb") as f:
                    f.write("last_epoch: " + str(ZZZZ_epochtime) + "\n")

            # Discard memory membuffer
            membuffer.close()

        elif sanity_check == 0:

            # Discard memory membuffer
            membuffer.close()

            # End for

###################
# Disk* Dynamic Sections : data requires to be transposed to be exploitable within Splunk
###################

# Because Big systems can a very large number of drives, Nmon create a new section for each step of 150 devices
# We allow up to 20 x 150 devices to be managed
# This will create a csv for each section (DISKBUSY, DISKBUSY1...), Splunk will manage this using a wildcard when
# searching for data
for section in dynamic_section1:
    dynamic_section_fn(section)

# Then proceed to sub section if any
for subsection in dynamic_section1:

    persubsection = [subsection + "1", subsection + "2", subsection + "3", subsection + "4", subsection + "5",
                  subsection + "6", subsection + "7", subsection + "8", subsection + "9", subsection + "10",
                  subsection + "11", subsection + "12", subsection + "13", subsection + "14", subsection + "15",
                  subsection + "17", subsection + "18", subsection + "19"]

    for section in persubsection:
        dynamic_section_fn(section)

###################
# Other Dynamic Sections : data requires to be transposed to be exploitable within Splunk
###################

for section in dynamic_section2:
    dynamic_section_fn(section)

###################
# AIX Only Dynamic Sections : data requires to be transposed to be exploitable within Splunk
###################

# Run
if OStype in ("AIX", "Unknown"):
    for section in AIX_dynamic_various:
        dynamic_section_fn(section)
    for section in AIX_WLM:
        dynamic_section_fn(section)

###################
# Solaris Sections : data requires to be transposed to be exploitable within Splunk
###################

# Specially for WLM Solaris section, we will add the number of logical CPUs to allow evaluation of % CPU
# report in logical CPU


def solaris_wlm_section_fn(section):

    # Set output file (will be opened for writing after data transposition)
    currsection_output = DATA_DIR + HOSTNAME + '_' + day + '_' + month + '_' + year + '_' + hour + minute + second +\
                         '_' + section + '_' + str(bytes_total) + '_' + csv_timestamp + '.nmon.csv'

    # Sequence to search for
    seq = str(section) + ',' + 'T'

    # Store last epochtime if in real time mode
    keyref = HOSTNAME_VAR + '/' + HOSTNAME + '.' + section + '_lastepoch.txt'

    if realtime:
        if not os.path.exists(keyref):
            if debug:
                print ("DEBUG, no keyref file for this " + section +
                       " section (searched for " + keyref + "), no data or first execution")
        else:
            with open(keyref, "r") as f:
                for line in f:
                    myregex = 'last_epoch:\s(\d+)'
                    myregex_match = re.search(myregex, line)

                    # Standard header extraction
                    if myregex_match:
                        last_epoch_persection = myregex_match.group(1)

                        if debug:
                            print("DEBUG, Last known timestamp for " + section +
                                  " section is " + last_epoch_persection)

        # In realtime mode, in case no per section information is available, let's use global epoch time
        try:
            last_epoch_persection
        except NameError:
            if debug:
                print ("DEBUG: no last epoch information were found for " + section +
                       " , using global last epoch time (gaps in data may occur if not the first time we run)")
            last_epoch_filter = last_known_epochtime
        else:
            if debug:
                print ("DEBUG: Using per section last epoch time for event filtering (no gaps in data should occur)")
            last_epoch_filter = last_epoch_persection

    # counter
    count = 0

    # sanity_check
    sanity_check = 1
    
    # Initialize num_cols_header to 0 (see sanity_check)
    num_cols_header = 0

    for line in data:

        # Extract sections
        if str(seq) in line:  # Don't use regex here for more performance

            # increment
            count += 1

    if count >= 1:

        # Open StringIO for temp in memory
        membuffer = cStringIO.StringIO()

        # counter
        count = 0

        for line in data:

            # Extract sections, and write to output
            myregex = r'^' + section + '[0-9]*' + '|ZZZZ.+'
            find_section = re.match(myregex, line)

            if find_section:

                line = subpctreplace(line)
                line = subreplace(line)

                # csv header

                # Extract header excluding data that always has Txxxx for timestamp reference
                myregex = '(' + section + ')\,([^T].+)'
                fullheader_match = re.search(myregex, line)

                if fullheader_match:
                    fullheader = fullheader_match.group(2)

                    # Replace "." by "_" only for header
                    fullheader = re.sub("\.", '_', fullheader)

                    # Replace any blank space before comma only for header
                    fullheader = re.sub(", ", ',', fullheader)

                    # Remove any blank space still present in header
                    fullheader = re.sub(" ", '', fullheader)

                    header_match = re.match(r'([a-zA-Z\-/_0-9]+,)([a-zA-Z\-/_0-9,]*)', fullheader)

                    if header_match:
                        header = header_match.group(2)

                        final_header = 'ZZZZ' + ',' + header + '\n'

                        # increment
                        count += 1

                        # Number of separators in final header
                        num_cols_header = final_header.count(',')

                        # Write header
                        membuffer.write(final_header),

                # Extract timestamp

                # Nmon V9 and prior do not have date in ZZZZ
                # If unavailable, we'll use the global date (AAA,date)
                ZZZZ_DATE = '-1'
                ZZZZ_TIME = '-1'

                # For Nmon V10 and more

                timestamp_match = re.match(r'^ZZZZ,(.+),(.+),(.+)\n', line)
                if timestamp_match:
                    ZZZZ_TIME = timestamp_match.group(2)
                    ZZZZ_DATE = timestamp_match.group(3)

                    # Replace month names with numbers
                    ZZZZ_DATE = monthtonumber(ZZZZ_DATE)

                    ZZZZ_timestamp = ZZZZ_DATE + ' ' + ZZZZ_TIME

                    if is_windows:
                        ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))
                    else:
                        ZZZZ_epochtime = datetime.datetime.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S').strftime('%s')

                        # in case datetime fails
                        if ZZZZ_epochtime == "%s":
                            ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))

                # For Nmon V9 and less

                if ZZZZ_DATE == '-1':
                    ZZZZ_DATE = DATE
                    timestamp_match = re.match(r'^ZZZZ,(.+),(.+)\n', line)

                    if timestamp_match:
                        ZZZZ_TIME = timestamp_match.group(2)

                        # Replace month names with numbers
                        ZZZZ_DATE = monthtonumber(ZZZZ_DATE)

                        ZZZZ_timestamp = ZZZZ_DATE + ' ' + ZZZZ_TIME

                        if is_windows:
                            ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))
                        else:
                            ZZZZ_epochtime = datetime.datetime.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S').\
                                strftime('%s')

                            # in case datetime fails
                            if ZZZZ_epochtime == "%s":
                                ZZZZ_epochtime = int(time.mktime(time.strptime(ZZZZ_timestamp, '%d-%m-%Y %H:%M:%S')))

                # Extract Data
                myregex = r'^' + section + '\,(T\d+)\,(.+)\n'
                perfdata_match = re.match(myregex, line)
                if perfdata_match:
                    perfdata = perfdata_match.group(2)

                    # final perfdata
                    final_perfdata = ZZZZ_timestamp + ',' + perfdata + '\n'

                    if realtime:

                        if ZZZZ_epochtime > last_epoch_filter:

                            # increment
                            count += 1

                            # Analyse the first line of data: Compare number of fields in data with number of fields
                            # in header
                            # If the number of fields is higher than header, we assume this section is not consistent
                            # and will be entirely dropped
                            # This happens in rare times (mainly with old buggy nmon version) that the header is
                            # bad formatted (for example missing comma between fields identification)
                            # For performance purposes, we will test this only with first line of data and assume
                            # the data sanity based on this result
                            if count == 2:

                                # Number of separators in final header
                                num_cols_perfdata = final_perfdata.count(',')

                                if num_cols_perfdata > num_cols_header:

                                    msg = 'ERROR: hostname: ' + HOSTNAME + ' :' + section +\
                                          ' section data is not consistent: ' + str(num_cols_perfdata) +\
                                          ' fields in data, ' + str(num_cols_header) +\
                                          ' fields in header, extra fields detected (more fields in data than header)' \
                                          ', dropping this section to prevent data inconsistency'
                                    print(msg)
                                    ref.write(msg + "\n")

                                    if debug:
                                        print("\nDebug information: header content:")
                                        print(final_header)
                                        print("Debug information: data sample:")
                                        print(final_perfdata)

                                    # Affect a sanity check to 1, bad data
                                    sanity_check = 1

                                else:

                                    # Affect a sanity check to 0, good data
                                    sanity_check = 0

                            # Write perf data
                            membuffer.write(ZZZZ_timestamp + ',' + perfdata + '\n'),

                        else:
                            if debug:
                                print ("DEBUG, " + section + " ignoring event " + ZZZZ_timestamp +
                                " ( " + ZZZZ_epochtime + " is lower than last known epoch time for this section " +
                                       last_epoch_filter + " )")

                    elif colddata:

                        # increment
                        count += 1

                        # Analyse the first line of data: Compare number of fields in data with number of fields
                        # in header
                        # If the number of fields is higher than header, we assume this section is not consistent
                        # and will be entirely dropped
                        # This happens in rare times (mainly with old buggy nmon version) that the header is bad
                        # formatted (for example missing comma between fields identification)
                        # For performance purposes, we will test this only with first line of data and assume the
                        # data sanity based on this result
                        if count == 2:

                            # Number of separators in final header
                            num_cols_perfdata = final_perfdata.count(',')

                            if num_cols_perfdata > num_cols_header:

                                msg = 'ERROR: hostname: ' + HOSTNAME + ' :' + section +\
                                      ' section data is not consistent: ' + str(num_cols_perfdata) +\
                                      ' fields in data, ' + str(num_cols_header) +\
                                      ' fields in header, extra fields detected (more fields in data than header),' \
                                      ' dropping this section to prevent data inconsistency'
                                print(msg)
                                ref.write(msg + "\n")

                                if debug:
                                    print("\nDebug information: header content:")
                                    print(final_header)
                                    print("Debug information: data sample:")
                                    print(final_perfdata)

                                # Affect a sanity check to 1, bad data
                                sanity_check = 1

                            else:

                                # Affect a sanity check to 0, good data
                                sanity_check = 0

                        # Write perf data
                        membuffer.write(ZZZZ_timestamp + ',' + perfdata + '\n'),

        if sanity_check == 0:

            # Reset counter
            count = 0

            # Open final for writing
            with open(currsection_output, "wb") as currsection:

                # Rewind temp
                membuffer.seek(0)

                writer = csv.writer(currsection)
                writer.writerow(
                    ['type', 'serialnum', 'hostname', 'OStype', 'logical_cpus', 'interval', 'snapshots',
                     'ZZZZ', 'device', 'value'])

                # increment
                count += 1

                for d in csv.DictReader(membuffer):
                    ZZZZ = d.pop('ZZZZ')
                    for device, value in sorted(d.items()):
                        # increment
                        count += 1

                        row = [section, SN, HOSTNAME, OStype, logical_cpus, INTERVAL, SNAPSHOTS,
                               ZZZZ, device, value]
                        writer.writerow(row)

                        # End for

            # Verify that the number of lines is at least 2 lines which should be the case if we are
            # here (header + data)
            # In any case, don't allow empty files to kept in repository
            if count < 1:
                if os.path.isfile(currsection_output):
                    os.remove(currsection_output)
            else:
                # Show number of lines extracted
                result = section + " section: Wrote" + " " + str(count) + " lines"
                print(result)
                ref.write(result + "\n")

            # In realtime, Store last epoch time for this section
            if realtime:
                with open(keyref, "wb") as f:
                    f.write("last_epoch: " + str(ZZZZ_epochtime) + "\n")

            # Discard memory membuffer
            membuffer.close()

        elif sanity_check == 0:

            # Discard memory membuffer
            membuffer.close()

            # End for

# Run
if OStype in ("Solaris", "Unknown"):
    for section in solaris_WLM:
        solaris_wlm_section_fn(section)

    for section in solaris_VxVM:
        dynamic_section_fn(section)

    for section in solaris_dynamic_various:
        dynamic_section_fn(section)

##########################
# Move final Perf csv data
##########################

# cd to directory
os.chdir(DATA_DIR)

# Move csv final perf data
for xfile in glob.glob('*.csv'):
    src = DATA_DIR + xfile
    dst = DATAFINAL_DIR + xfile
    os.rename(src, dst)

###################
# End
###################

# Time required to process
end_time = time.time()
result = "Elapsed time was: %g seconds" % (end_time - start_time)
print(result)
ref.write(result + "\n")

# exit
sys.exit(0)
