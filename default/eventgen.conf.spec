[config_sample]
interval = 15
earliest = -15s
latest = now
count = 10
hourOfDayRate = { "0": 0.8, "1": 1.0, "2": 0.9, "3": 0.7, "4": 0.5, "5": 0.4, "6": 0.4, "7": 0.4, "8": 0.4, "9": 0.4, "10": 0.4, "11": 0.4, "12": 0.4, "13": 0.4, "14": 0.4, "15": 0.4, "16": 0.4, "17": 0.4, "18": 0.4, "19": 0.4, "20": 0.4, "21": 0.4, "22": 0.5, "23": 0.6 }
dayOfWeekRate = { "0": 0.7, "1": 0.7, "2": 0.7, "3": 0.5, "4": 0.5, "5": 1.0, "6": 1.0 }
randomizeCount = 0.2
randomizeEvents = true
mode = sample
sampletype = raw
bundlelines = true
outputMode = splunkstream
splunkHost = localhost
splunkUser = admin
splunkPass = changeme
index=nmon
host=samplehost
sourcetype=nmon_config
## Replace timestamp
token.0.token = \d*-\w*-\d{4}:\d{2}:\d{2}
token.0.replacementType = timestamp
token.0.replacement = %d-%b-%Y:%H:%M

[collect_sample]
interval = 15
earliest = -15s
latest = now
count = 10
hourOfDayRate = { "0": 0.8, "1": 1.0, "2": 0.9, "3": 0.7, "4": 0.5, "5": 0.4, "6": 0.4, "7": 0.4, "8": 0.4, "9": 0.4, "10": 0.4, "11": 0.4, "12": 0.4, "13": 0.4, "14": 0.4, "15": 0.4, "16": 0.4, "17": 0.4, "18": 0.4, "19": 0.4, "20": 0.4, "21": 0.4, "22": 0.5, "23": 0.6 }
dayOfWeekRate = { "0": 0.7, "1": 0.7, "2": 0.7, "3": 0.5, "4": 0.5, "5": 1.0, "6": 1.0 }
randomizeCount = 0.2
randomizeEvents = true
mode = sample
sampletype = raw
outputMode = splunkstream
splunkHost = localhost
splunkUser = admin
splunkPass = changeme
index=nmon
host=samplehost
sourcetype=nmon_collect
## Replace timestamp
token.0.token = \d*-\w*-\d{4}:\d{2}:\d{2}
token.0.replacementType = timestamp
token.0.replacement = %d-%b-%Y:%H:%M

[AIX_CPU_ALL_sample]
interval = 15
earliest = -15s
backfill = -1h
latest = now
count = 100
hourOfDayRate = { "0": 0.8, "1": 1.0, "2": 0.9, "3": 0.7, "4": 0.5, "5": 0.4, "6": 0.4, "7": 0.4, "8": 0.4, "9": 0.4, "10": 0.4, "11": 0.4, "12": 0.4, "13": 0.4, "14": 0.4, "15": 0.4, "16": 0.4, "17": 0.4, "18": 0.4, "19": 0.4, "20": 0.4, "21": 0.4, "22": 0.5, "23": 0.6 }
dayOfWeekRate = { "0": 0.7, "1": 0.7, "2": 0.7, "3": 0.5, "4": 0.5, "5": 1.0, "6": 1.0 }
randomizeCount = 0.2
randomizeEvents = true
mode = sample
sampletype = csv
spoolFile = AIX_CPU_ALL_sample.csv
outputMode = spool
spoolDir = $SPLUNK_HOME/etc/apps/nmon/samples/spool/csv_repository
## Replace timestamp
token.0.token = \d*-\d*-\d{4}\s\d{2}:\d{2}:\d{2}
token.0.replacementType = timestamp
token.0.replacement = %d-%m-%Y %H:%M:%S

