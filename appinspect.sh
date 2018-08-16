#!/bin/bash

splunk-appinspect inspect `ls nmon-performance-monitor-*.tgz | head -1` --mode precert --included-tags splunk_appinspect
