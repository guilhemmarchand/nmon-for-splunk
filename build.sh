#!/usr/bin/env bash
# set -x

PWD=`pwd`
app="nmon-performance-monitor-for-unix-and-linux-systems"
version=`grep 'version =' nmon/default/app.conf | awk '{print $3}' | sed 's/\.//g'`

tar -czf ${app}_${version}.tgz --exclude=nmon/local --exclude=nmon/metadata/local.meta --exclude=nmon/lookups/lookup_file_backups nmon
echo "Wrote: ${app}_${version}.tgz"

exit 0