[AIX_LPAR_sample]
interval = 15
earliest = -15s
backfill = -1h
latest = now
count = 100
hourOfDayRate = { "0": 0.8, "1": 1.0, "2": 0.9, "3": 0.7, "4": 0.5, "5": 0.4, "6": 0.4, "7": 0.4, "8": 0.4, "9": 0.4, "10": 0.4, "11": 0.4, "12": 0.4, "13": 0.4, "14": 0.4, "15": 0.4, "16": 0.4, "17": 0.4, "18": 0.4, "19": 0.4, "20": 0.4, "21": 0.4, "22": 0.5, "23": 0.6 }
dayOfWeekRate = { "0": 0.7, "1": 0.7, "2": 0.7, "3": 0.5, "4": 0.5, "5": 1.0, "6": 1.0 }
randomizeCount = 0.2
randomizeEvents = true
mode = sample
sampletype = csv
spoolFile = AIX_LPAR_sample.csv
outputMode = spool
spoolDir = $SPLUNK_HOME/etc/apps/nmon/samples/spool/csv_repository
## Replace timestamp
token.0.token = \d*-\d*-\d{4}\s\d{2}:\d{2}:\d{2}
token.0.replacementType = timestamp
token.0.replacement = %d-%m-%Y %H:%M:%S

[AIX_MEM_sample]
interval = 15
earliest = -15s
backfill = -1h
latest = now
count = 100
hourOfDayRate = { "0": 0.8, "1": 1.0, "2": 0.9, "3": 0.7, "4": 0.5, "5": 0.4, "6": 0.4, "7": 0.4, "8": 0.4, "9": 0.4, "10": 0.4, "11": 0.4, "12": 0.4, "13": 0.4, "14": 0.4, "15": 0.4, "16": 0.4, "17": 0.4, "18": 0.4, "19": 0.4, "20": 0.4, "21": 0.4, "22": 0.5, "23": 0.6 }
dayOfWeekRate = { "0": 0.7, "1": 0.7, "2": 0.7, "3": 0.5, "4": 0.5, "5": 1.0, "6": 1.0 }
randomizeCount = 0.2
randomizeEvents = true
mode = sample
sampletype = csv
spoolFile = AIX_MEM_sample.csv
outputMode = spool
spoolDir = $SPLUNK_HOME/etc/apps/nmon/samples/spool/csv_repository
## Replace timestamp
token.0.token = \d*-\d*-\d{4}\s\d{2}:\d{2}:\d{2}
token.0.replacementType = timestamp
token.0.replacement = %d-%m-%Y %H:%M:%S

[Linux_CPU_ALL_sample]
interval = 15
earliest = -15s
backfill = -1h
latest = now
count = 100
hourOfDayRate = { "0": 0.8, "1": 1.0, "2": 0.9, "3": 0.7, "4": 0.5, "5": 0.4, "6": 0.4, "7": 0.4, "8": 0.4, "9": 0.4, "10": 0.4, "11": 0.4, "12": 0.4, "13": 0.4, "14": 0.4, "15": 0.4, "16": 0.4, "17": 0.4, "18": 0.4, "19": 0.4, "20": 0.4, "21": 0.4, "22": 0.5, "23": 0.6 }
dayOfWeekRate = { "0": 0.7, "1": 0.7, "2": 0.7, "3": 0.5, "4": 0.5, "5": 1.0, "6": 1.0 }
randomizeCount = 0.2
randomizeEvents = true
mode = sample
sampletype = csv
spoolFile = Linux_CPU_ALL_sample.csv
outputMode = spool
spoolDir = $SPLUNK_HOME/etc/apps/nmon/samples/spool/csv_repository
## Replace timestamp
token.0.token = \d*-\d*-\d{4}\s\d{2}:\d{2}:\d{2}
token.0.replacementType = timestamp
token.0.replacement = %d-%m-%Y %H:%M:%S

[Linux_MEM_sample]
interval = 15
earliest = -15s
backfill = -1h
latest = now
count = 100
hourOfDayRate = { "0": 0.8, "1": 1.0, "2": 0.9, "3": 0.7, "4": 0.5, "5": 0.4, "6": 0.4, "7": 0.4, "8": 0.4, "9": 0.4, "10": 0.4, "11": 0.4, "12": 0.4, "13": 0.4, "14": 0.4, "15": 0.4, "16": 0.4, "17": 0.4, "18": 0.4, "19": 0.4, "20": 0.4, "21": 0.4, "22": 0.5, "23": 0.6 }
dayOfWeekRate = { "0": 0.7, "1": 0.7, "2": 0.7, "3": 0.5, "4": 0.5, "5": 1.0, "6": 1.0 }
randomizeCount = 0.2
randomizeEvents = true
mode = sample
sampletype = csv
spoolFile = Linux_MEM_sample.csv
outputMode = spool
spoolDir = $SPLUNK_HOME/etc/apps/nmon/samples/spool/csv_repository
## Replace timestamp
token.0.token = \d*-\d*-\d{4}\s\d{2}:\d{2}:\d{2}
token.0.replacementType = timestamp
token.0.replacement = %d-%m-%Y %H:%M:%S

[Linux_TOP_sample]
interval = 15
earliest = -15s
backfill = -1h
latest = now
count = 100
hourOfDayRate = { "0": 0.8, "1": 1.0, "2": 0.9, "3": 0.7, "4": 0.5, "5": 0.4, "6": 0.4, "7": 0.4, "8": 0.4, "9": 0.4, "10": 0.4, "11": 0.4, "12": 0.4, "13": 0.4, "14": 0.4, "15": 0.4, "16": 0.4, "17": 0.4, "18": 0.4, "19": 0.4, "20": 0.4, "21": 0.4, "22": 0.5, "23": 0.6 }
dayOfWeekRate = { "0": 0.7, "1": 0.7, "2": 0.7, "3": 0.5, "4": 0.5, "5": 1.0, "6": 1.0 }
randomizeCount = 0.2
randomizeEvents = true
mode = sample
sampletype = csv
spoolFile = Linux_TOP_sample.csv
outputMode = spool
spoolDir = $SPLUNK_HOME/etc/apps/nmon/samples/spool/csv_repository
## Replace timestamp
token.0.token = \d*-\d*-\d{4}\s\d{2}:\d{2}:\d{2}
token.0.replacementType = timestamp
token.0.replacement = %d-%m-%Y %H:%M:%S

[Solaris_CPU_ALL_sample]
interval = 15
earliest = -15s
backfill = -1h
latest = now
count = 100
hourOfDayRate = { "0": 0.8, "1": 1.0, "2": 0.9, "3": 0.7, "4": 0.5, "5": 0.4, "6": 0.4, "7": 0.4, "8": 0.4, "9": 0.4, "10": 0.4, "11": 0.4, "12": 0.4, "13": 0.4, "14": 0.4, "15": 0.4, "16": 0.4, "17": 0.4, "18": 0.4, "19": 0.4, "20": 0.4, "21": 0.4, "22": 0.5, "23": 0.6 }
dayOfWeekRate = { "0": 0.7, "1": 0.7, "2": 0.7, "3": 0.5, "4": 0.5, "5": 1.0, "6": 1.0 }
randomizeCount = 0.2
randomizeEvents = true
mode = sample
sampletype = csv
spoolFile = Solaris_CPU_ALL_sample.csv
outputMode = spool
spoolDir = $SPLUNK_HOME/etc/apps/nmon/samples/spool/csv_repository
## Replace timestamp
token.0.token = \d*-\d*-\d{4}\s\d{2}:\d{2}:\d{2}
token.0.replacementType = timestamp
token.0.replacement = %d-%m-%Y %H:%M:%S

[Solaris_MEM_sample]
interval = 15
earliest = -15s
backfill = -1h
latest = now
count = 100
hourOfDayRate = { "0": 0.8, "1": 1.0, "2": 0.9, "3": 0.7, "4": 0.5, "5": 0.4, "6": 0.4, "7": 0.4, "8": 0.4, "9": 0.4, "10": 0.4, "11": 0.4, "12": 0.4, "13": 0.4, "14": 0.4, "15": 0.4, "16": 0.4, "17": 0.4, "18": 0.4, "19": 0.4, "20": 0.4, "21": 0.4, "22": 0.5, "23": 0.6 }
dayOfWeekRate = { "0": 0.7, "1": 0.7, "2": 0.7, "3": 0.5, "4": 0.5, "5": 1.0, "6": 1.0 }
randomizeCount = 0.2
randomizeEvents = true
mode = sample
sampletype = csv
spoolFile = Solaris_MEM_sample.csv
outputMode = spool
spoolDir = $SPLUNK_HOME/etc/apps/nmon/samples/spool/csv_repository
## Replace timestamp
token.0.token = \d*-\d*-\d{4}\s\d{2}:\d{2}:\d{2}
token.0.replacementType = timestamp
token.0.replacement = %d-%m-%Y %H:%M:%S

[Solaris_TOP_sample]
interval = 15
earliest = -15s
backfill = -1h
latest = now
count = 100
hourOfDayRate = { "0": 0.8, "1": 1.0, "2": 0.9, "3": 0.7, "4": 0.5, "5": 0.4, "6": 0.4, "7": 0.4, "8": 0.4, "9": 0.4, "10": 0.4, "11": 0.4, "12": 0.4, "13": 0.4, "14": 0.4, "15": 0.4, "16": 0.4, "17": 0.4, "18": 0.4, "19": 0.4, "20": 0.4, "21": 0.4, "22": 0.5, "23": 0.6 }
dayOfWeekRate = { "0": 0.7, "1": 0.7, "2": 0.7, "3": 0.5, "4": 0.5, "5": 1.0, "6": 1.0 }
randomizeCount = 0.2
randomizeEvents = true
mode = sample
sampletype = csv
spoolFile = Solaris_TOP_sample.csv
outputMode = spool
spoolDir = $SPLUNK_HOME/etc/apps/nmon/samples/spool/csv_repository
## Replace timestamp
token.0.token = \d*-\d*-\d{4}\s\d{2}:\d{2}:\d{2}
token.0.replacementType = timestamp
token.0.replacement = %d-%m-%Y %H:%M:%S

[Solaris_WLM_sample]
interval = 15
earliest = -15s
backfill = -1h
latest = now
count = 100
hourOfDayRate = { "0": 0.8, "1": 1.0, "2": 0.9, "3": 0.7, "4": 0.5, "5": 0.4, "6": 0.4, "7": 0.4, "8": 0.4, "9": 0.4, "10": 0.4, "11": 0.4, "12": 0.4, "13": 0.4, "14": 0.4, "15": 0.4, "16": 0.4, "17": 0.4, "18": 0.4, "19": 0.4, "20": 0.4, "21": 0.4, "22": 0.5, "23": 0.6 }
dayOfWeekRate = { "0": 0.7, "1": 0.7, "2": 0.7, "3": 0.5, "4": 0.5, "5": 1.0, "6": 1.0 }
randomizeCount = 0.2
randomizeEvents = true
mode = sample
sampletype = csv
spoolFile = Solaris_WLM_sample.csv
outputMode = spool
spoolDir = $SPLUNK_HOME/etc/apps/nmon/samples/spool/csv_repository
## Replace timestamp
token.0.token = \d*-\d*-\d{4}\s\d{2}:\d{2}:\d{2}
token.0.replacementType = timestamp
token.0.replacement = %d-%m-%Y %H:%M:%S

[DISKXFER_sample]
interval = 15
earliest = -15s
backfill = -1h
latest = now
count = 100
hourOfDayRate = { "0": 0.8, "1": 1.0, "2": 0.9, "3": 0.7, "4": 0.5, "5": 0.4, "6": 0.4, "7": 0.4, "8": 0.4, "9": 0.4, "10": 0.4, "11": 0.4, "12": 0.4, "13": 0.4, "14": 0.4, "15": 0.4, "16": 0.4, "17": 0.4, "18": 0.4, "19": 0.4, "20": 0.4, "21": 0.4, "22": 0.5, "23": 0.6 }
dayOfWeekRate = { "0": 0.7, "1": 0.7, "2": 0.7, "3": 0.5, "4": 0.5, "5": 1.0, "6": 1.0 }
randomizeCount = 0.2
randomizeEvents = true
mode = sample
sampletype = csv
spoolFile = DISKXFER_sample.csv
outputMode = spool
spoolDir = $SPLUNK_HOME/etc/apps/nmon/samples/spool/csv_repository
## Replace timestamp
token.0.token = \d*-\d*-\d{4}\s\d{2}:\d{2}:\d{2}
token.0.replacementType = timestamp
token.0.replacement = %d-%m-%Y %H:%M:%S
