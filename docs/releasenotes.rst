#########################################
Release notes
#########################################

^^^^^^^^^^^^
Requirements
^^^^^^^^^^^^

* Splunk 6.5.x and later Only, for 6.4.x and prior download release: V1.7.9, for prior to 6.2.x download release: V1.6.15, for 6.1.x and prior download release: V1.4.902

* Universal Forwarder v6.x is required for clients

* Universal Forwarders clients system lacking a Python 2.7.x interpreter requires Perl WITH Time::HiRes module available

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
What has been fixed by release
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

========
V1.9.17:
========

**Version 1.9.17**

- fix: JQuery vulnerability issue for the integrated viz addons (bullet chart amd radial meter, CVE-2016-10707/CVE-2015-9251) #114
- fix: KVstore collections management interfaces improvements #115
- fix: Nav improvement: merge search and builtin menu into search menu #116

========
V1.9.16:
========

**Version 1.9.16 - multiple updates #112**

- review props.conf sourcetypes definition for Splunk best practices
- update of horseshoe-meter and bullet-graph to their latest version
- removal of calendar heatmap views managing processing and nmon data availability
- New dashboard: Heatmap daily CPU usage calendar with drilldown
- New alerting scheme with multi-layer KVstore based: Threshold management, frameID mapping and thresholds templating
- Splunk 7.1 minor compatibility issues

========
V1.9.15:
========

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

This is a major release of the Nmon application and the TA-nmon:

Migration from 1.7.x and prior: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-7-x

Migration from 1.8.x: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-9-x

- fix: NMON_Data_PAGE data model issue: Comparator '=' has an invalid term #106
- fix: PAGE interface for AIX - duplicated ID #107

========
V1.9.14:
========

- intermediate release unpublished

========
V1.9.13:
========

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

This is a major release of the Nmon application and the TA-nmon:

Migration from 1.7.x and prior: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-7-x

Migration from 1.8.x: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-9-x

- fix: CONFIG DF dead link in home pages (was replaced by STORAGE ui in 1.9.12)
- fix: props.conf and Nmon config datamodel issue with AIX combo cpu #100
- fix: Nmon Summary dashboard - nmon_span referenced instead of variable #102
- feature request: allow deactivation for auto-refresh feature #103
- fix: Summary dashboard stacking issues with Splunk 7 #104

========
V1.9.12:
========

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

This is a major release of the Nmon application and the TA-nmon:

Migration from 1.7.x and prior: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-7-x

Migration from 1.8.x: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-9-x

- fix: Splunk certification requirements update, avoid global default parameter in ui-prefs.conf (config file has been removed) #98
- fix: Splunk certification requirements update, default activation of data model acceleration is now prohibited #98
- fix: DF_STORAGE vs JFSFILE compatibility for STORAGE UI and Dark monitoring

========
V1.9.11:
========

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

This is a major release of the Nmon application and the TA-nmon:

Migration from 1.7.x and prior: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-7-x

Migration from 1.8.x: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-9-x

For the TA-nmon complete release notes: http://ta-nmon.readthedocs.io/en/latest/releasenotes.html

- feature: DF_STORAGE and DF_INODES implementation in replacement of JFSFILE (extended file system utilisation statistics)
- feature: New interface for STORAGE statistics management
- feature: metric_catalog lookup implementation
- feature: review and refresh of various interfaces, including comparative and predictive interfaces
- fix: dynamic tokens in dashboard improvements
- fix: Nmon Config datamodel OStype extraction #95

========
V1.9.10:
========

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

This is a major release of the Nmon application and the TA-nmon:

Migration from 1.7.x and prior: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-7-x

Migration from 1.8.x: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-9-x

For the TA-nmon complete release notes: http://ta-nmon.readthedocs.io/en/latest/releasenotes.html

- feature: index and search time configuration for the TA-nmon-hec / nmon-logger-splunk-hec (agent less package using the Splunk http input)
- fix: UI Compare - fix frameID mapping for non CSV source data (nmon-logger) #92
- fix: UI Predictive - issue when time range is changed, bad MEM metric label #93
- fix: UI Summary / WOF - token auto-selection issue when time range is changed #94

=======
V1.9.9:
=======

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

This is a major release of the Nmon application and the TA-nmon:

Migration from 1.7.x and prior: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-7-x

Migration from 1.8.x: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-9-x

For the TA-nmon complete release notes: http://ta-nmon.readthedocs.io/en/latest/releasenotes.html

- fix: Large scale issue - Optimize Nmon inventory generation runtime #85
- fix: Nmon inventory - Uptime data analysis issue #86
- fix: Nmon Dark dashboard - missing reset auto-refresh #87
- fix: TOP datamodel issue - error in distributed search for ALL_OS node (nmon summary...) #88
- fix: Drilldown correction for the number of last 7 days hosts in home pages #89
- evolution: Large scale consideration - restricted default limits for datamodel acceleration (1y for metrics) #90
- fix: Use nmon_inventory to retrieve configuration data instead of using datamodel #91

=======
V1.9.8:
=======

- intermediate unpublished release

=======
V1.9.7:
=======

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

This is a major release of the Nmon application and the TA-nmon:

Migration from 1.7.x and prior: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-7-x

Migration from 1.8.x: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-9-x

For the TA-nmon complete release notes: http://ta-nmon.readthedocs.io/en/latest/releasenotes.html

- fix: Large scale issue - Optimize search refresh values for large deployments #84
- fix: Nmon Config data model issues in some clustered environments #83
- fix: baseline future charting not working due to mismatch between host and hostname #82
- fix: Large scale issue - Optimize the run time of the Hosts with data within last 7 days #81
- fix: Large scale issue - restrict the nmon_processing data model to the last 30 days by default #80
- fix: report issue - TA-nmon package deployment reporting can includes non deployment events #79
- fix: Large scale issue - Optimize run time of the Volume of Data indexed today report #78
- fix: Large scale issue - Nmon inventory generation report may fail due to report lengh #77

=======
V1.9.6:
=======

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

This is a major release of the Nmon application and the TA-nmon:

Migration from 1.7.x and prior: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-7-x

Migration from 1.8.x: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-9-x

For the TA-nmon complete release notes: http://ta-nmon.readthedocs.io/en/latest/releasenotes.html

- fix: Alerting for CPU is broken since 1.9.5 due to unexpected missing sort _time #73
- fix: nmon data from syslog, missing indexed time creation and OStype and type fields #74
- fix: nmon data from syslog - uptime extraction failure #75
- fix: Alerting - Show the real number of alerts instead of triggered alerts #76

=======
V1.9.5:
=======

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

This is a major release of the Nmon application and the TA-nmon:

Migration from 1.7.x and prior: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-7-x

Migration from 1.8.x: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-9-x

For the TA-nmon complete release notes: http://ta-nmon.readthedocs.io/en/latest/releasenotes.html

- fix: missing oshost tag for ITSI
- fix: Nmon Summary dashboard not retrieving expected results in CPU usage summary with Splunk 6.6.1

=======
V1.9.4:
=======

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

This is a major release of the Nmon application and the TA-nmon:

Migration from 1.7.x and prior: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-7-x

Migration from 1.8.x: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-9-x

For the TA-nmon complete release notes: http://ta-nmon.readthedocs.io/en/latest/releasenotes.html

- fix alerting macros issues: transaction incorrect usage filter out events in excess of allowed limits #70
- fix eventtype related messages for nmon:performance:cpu/mem due to WLM stats #71
- fix Safe Center: reduce the number of searches and add refresh selector dropdown
- fix: CIM compliance improvements and corrections
- feature: introduce a smart auto refresh feature to prevent from having auto refresh enabled when out of current time range
- feature: red highlighting of forms waiting for inputs in views
- feature: Take the tour update

=======
V1.9.3:
=======

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

This is a major release of the Nmon application and the TA-nmon:

Migration from 1.7.x and prior: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-7-x

Migration from 1.8.x: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-9-x

For the TA-nmon complete release notes: http://ta-nmon.readthedocs.io/en/latest/releasenotes.html

- fix certification issues: TA-nmon and PA-nmon_light are not anymore embedded in the core application and must be downloaded externally
- Lower data model acceleration load with per data model schedule configuration #68
- Net stats not associated with time range selector in Nmon Summary
- IOPS and NET stats rendering improvements in Analyser views

=======
V1.9.2:
=======

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

This is a major release of the Nmon application and the TA-nmon:

Migration from 1.7.x and prior: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-7-x

Migration from 1.8.x: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-9-x

For the TA-nmon complete release notes: http://ta-nmon.readthedocs.io/en/latest/releasenotes.html

- Splunk 6.6 tstats issue over non existing field generates nan value instead of null values #67
- Introducing the Dark monitoring dashboard, interfaces review
- Linux Nmon Analyser view issue in DG chart for IOPS
- Nmon external load average extraction failure for some OS
- Be time relative to show indexing evolution in home page
- UPTIME external collection integration
- TA-nmon local/nmon.conf from the SHC deployer is not compatible #23, AIX issues with old topas-nmon, external collection stops on AIX 6.1/7.1, ...

=======
V1.9.1:
=======

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

This is a major release of the Nmon application and the TA-nmon:

Migration from 1.7.x and prior: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-7-x

Migration from 1.8.x: http://nmon-for-splunk.readthedocs.io/en/latest/upgrade.html#migrating-from-release-prior-to-version-1-9-x

For the TA-nmon complete release notes: http://ta-nmon.readthedocs.io/en/latest/releasenotes.html

- TA-nmon new branch: fantastic foot print reduction with the fifo implementation, extend data with nmon external, various bug fixes (read TA-nmon release notes)
- PA-nmon and TA-nmon_selfmode are now deprecated (unified by the new TA-nmon features)
- Optimization and rationalisation (globally use the host Splunk Metadata instead of historical hostname field)
- Nmon cores issues (multisearch and tstats incompatible in distributed for the Disk KV generation)

=======
V1.8.6:
=======

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

Please review update notes: http://nmon-for-splunk.readthedocs.io/en/latest/Userguide.html#additional-upgrade-notes-migrating-from-release-prior-to-version-1-7-x

- Invalid error number of events count in TCO dashboard when running multiple indexes
- Update of Nmon baseline generation for Disk I/O, and relevant macro update (use DG stats when available)
- app certification failure correction (custom viz issues in savedsearches.conf)
- Addons update to version 1.2.54
- Removal of the static "nmon" index abstraction layer: the app supports natively any index(es) starting with the "nmon" pattern
- Native support for multiple indexes
- Introducing the new frameID management using KVstore, and the frameID mapping management interface
- Improved multi-line events management for rsyslog with nmon-logger agent
- TA-nmon issue: implementation of linux disks groups caused issues with old nmon releases
- Improvement of multi line event management for rsyslog deployments
- populating forms issues in DG interface

=======
V1.8.5:
=======

- Intermediate release unpublished

=======
V1.8.4:
=======

- Intermediate release unpublished

=======
V1.8.3:
=======

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

Please review update notes: http://nmon-for-splunk.readthedocs.io/en/latest/Userguide.html#additional-upgrade-notes-migrating-from-release-prior-to-version-1-7-x

- Octamis release, Nmon Performance suite is now a company supported software
- ITSI better compatibility (most ITSI OS module builtin will work, entities dynamic inventory...)
- Nmon WOF dashboard correction (single forms mot linked to shared time picker)
- Adding direct link to Data model manager, updating to datasets link, correction to removed interfaces (UI RT)
- Implementation of Linux disks extended statistics (DG* sections), new data model, interfaces, Howto
- Nmon Analyser update, Nmon Summary and WOF will now automatically choose disks extended statistics when available
- Implementation of monitors assets description (monitor description enrichment)
- Allow nmon.conf on a per server basis (/etc/nmon.conf can be set to customize parameters on a per server basis)
- Generic Nmon binaries not recognized for Linux 32 bits systems
- TA-nmon and PA-nmon update to v1.2.51

=======
V1.8.2:
=======

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

Please review update notes: http://nmon-for-splunk.readthedocs.io/en/latest/Userguide.html#additional-upgrade-notes-migrating-from-release-prior-to-version-1-7-x

- Drilldown error with Splunk 6.5.1 #60 - Various drilldown errors since 6.5 when a pipeline is split in more than one line (carriage return)
- Errors in Nmon analyser views (Since 6.5 renming an non existing field removes the existing field, this was causing various Disks charts not to be displayed)
- TA-nmon update - Allow host name override #58 (feature request)
- TA-nmon and PA-nmon update to v1.2.50

=======
V1.8.1:
=======

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

Please review update notes: http://nmon-for-splunk.readthedocs.io/en/latest/Userguide.html#additional-upgrade-notes-migrating-from-release-prior-to-version-1-7-x

- Technical addons issue with Oracle Solaris 10 using Python interpreter (https://github.com/guilhemmarchand/TA-nmon/issues/11)
- TA-nmon and PA-nmon update to v1.2.48

=======
V1.8.0:
=======

**CAUTION: For Splunk 6.5 and later (for prior versions of Splunk, see requirements below)**

Please review update notes: http://nmon-for-splunk.readthedocs.io/en/latest/Userguide.html#additional-upgrade-notes-migrating-from-release-prior-to-version-1-7-x

- Implementation of Splunk 6.5 auto refresh features
- Minor improvements and evolutions for best Splunk 6.5 compatibility

=======
V1.7.9:
=======

Please review update notes: http://nmon-for-splunk.readthedocs.io/en/latest/Userguide.html#additional-upgrade-notes-migrating-from-release-prior-to-version-1-7-x

- Adding the PA-nmon_light add-on for indexers that need parsing configuration only (for people that do not want or must not monitor performance of indexers such as Splunk cloud indexers instances)
- Documentation update

=======
V1.7.8:
=======

Please review update notes: http://nmon-for-splunk.readthedocs.io/en/latest/Userguide.html#additional-upgrade-notes-migrating-from-release-prior-to-version-1-7-x

- Add-ons update to 1.2.47 (Linux_unlimited_capture improvement #9, Nmon binary issue with SLES 11.3 #10)
- Adding CONFIG df (filesystems stats) reports & dashboard

=======
V1.7.7:
=======

Please review update notes: http://nmon-for-splunk.readthedocs.io/en/latest/Userguide.html#additional-upgrade-notes-migrating-from-release-prior-to-version-1-7-x

- Drilldown to inventory issues and improvements (Issue #55)
- Performance improvement of the TCO per server search (use datamodel for dcount)
- Add-ons Perl parser (nmon2csv.pl) is lacking OStype field in raw data for TOP/UARG, causing data to be unavailable
- Removal of nmon_inventory OStype mapping had removed OStype mapping for historical data
- Add-ons update (PA-nmon/TA-nmon/TA-nmon_selfmode) to 1.2.46

=======
V1.7.6:
=======

Please review update notes: http://nmon-for-splunk.readthedocs.io/en/latest/Userguide.html#additional-upgrade-notes-migrating-from-release-prior-to-version-1-7-x

- Fix TCO scheduling searches analysis when running in Search Head Cluster
- Updating alerting menu
- Broken links to removed django views (Issue #54)

=======
V1.7.5:
=======

Please review update notes: http://nmon-for-splunk.readthedocs.io/en/latest/Userguide.html#additional-upgrade-notes-migrating-from-release-prior-to-version-1-7-x

- Prevent unwanted server filtering in nmon inventory interfaces due to null fields in nmon_inventory KV
- Correct labels for LPAR stats (for Powerlinux), correct series name to match Physical raw field names
- Integrating the TA-nmon_selfmode as an alternative to the standard TA in case of unsolved unarchive processor failure
- Rewritten Internal dashboard as the Total Cost of Ownership dashboard
- Rewritten Add-ons reporting to provide the global picture of add-ons deployment
- The Nmon app customization tool now offers the option to build a core app that supports Linux only
- Nmon core app Fix Git Issues: #48 to #53
- TA-nmon and PA-nmon V1.2.45

=======
V1.7.5:
=======

Please review update notes: http://nmon-for-splunk.readthedocs.io/en/latest/Userguide.html#additional-upgrade-notes-migrating-from-release-prior-to-version-1-7-x

- Prevent unwanted server filtering in nmon inventory interfaces due to null fields in nmon_inventory KV
- Correct labels for LPAR stats (for Powerlinux), correct series name to match Physical raw field names
- Integrating the TA-nmon_selfmode as an alternative to the standard TA in case of unsolved unarchive processor failure
- Rewritten Internal dashboard as the Total Cost of Ownership dashboard
- Nmon core app Fix Git Issues: #48 to #53
- TA-nmon and PA-nmon V1.2.44

=====================
V1.7.4: Major release
=====================

Please review update notes: http://nmon-for-splunk.readthedocs.io/en/latest/Userguide.html#additional-upgrade-notes-migrating-from-release-prior-to-version-1-7-x

- Removing of the django deprecated django stack, all views were migrated to simple xml views
- New global bootstrap navigation scheme for easy and efficient user experience with the integrated navigation
- New dynamic help messages will inform about each step of required user action for better user experience
- New major view with the Nmon Wall Of Performance (Nmon WOF)
- Major improvement of Nmon Summary and Nmon Analyser views (active tokens, bar visualization for file systems and much more)
- Rewritten Nmon predictive interface for improved predictive experience
- Embedded Splunk 6.4.x custom viz with fallback to compatibility mode for Splunk 6.3.x
- Improved Power architectures support (PowerLinux Little / Big endian management, LPAR monitor support for Linux, LPAR parsing model)
- Binaries upgrade for Linux (16e / 16f), Linux binaries are now stored in tgz archive and will be uncompressed on client if applicant
- Various bug fixes (Issues #29 to #49)
- Certification app path: The nmon index is not anymore created at installation time for standalone instances
- Certification app path: The core application does contain anymore data generation related object, the TA-nmon must be installed for this to be achieved
- Certification app path: The nmon_inventory file base lookup table were migrated to KV store collection
- inline_customspan macro were renamed to span_nmon for easier usage
- TA-nmon and PA-nmon new packages (V1.2.40)

========
V1.6.15:
========

- App certification path, issue 1 execute permission
- App certification path, issue 2 invalid json detected
- App certification path, issue 3/4 duplicated stanzas
- App certification path, issue 5 new line chars in savedsearches.conf

========
V1.6.14:
========

* eventtypes / tags implementation over hard index/sourcetype (allow easier multi-index scenarios)
* CIM 4.3 implementation over Performance, Application State, Inventory, Network
* NEW Deployment scenario using Sysog as the transport layer with the nmon-logger third party tool
* #16 (nmon2csv.py logging)
* #17 execute permission in appserver
* #18 html iframe in help
* #19 which python error
* #20 html panel resize
* #21 rename eventgen.conf to .conf.spec
* #22 SuSE Linux identification failure
* #23 nmon 16d / 16c upgrade for Linux binaries
* #24 Prevents bin modifications from customization tools
* TA-nmon and PA-nmon new packages (V1.2.34)

========
V1.6.13:
========

* modal windows conversion of transition pages (operating system choice...)
* Fix file text busy error in sh cluster deployment with search head generating nmon data by the core app
* nmon_helper.sh update: Linux and Solaris clients hosts will now cache binaries in run directory
* New monitor: POOLS for AIX systems (extended pools statistics)
* TA-nmon and PA-nmon new packages (V1.2.32)
* Various UI improvements: simplification of multi-series charting, baseline interfaces updates and optimization, custom span macro update (2-3x faster)
* CPU data model update, AIX Nmon Analyser update, new POOLS monitor interface
* App customization Python tool fix (broken links for new app nav bar)

========
V1.6.12:
========

* Oracle Solaris 10 clients generates duplicated sarmon processes with TA-nmon v1.2.30 #13
* TA-nmon and PA-nmon new packages (V1.2.31)
* New Application bar navigation menu for better user experience
* Removed single decoration on home pages for better Splunk 6.3 compatibility
* Minor corrections

========
V1.6.11:
========

* sarmon (Nmon for Solaris) update to new v1.11 for sparc and x86
* TA-nmon and PA-nmon new packages (V1.2.30)

========
V1.6.10:
========

* Removing Home pages searches schedule to limit Splunk load due to the Nmon App (schedules with low interest over cost)
* Smoothing alerting schedule reports (prevents from running them on same round step of 5 minutes)
* Manage artifacts time to live (ttl) for Baseline generation reports and other scheduled reports (limit file system usage on search heads, limit number of artifacts)

========
V1.6.09:
========

* nmon2csv.sh hotfix: V1.6.07 changed the temp directory from /tmp to $SPLUNK_HOME/var/run/nmon, but it was lacking creating the directory if required
* This only affects system running the App (core / PA or TA) BUT not generating itself nmon data (such like managing external nmon data)
* TA-nmon and PA-nmon new packages (V1.2.29)

========
V1.6.08:
========

* Splitting the kvstore per Performance metric
* Major improvements of baseline generation reports to be valuable at scale
* Baseline interfaces corrections

========
V1.6.07:
========

* New feature: Introducing the baseline KV store and baseline interface, chart system key metrics over the baseline to detect system resources utilization derivation and anomalies
* css & html code improvements, code cleaning and xml re-indentation
* Linux binaries 15e/15g updates, set Linux embedded binaries utilization priority by default
* Updates for upcoming sarmon new release
* TA-nmon and PA-nmon new packages (V1.2.28)
* Processing errors detection improvements
* Howto TOP corrections
* Fix for Nmon inventory generation (get latest information instead of last)

========
V1.6.06:
========

* New Howtos interfaces: semi interactive SPL request repositories for main monitors
* New pre-built Panels interfaces for main monitors
* Support for CPUnn (CPU usage per logical core), Interfaces and CPU Data Model update
* nmon2csv Python and Perl backend improvements: Manage sections status store per server (allows managing multiple files in realtime mode), fixed blanck space issue in device for nmon2csv.py
* nmon2csv.sh backend will now restrict nmon2csv.py usage to 2.7.x interpreter versions (other will use Perl)
* Nmon App customization Python tool fix (management of token URLs)
* Various interfaces corrections, Home OS pages update
* Removed singlevalue.css for Splunk 6.3.0 compatibility, pre and post label single issue workaround for Splunk 6.3.0
* TA-nmon and PA-nmon new packages (V1.2.27)

========
V1.6.05:
========

* Data gaps in Real Time deployment for some random monitors and random timestamp #5
* Data gaps between Nmon collections (occurs between 2 Nmon processes iteration) #6
* Added support for DISKREADSERV / DISKWRITESERV
* TA-nmon and PA-nmon new packages (V1.2.26)

========
V1.6.04:
========

* Splunkd unexpected crashes with Splunk version 6.2.4 #4
* TA-nmon and PA-nmon new packages (V1.2.25)

========
V1.6.03:
========

* SAFE Center error in events panel for FS Analysis #3
* PA-nmon and TA-nmon add-on tgz archives where wrongly named and affected create_agent.py and Nmon customize script
* Global review of UI and Dashboards names and descriptions for better visibility
* Corrections and improvements of views
* Simple xml conversion of heatmap calendar views
* Added the Help menu in App bar

========
V1.6.02:
========

* AIX Hotfix: nmon_helper.sh on AIX generates splunkd error with grep call #2
* TA-nmon and PA-nmon new packages (V1.2.24)

========
V1.6.01:
========

* Hotfix for PA-nmon add-on, corrects non working Performance generation on standalone indexers
* Hotfix for Nmon_SplunkApp_Customize.py script: Broken triggered link in Home page when the root directory of App is customized
* Hotfix for create_agent.py: Manage creation of custom agents packages using the shell wrapper
* Improved single alerts drilldown of active alerts to match active time range (Home and Safe Center UI)
* TA-nmon and PA-nmon new packages (V1.2.23)

=======
V1.6.0:
=======

* New nmon2csv wrapper that will automatically choose between Python and Perl tool to convert Nmon raw data, deploy the TA-nmon much more easier than ever
* Introducing the SAFE Center as a central place to manage real time hosts alerting using performance data
* Introducing the TA-NMON management interface to get the better vision of your Nmon and Splunk clients deployment
* Reviewed Home pages for global App, and per type of Operating System
* Eventgen configuration and data samples for chosen main monitors (CPU, LPAR, TOP…) relevant for AIX, Linux and Solaris template hosts, test the App without deploying real clients
* New Wiki documentation now Online hosted at http://nmonsplunk.wikidot.com, Help page now refers to Online Wiki
* TA-nmon and PA-nmon new packages (V1.2.22)
* Various UI corrections

========
V1.5.30:
========

* SUSE Linux hotfix: nmon_helper.sh typo error leading in failing to identify best binary for Suse Linux clients
* nmon_helper.sh hotfix: Some cases still lead to processes duplication at boot time for some OS, improved and simplified code will prevent this
* TA-nmon and PA-nmon new packages (V1.2.21)

========
V1.5.29:
========

* nmon_helper.sh hotfix: Under certain circumstances and after reboot, multiple nmon instances may be generated, this new improved version will prevent this.
* TA-nmon and PA-nmon new packages (V1.2.20)

========
V1.5.28:
========

* Simple xml conversion of Nmon Internal interface, TOP Usage (bubblechart) dashboards
* Simplification of custom span definition in views, added a new form input "span" available in all interfaces
* Correction of IBM Pool usage alerting (bad CPU % reported), added file systems excluding lookup
* nmon_helper.sh update: Improvements code (All OS) to help preventing launching multiple nmon instances
* TA-nmon and PA-nmon new packages (V1.2.19)

========
V1.5.27:
========

* AIX Pool usage interface correction (relative and real time interfaces): non working token for monitor other than VP usage reporting (VP usage in % of its capacity)
* CPU_ALL / LPAR data model update: correcting evaluation of VP usage in % of capacity
* Data dictionary update (formula correcton for VP usage in %)

========
V1.5.26:
========

* nmon2csv.pl (Perl Nmon converter) update: Fix BBB config section extraction failure when BBB is lately generated (mainly for Linux hosts)
* nmon_helper.sh update: for AIX, prevents nmon instance identification failure if not using topas-nmon
* nmon_helper.sh update: for Linux (Ubuntu), added support for older releases (with no os-release file available)
* nmon2csv.py (Python Nmon converter) update: Windows Hotfix, broken directory creation fixed
* TA-nmon and PA-nmon new packages (V1.2.18)
* Nmon customization Python tool update: Fix customization failure due to the TA-nmon removing in V1.5.25 (only the tgz archive is kept now, for size optimization)
* Data dictionary visualization update: Added overflow scollbar and fixed low resolution truncation

========
V1.5.25:
========

* SEA Data model correction (SEACHPHY not reported)
* Correction of data volume comparison in Home page
* nmon_helper.sh maj update for Linux: Linux identification allows using best embedded nmon binary
* TA-nmon now brings nmon binaries for most common Linux OS and hardware
* New nmon.conf option allows giving priority to local nmon binary in PATH or embedded binaries
* TA-nmon and PA-nmon new packages (V1.2.17)
* TOP UI maj update: Aggregate stats per host or globally, Active drilldown links to stats per PID for the clicked Command invocation
* New embedded alert to watch for potential nmon processes duplication on hosts
* Internal Stats UI update: Added message for admin rights acess to internal indexes
* Web FrameWork dashboards maj update: Improved html code to correct fit to screen issues

========
V1.5.24:
========

* nmon_helper.sh hotfix: Corrections and improvement for App related nmon instances identification
* Introducing the very first version of Nmon Splunk Alerting, Alerting templates rules for common monitors (% CPU, Real and Virtual Memory...)
* Added support for SEA AIX Statistics (Shared Ethernet Adapter)
* Corrected NFS V4 AIX options which was incorrectly verified in nmon_helper.sh
* TA-nmon and PA-nmon new packages (V1.2.16)
* New data model for SEA statistics, associated SEA interface
* Data dictionary update (inclusion of SEA metrics)
* Home and Home AIX pages update

========
V1.5.23:
========

* Rewritten version of the nmon_helper.sh to definitively solve trouble with the input script
* The nmon_helper.sh has been a root cause of various troubles because it was (with more or less success) attempting to manage process duplication and so
* Part of the script has been rewritten from scratch, to be simple and effective with very few conditions
* The script won't try to kill anything now (common trouble for people) and will be based pid file to get its current status
* TA-nmon and PA-nmon new packages (V1.2.15)

==================
V1.5.19 - V1.5.22:
==================

* nmon_helper.sh update

========
V1.5.18:
========

* IOADAPT interface hotfix: Missing span in tstats command causing avg eval deviation and charting issues
* nmon2csv.py / nmon2csv.pl update: Added support for AIX Fiber Chanel metrics (FC*)
* nmon_helper.sh update: Prevent from trying to verify non existing processes (error message in Solaris, no such process)
* TA-nmon and PA-nmon new packages (V1.2.10)
* New data model for FC statistics, associated FC interface
* AIX Nmon Analyser update: set IOADAPT charts in stack mode
* Data dictionary update (inclusion of FC metrics)
* Home and Home AIX pages update

========
V1.5.17:
========

* Solaris update: Added Solaris specific Performance monitors, specially WLM statistics for Zone management
* New Solaris interfaces and Django Dashboard for WLM Statistics, Disks service and wait time
* nmon2csv.py / nmon2csv.pl update: Code improvement, Solaris update
* nmon_helper.sh / nmon.conf update: Solaris update (deactivation of CPUnn data, management of VxVM activation)
* TA-nmon and PA-nmon new packages (V1.2.09)
* New Data Model for Solaris WLM Stats, Disks Service and wait time
* Nmon Config Data Model update for type of processor identification corretion for Solaris
* Data dictionary update

========
V1.5.16:
========

* Linux maximum number of devices is now overcharged by nmon.conf to allow easy customization for very large systems
* nmon_helper.sh update for Linux max devices overcharged update
* nmon2csv.py / nmon2csv.pl hotfix: Prevent partial Configuration extraction in Real time mode for very large systems (BBB collects may occurs after Performance collect starts)
* TA-nmon and PA-nmon new packages (V1.2.08)
* Nmon Inventory Data Model update to prevent OSfilter being null in case of unexpected Operating System recognition (hosts would be listed in Any OS)
* Nmon Inventory Data Model update to improve Linux distribution and vendor identification, inventory savedsearch update and minor Linux sections update in inventory interfaces
* Minor corrections in CPU_ALL interfaces (2 decimals rounding)
* Help update

========
V1.5.15:
========

* Data Model conversion and important performance optimization of Nmon Analyser views for AIX / Linux / Solaris
* MEM Linux interface correction for table stats
* Various optimizations of interfaces

========
V1.5.14:
========

* Introducing the new Data Dictionary to provide through a dendogram user interface the capacity to explore the App data definition: Which metrics are available, Operating systems applicable... and more !
* Major update of the nmon_helper.sh input script update: Improvement of process identification, prevents from killing non App related nmon instances, analysis of Linux return code...
* TA-nmon and PA-nmon new packages (V1.2.06)
* MEM Linux interface correction (duplicated OS filter, _time shown in chart)
* Minor AIX File datamodel update
* Global update of interface to add metric definitions for more complex interfaces
* Added information panel in Nmon Analyser views and Nmon Summary
* Nmon_SplunkApp_Customize.py script update for dendogram compatibility
* Update of scheduled search for error reporting (added the Data collect error reporting), Home page update
* Added the Know Issues, available as link from the Help page, Help page update

========
V1.5.13:
========

* Missing Wildcard in Disks DataModels that would lead to ignore devices in Data Model stats (introduced in V1.5.12 that was not published as public release)

========
V1.5.12:
========

* Data Models rebuild for disks sections: Main Disk datamodel has been split by type (DISKXFER, DISKBUSY...) for better acceleration building (large data volume) and better search performances
* Update of Disks interfaces and Nmon Summary interface
* Minor css correction for django interfaces

========
V1.5.11:
========

* shebang correction in nmon_cleaner.py
* python subversion check correction in nmon_cleaner.sh

========
V1.5.10:
========

* Migration of var directories used by the App to generate, monitor, index and clean nmon and associated data
* The main var directory is now $SPLUNK_HOME/var/run/nmon, this especially prevents from loosing data during indexing time if app upgrade occurs (deployment process)
* New versions of all third party scripts
* TA-nmon and PA-nmon new packages (V1.2.05)
* Documentation update
* Correction for Volume of data indexed saved search (bad volume reported in cluster), Home update
* Nmon Inventory update: regular expression to ignore Linux LSB_version patterns (improvement of Linux distributions recognition)
* First level of drilldown UI update

========
V1.5.09:
========

* nmon_helper.sh corrective hotfix (collision when nmon is in bin/)
* nmon_cleaner.sh improvement: Verify Python version meets 2.7.x requirements before using py script (User Perl version if not met)
* TA-nmon and PA-nmon new packages (V1.2.04)

========
V1.5.08:
========

* nmon_cleaner.sh corrective Hotfix
* TA-nmon and PA-nmon new packages (V1.2.03)

========
V1.5.07:
========

* New frontal sh script nmon_cleaner.sh to encapsulate both Python and Perl cleaners, if Python not locally available, the Perl version is now automatically used (configuration simplification)
* TA-nmon and PA-nmon new packages (V1.2.02)
* macros.conf update for custom span definition: 1 minute minimal span value is now the default standard (equal to the default value of nmon.conf)
* Minor correction of Nmon Inventory views (single forms drilldown issue)
* New source stanza in props.conf to Allow managing nmon.gz gzip compressed file archives without further more configuration (cold nmon repositories)
* nmon_helper.sh update: Definitively fixed detaching issue for Solaris!
* nmon2csv.py update and correction (data not being reported if count less than 3 events)
* Hotfix 20150211 for Windows users: fix non compatible epoch time conversion leading to nmon2csv failure
* source default field override by default to prevent multiplication of Metadata entries
* Nmon customization resource script cleaning improvement

========
V1.5.06:
========

* Error in CPU_ALL tables stats for Wait % value
* Broken image link in Nmon_ANALYSER_AIX

========
V1.5.05:
========

* New Application logo !
* Incorrect link to django interfaces in TOP processes views
* Data Model update for VM section (Linux, Solaris), update of associated interfaces
* Data Model conversion of heatmap cal view (data), improvement of processing calendar views
* Data Model conversion of Nmon Analyser views

========
V1.5.04:
========

* TOP Processes Activity (CPU, MEM) dj dashboards improvements: Added a table stats to link Commands by associated hosts

========
V1.5.03:
========

* OStype filtering error in Nmon Summary interface
* Nmon Compare interface corrections and improvements

========
V1.5.02:
========

* Error in LPAR Pool interface for Pool ID identification in table stats
* Nmon Summary interface corrections and Data Model conversion
* TOP Data Model update (added All OS node to allow Nmon Summary update)
* Various minor corrections of Interfaces
* Nmon Analyser views populating inputs update
* Home pages update for OS Filter token to be passed to Nmon Summary & Analyser

========
V1.5.01:
========

* Minor corrections in LPAR interfaces (hostname populating not associated with frameID)
* Fixed AIX compatibility with nmon_helper.sh
* NFS macro correction (macros.conf)
* Minor width corrections for redesigned django interfaces
* New version of TA-nmon: Version 1.2.01 and PA-nmon: 1.2.01
* Schedule of Nmon Inventory data from accelerated datamodel to run every hour

=======
V1.5.0:
=======

* Important new releases of Python and Perl nmon2csv converters with now real time capacity
* The App can now manage a single real time Nmon file (nmon binary is running) with the capacity of real time / cold data analysis detection
* Main nmon options (interval and snapshot, NFS activation) can now be controlled through a Splunk fashion default/local nmon.conf file (upgrade resilient)
* All new Data Models for each type of Nmon data, Using the Data Model acceleration, the App run faster than ever
* Global review of All interfaces and dashboard, take benefit of Data models acceleration, improved design, best functionalities
* Important improvement of the Nmon inventory data generation using the Data model acceleration (specially solves performance issue while generating nmon inventory)
* Brings new Python and Perl nmon_cleaner tools to manage retention of nmon raw data files and prevent potential issues with temporary csv data

========
V1.4.92:
========

* New Accelerated Data Model for Nmon Config: Configuration items extraction
* Updated associated saved search and home page

========
V1.4.91:
========

* Improved Linux Memory interface Analysis
* Update of Linux Nmon Analyser interface
* Minor views improvements
* Include the optional Python script "nmon_cleaner.py" that can be used to purge csv repositories, based on file retention
* New version of TA-nmon: Version 1.1.34 and PA-nmon: 1.1.27
* Nmon SplunkApp Customize tool updated: Deleted useless removal of pyo files (now forbidden files for package creation)

========
V1.4.90:
========

* Decimals rounding for evolution trend JavaScript decoration (home page and comparison ui decoration)
* Applying a dispatch ttl of 4 hours for Nmon Inventory lookup table generation savedsearch to prevent affecting user quota
* nmon2csv Python converter update: Fix for old Linux Nmon releases that have unexepected timestamp id in csv header, code cleaning (redundant espaced chars)
* New version of TA-nmon: Version 1.1.33 and PA-nmon: 1.1.26

========
V1.4.89:
========

* Home page improvements with volume of data indexed and reported errors trends decorations
* Comparison interface improvements with range icon decoration (equal, increase, decrease)
* New improved version of calendar data Analysis
* Improvements of Nmon Summary interface
* Improvement of hosts accounting (mainly for AIX, redundant hostnames are now accounted by serial numbers)
* nmon_helper.sh input script update: Allow master node execution for cluster monitoring
* New version of TA-nmon: Version 1.1.32 and PA-nmon: 1.1.25
* Nmon SplunkApp Customize tool updated: Missing string replacement for dispatch ui in savedsearches.conf
* Missing AIX_LEVEL in table stats of Nmon inventory interfaces
* Help update with a proper and improved Splunk Distributed Cluster monitoring
  using Nmon App (includes Splunk 6.2 search head clustering compatibility)

========
V1.4.88:
========

* nmon2csv Python converter update: Correction for bad header identification due to unexpected blank space after comma, String replacement correction that could affect LPAR section for partitions with no pools (IBM P5)
* New versions of TA-nmon: Version 1.1.31 and PA-nmon: 1.1.24
* props.conf of core App update (workaround for LPAR section with data previously indexed and affected by the string replacement error)
* Update of default metadata macros system export

========
V1.4.87:
========

* Remove the App setting page (setup.xml) which generates more troubles than benefits, replaced by links to main items in the configuration menu
* Corrected Volume Index today savedsearch
* Important correction of auto-span macros: under some circumstances, the macro was generating unexpected span values, and gaps in charts or "too much data" error message
* Correction of MEM views for Linux and Solaris
* Added missing Host pattern filtering in Predictive Web framework view
* Help update

========
V1.4.86:
========

* Nmon SplunkApp Customize tool updated: Missing string replacement for UARG links in Web Framework views
* Missing Host populating filter in Web Framework views: "D3chart: Processes CPU and Memory Usage"
* Corrected scale names in MEM interfaces
* Activated acceleration over report "Generate NMON Inventory Lookup Table"
* Pivot models update
* Added the number of nmon files proceeded in Application Internal Statistics

========
V1.4.85:
========

* Added Host populating filter in all views to facilitate management of very large number of hosts
* Improved Nmon Summary interface: Added Single links, improved memory analysis accuracy
* Navbar color changed
* Limited the minimal span to 20 sec instead of 10 sec, sometimes the Nmon collect may miss a measure which generates gaps in charts when looking at very small time ranges This will prevent this and does not change the minimal interval definition if the Nmon data has been generated out of Splunk. (unless interval inferior to 20 seconds)
* Nmon Analyser views update: Added NFS sections for AIX/Linux, migrated row grouping to panel mechanism
* Removed useless LPAR views for Linux
* Update and improvements of Web Frameworks dashboards

========
V1.4.84:
========

* Typo error in unarchive_cmd configuration line for props.conf of the core App (repeated unarchive_cmd but does not affect the good work of the Application)

========
V1.4.83:
========

* The nmon2csv converter is now officially available in 2 flavors, Python as the default converter, and Perl as the alternative converter
* Systems lacking Python or having trouble with it can use the Perl converter that has the same level of functionalities: Processing statistics, Prevention of data inconsistency, error logging...
* Release V1.0.9 of the Python nmon2csv converter (log truncated prevention)
* Updated help page
* New version of TA-nmon: Version 1.1.30 and PA-nmon: 1.1.23

========
V1.4.82:
========

* nmon2csv converter updated: Improvement of logging Splunk compliance, portable shebang update
* Nmon SplunkApp Customize tool updated: Important correction for non working calendar heatmap views due to customization, portable shebang update
* Removed useless nmon_data source overwrite in inputs.conf for csv indexing state
* Added report for NMON related splunkd events
* New versions of TA-nmon: Version 1.1.29 nd PA-nmon: 1.1.22

========
V1.4.81:
========

* Improved version of the "Nmon_SplunkApp_Customize.py" Python customizer tool (v1.0.2): Code improvement, backward compatibility with Python 2.6.x
* Added a new advanced macro with args used with manual interacts in Prediction UI (code improvement)
* Web Framework views improvements, minor corrections

=======
V1.4.8:
=======

* nmon2csv Python converter update:
	. PEP 8 Python compliance, various syntax corrections
	. Added the Parameters section to facilitate user customizations
* New versions of TA-nmon: Version 1.1.28 nd PA-nmon: 1.1.21
* Help update
* minor macros.conf update for Solaris inventory improvement, improved version of Solaris inventory UI

=======
V1.4.7:
=======

* Introducing the "Nmon_SplunkApp_Customize.py", a simple to use Python tool that allows customizing the Application to fit your needs and company criteria, such as:
* Customize the Appication Index Name (default: nmon)
* Customize the Application Root Directory (default: nmon)
* Customize the TA NMON Root Directory (default: TA-nmon)
* Customize the PA NMON Root Directory (default: PA-nmon)
* Customize the local CSV Repository (default:csv_repository)
* Customize the local Config Repository (default:config_repository) The Python tool uses optional command line arguments and can be used over each future release, such that your customizations are automatically integrated and updating the Application is easy as usual.
* Help update

=======
V1.4.6:
=======

* Missing PID filter in AIX TOP processes view, Added UARG interface link and PID filter in Web Framework TOP views
* Migrated default nmon repository from monitor to batch to prevent local nmon data missing when indexing large nmon volumes from central shares (does not affect central shares configuration, only for local host monitoring)
* nmon2csv converter update:
	. UARG section correction for AIX systems
	. Inconsistency Data prevent improvements
	. Logging improvements (some functional messages were logged instead of indexed within nmon_processing sourcetype)
* nmon_helper collecter update: Avoir deleting existing nmon files in default nmon_repository to prevent missing local nmon data, this operation is now done by Splunk (migrating from monitor to batch)
* New versions of TA-nmon: Version 1.1.27 nd PA-nmon: 1.1.20
* Corrected UARG Interfaces for AIX
* Inventory macros corrections, Improved versions of Inventory Interfaces for AIX, Linux
* Help update

=======
V1.4.5:
=======

* nmon2csv converter update:
	. Avoid blank line creation when running under Windows OS
	. Added NFS Statistics extraction: Sections NFSSVRV2 / NFSSVRV3 / NFSSVRV4 for Server, NFSCLIV2 / NFSCLIV3 / NFSCLIV4 for client
	. Added UARG data extraction (full command argument of TOP processes, needs to be activated in nmon command line to be available)
* New interfaces for NFS Statistics (AIX / Linux)
* nmon_helper collecter update: Improved default command line options for AIX / Linux
* New UARG interface, updated versions of TOP interfaces with link to UARG, improvement of Nmon Config interfaces
* New versions of TA-nmon: Version 1.1.26 nd PA-nmon: 1.1.19
* Help Page improvements: Various corrections, new Table of content with sections links, updated FAQ

=======
V1.4.4:
=======

* nmon2csv converter update: Added interval and snapshots values in data, to be used in conjunction with the new custom span macro embedded within this release
* New version of custom span macros used with the App to identify the better span value for data accuracy, the new version allows:
	. Always use a minimal span value that matches the lower level of the Nmon interval between 2 measures
	. Always have charts with no gaps no matters the Nmon interval in data (if there is no gaps in data)
	. Allow an automatic identification of the interval per host, so that you can have hosts with different interval values
	. No more requirement of setting a local version of macros.conf if your Nmon data is less accurate than the proposal one in Nmon Collect
* All views updated to match the new macro syntax (args required, type and hostname)
* Help update
* OSfilter correction in some views
* New versions of TA-nmon: Version 1.1.25 and PA-nmon: Version 1.1.18

=======
V1.4.3:
=======

Windows OS compatiblity for Nmon Data conversion:
* nmon2csv.py (Version 1.0.3) update for Windows Compatibility
* Added OS type, Python version and Splunk Root Directory in output processing
* Added inputs.conf.forWindows and props.conf.forWindows to allow users who need to convert Nmon files under Windows OS
* Help update
* New versions of TA-nmon as of Version 1.1.24 and PA-nmon as of Version 1.1.17

=======
V1.4.2:
=======

* Review and improvement of default config files inputs.conf and props.conf
* Using variable path instead of full path ($SPLUNK_HOME)
* Change the source stanza in props.conf to match any nmon file no matters where it is located to simplify adding custom repositories (now possible from Splunk Web)
* Using the Python emebedded interpreter for standard Application and PA-nmon (Forwarders don't have Python embedded, so must have the host running TA-nmon)
* Web Framework views improvement: Added auto_cancel parameter to prevent Real time searches from running after leaving interfaces
* New Versions of Calendar views: Data Processing and Performance Monitors Analysis
* Home page update: Added the Number of errors reported
* Help update
* Various minor corrections
* nmon2scv converter update: Minor version with code cleaning
* New versions of TA-nmon as of Version 1.1.23 and PA-nmon as of Version 1.1.16

=======
V1.4.1:
=======

* nmon2csv converter update: Minor regex optimizations, added nmon2csv version in output processing (nmon_processing sourcetype)
* Default host field override based on events data for nmon_data and nmon_config: corrects the host field when indexing nmon files from central shares instead of Forwarder hosts
* Increased the number of max event lines for nmon_config (prevents event breaking for very large system)
* New versions of TA-nmon as of Version 1.1.22 and PA-nmon as of Version 1.1.15
* Duration evaluation corrected in Application Internal Statistics interface
* Help updated mainly for the new Python nmon2csv converter and some other corrections

=======
V1.4.0:
=======

* The Nmon converter tool (formerly nmon2csv) has been fully rewritten in Python 2.x: More Data control, better processing output, lower resources usage, lower volume of data generated, no more empty files generation... and much more !
* Application Internal Statistics update to take advantage of the new Python converter (conversion stats: elapsed time, volume of Nmon raw data converted, numbers of encountered errors...)
* Reports updates (Activity and Errors in Data Collect / Processing)
* Added pre-packaged Nmon binary for powerlinux systems (ppc32/64)
* Removed the Nmon cleaner (nmon_cleaner.sh) which is not required anymore (no more generation of empty csv files with the new nmon2csv Python converter)
* New versions of TA-nmon as of Version 1.1.21 and PA-nmon as of Version 1.1.14
* Various updates and corrections

=======
V1.3.6:
=======

* nmon2csv converter update, Blank line issue correction: If the nmon file contains several blank lines, this could lead the script not to be able to convert data successfully, this is has been corrected in this release by filtering blank lines while reading from stdin
* Added text input filter in Nmon_Summary and Nmon_Analyser views to allow pre-filtering hosts using a user pattern
* Corrected Nmon_Summary and Nmon_Summary to keeps stats in "Waiting for input" mode until user's selection
* Added the CPU datasource identification for Nmon_Summary and Nmon_Analyser views
* Update of nmon_helper.sh to prevent users from trying to launch nmon data collect non supported systems
* New input script "nmon_cleaner.sh", prevents empty csv files kept undeleted by Splunk which may sometime happen
* Added reports nmon_cleaner activity / Nmon collect errors
* New versions of TA-nmon as of Version 1.1.20 and PA-nmon as of Version 1.1.13

=======
V1.3.5:
=======

* Intregated type of OS filtering based on csv lookup table instead of raw Nmon data to improve time required to populate hosts lists (requires a first run to be available)
* nmon2csv converter update: improved processing output logging (nmon_collect sourcetype)
* minor regex update for nmon_config
* New versions of TA-nmon as of Version 1.1.19 and PA-nmon as of Version 1.1.12
* Removed "Inactive" OS type choice when useless within interfaces

=======
V1.3.4:
=======

* OS type identification optimization: time of treatment drastrically reduced using dedup at top of nmon_config based search
* New UI "NMON Summary" for Light System load Analysis, available ton top of Home pages
* Nmon inventory important update, complete regex extraction of available config elements for AIX/Linux/Solaris
* Corrections for NMON Analyser views: Missing wildcards in some charts for disks aggregation
* New scheduled savedsearches which generates NMON inventory data used in inventory UIs, update NMON App setup page to allow customization
* nmon2csv converter update: added nmon data structure verification to prevent data inconsistency: Buggy nmon files (ZZZZ lines truncated) and obsolete Nmon versions
* Added a simple report to show NMON Processing Errors
* Added a simple report that shows NMON Collect Activity
* nmon_helper.sh update to clean Solaris sadc output
* New versions of TA-nmon as of Version 1.1.18 and PA-nmon as of Version 1.1.11

=======
V1.3.3:
=======

* Improved nmon2cv.pl time format for processing output, correction in props.conf
* Increased number of devices taken in charge while converting data, up to 150x5 devices for very large systems (nmon2csv update)
* Improved the identification of the number of logical CPUs for TOP section
* Introduced CPU load increase factor by SMT mode for AIX TOP processes views
* New section for AIX: DISKRIO and DISKWIO for read/write I/O and new AIX Interface
* New versions of TA-nmon as of Version 1.1.17 and TA-nmon as of Version 1.1.10
* Improved nmon_data section in props.conf
* Corrected nmon_processing django analysis interface (number of nmon files processed per day)
* Corrected default metadata (admin as default owner of views)
* Global review of all Interfaces with various corrections and improvements
* Interfaces with devices (NET*, DISK*, JFS*, IOADADPT) have been converted into multi-hosts selection,multi-series charts
* FileSystem filtering by pattern input (JFS* monitor)
* Pivot Models update

=======
V1.3.2:
=======

* Update of nmon converter (mmon2csv.pl): Corrected TOP section header and timestamp pattern to match updated props.conf
* New versions of TA-nmon as of Version 1.1.16 and TA-nmon as of Version 1.1.9
* Improved timestamp recognition of events
* setup.xml correction (wrong description in polling interval)
* Web Framework Toolkit upgraded to version 1.1
* Updated django Processes views "D3chart: Processes CPU and Memory Usage" to limit timecharts to top 20 processes (prevents browser hangs)
* Various minor corrections in views

=======
V1.3.1:
=======

* All New rewritten Comparison Interface in Simple XML: Compare various Metrics (CPU, I/Os, Network...), Evolution Trend with Single value decoration, Overlapped chart of periods, Multi Hosts selection
* Added Time Filtering input forms for all Interfaces (filter statistics by hour and type of days, business days, nights...)
* NMON logo and margin insertion in simple xml views (css customization)
* Added filter to prevent bad identified devices for NET section under Linux
* Added auto-refreshed indexing volume of the day in Home page
* Help update

=======
V1.3.0:
=======

* Solaris issue with nmon_helper.sh

=======
V1.2.9:
=======

* Optimization of CPU Load generated by the nmon App for Forwarders and Indexers by avoiding multiple nmon files to be kept in nmon_repository directory
* Removed input script "purge_nmon_repository.sh" from bin and App setup
* Updated nmon_helper.sh third party script
* New resources versions: PA-nmon (1.1.7) and TA-nmon (1.1.14) versions
* Update is highly recommended, please clean the old input "purge_nmon_repository.sh" from your local/inputs.conf, if any.

=======
V1.2.8:
=======

* Deactivated third party scripts nmon_helper.sh and purge_nmon_respository.sh in default App configuration to prevent splunkd crash on Max OS X installation

=======
V1.2.7:
=======

* Views and dashboards updates: Auto refresh for single forms in home page, Improved placements of forms in views for better options visualization
* Macro custom span definition update to correct Real Time span definition (issue introduced in last version with span accuracy improvements)
* Update of nmon_helper.sh to suppress useless log pollution of Solaris sadc binary in nmon_collect sourcetype
* New resources versions: PA-nmon (1.1.6) and TA-nmon (1.1.13) versions

=======
V1.2.6:
=======

* Update of purge nmon repository third party script to correct compatibility issue with Solaris 10
* New resources versions: PA-nmon (1.1.5) and TA-nmon (1.1.12) versions
* Update of nmon_helper.sh to improve accuracy of nmon measures, one measure each step of 10 seconds in default configuration
* Accuracy improvement of custom span definition macros for small time ranges (added 10s / 30s)
* Update of setup.xml to allow interval custom settings of nmon_helper.sh execution
* In default configuration, data will be refreshed each minute (2 minutes before) for Real Time monitoring accuracy
* Web Framework views corrections for Real Time search compatibility
* Help update

=======
V1.2.5:
=======

* Components from Web FrameWork Toolkit have been incorporated within the App core, it is not required anymore to install the WFT as a requirement
* Various corrections and optimizations of Web Framework dashboards
* Added missing OS Type filtering in Web Framework views
* Adding textinput filtering by Command in TOP interfaces for AIX / Linux / Solaris
* Added FAQ in Help Page
* Updated Installation section of Help Page
* Removed useless indexes.conf in TA-nmon, new TA-nmon as of Version 1.1.11

=======
V1.2.4:
=======

* An error has been introduced in Version 1.2.2 and 1.2.3 in props.conf of TA-nmon and PA-nmon
* Corrected Versions of TA-nmon / PA-nmon

=======
V1.2.3:
=======

* nmon2csv.pl correction for to clean cksum hash reference file upon check operation iteration
* New TA-nmon (V1.1.9) and PA-nmon (V1.1.3) versions
* Help updated for incorrect splunkforwarder rc-init management when a Splunk instance is present in the same machine (Cluster topology)

=======
V1.2.2:
=======

* nmon2csv.pl correction for missing timestamp in nmon_processing sourcetype
* New TA-nmon (V1.1.8) and PA-nmon (V1.1.2) versions
* Indexes First and Last Events statistics correction

=======
V1.2.1:
=======

* Update and improvement of all simple xml views (Nmon Metric interfaces) to implement the Multiselect module for multi Hosts / Devices selection that came with Splunk 6.1
* Various views corrections

=======
V1.2.0:
=======

* Introducing the "PA-nmon" App available in resources directory for Cluster Topology (cluster bundle configuration) to be installed in peer nodes of a cluster
* Help update with a new full tutorial for Cluster topology integration
* All pieces of a Splunk Cluster can now be analysed with Nmon Performance data

========
V1.1.10:
========

* Solaris 10 correction for sparc arch (nmon_helper.sh update)
* New Forwarder version as of Version 1.1.7 (Solaris 10 sparc arch issue)

=======
V1.1.9:
=======

* Solaris 10 incompatibility correction with nmon_helper.sh third party script
* New Forwarder version as of Version 1.1.6 (Solaris 10 incompatibility with previous version)

=======
V1.1.8:
=======

* New version of Forwarder App "TA-nmon" As of version 1.1.5 (nmon_helper.sh update, pre-packages for Solaris sparc and X86)
* Update of nmon_helper.sh third party script which includes now pre-packages for Solaris sparc and X86
* CSS updates
* Help page update

=======
V1.1.7:
=======

* Unification of various scripts for both nmon and TA-nmon (local data collect, remote collect through agents)
* md5sum operations has been replaced by cksum for AIX compliance
* Data collect is now fully compatible with AIX OS

=======
V1.1.6:
=======

* Images paths corrections for reverse proxy compliance

=======
V1.1.5:
=======

* New version of NMON Forwarder App (for Linux and Solaris, upcoming for AIX) which is now unified to be fully compliant with Splunk Deployment schemas
* Forwarder App renamed to "TA-nmon", input script unified for Solaris and Linux
* Help updated with deployment server tutorial, integration of Deployment server configuration and NMON forwarder App deployment
* Broken link correction in Home page for AIX JFSINODE
* NMON Analyser OS filtering missing for Solaris

=======
V1.1.4:
=======

* New version of third party script nmon2csv.pl to integrate auto extraction of full host configuration (AAA and BBB Nmon sections)
* New version of lightweight Nmon App forwarder version (version 1.1.2)
* New User Interface, Nmon Hosts Configuration Show Interface
* New User Interfaces, Nmon Hosts Inventory Interface for All systems and per OS type
* New Pivot Model to exploit Nmon Config data
* Purge script update
* Added Application setup confuguration to allow users activating NMON inputs at installation time
* Added access to Setup from navigation bar within the application
* migrated from full path references in default/inputs.conf to relative path due to incompatibility with setup.xml design (and REST endpoints update)
* Minor corrections of NMON Analyser pages
* Help page update

=======
V1.1.3:
=======

* Various corrections of views
* MEM views update with OS kind distinction
* Pivot Model updates to manage OS specific Metrics by OS type

=======
V1.1.2:
=======

* Dashboard "PieChart: TOP Hosts CPU and Memory Usage" Memory section correction

V1.1.1:
Important update of NMON App which introduces distributed NMON Data collect and Real Time compatibility

* Indexers (or standalone instance) can now activate NMON local data collect upon installation (collect every 2 minutes in default config with 30 seconds data interval)
* A lightweight version of NMON App specifically designed for Splunk forwarders is available in "resources" directory, install it on forwarders and activate the input for your related OS to begin distributed NMON Data collect
* Custom span definition update: The macro is now much more accurate, generated charts give you the better of Splunk charting
* Real Time compatibility: Views can now do Real Time, thus with a limitation (for now) to a 12 hours window
* Important update of Documentation with Deployments scenarios
* Added Inline Help page available within the App
* Added scheduled purge of default NMON repository

=======
V1.1.0:
=======

* Major update of NMON App which introduces compatibility layer with AIX, Linux and Solaris OS Metrics
* New Home Page and navigation scheme between metrics and interfaces that have specific definitions and analysis depending on System type. (eg. NMON TOP sections for example will have different metrics available if you are analyzing an AIX, Linux or Solaris host)
* Global Metrics and Interfaces update for OS compatibility
* The "Global Analysis by host" interface has been renamed as "NMON Analyser" and exists in different versions depending on OS choice
* Processes System resources usage (known as TOP Section) NMON data is now converted with dynamic fields for OS compatibility, users with Linux or Solaris data already indexed should re-index these data
* Corrections on LPAR interface for AIX Virtualized Partitions
* Pivot Model update

=======
V1.0.9:
=======

* Various views corrections and improvements
* New Dashboard (django view) for Process Usage Analysis (NMON TOP Section)
* Span definition macro correction (no span value under certain circumstances)
* Home page margin correction for Firefox browser
* Calendar icon replacement
* Dashboards Django views corrections (empty fields with CPU % monitor)

=======
V1.0.8:
=======

* Icon gray theme changes
* Pivot Model corrections
* README update

=======
V1.0.7:
=======

* third party script corrections (blank lines in csv data generating streaming warn messages in splunkd, various corrections)
* Added support and views for File-Systems Metrics (JFSFILE, JFSINODE)
* Added Support and views for Linux Kernel Virtual Memory Statistics (VM)
* Pivot Model update

=======
V1.0.6:
=======

* Introducing NMON Pivot Data Models in very first versions

=======
V1.0.5:
=======

* Minor views update
* System App dj Page corrected for indexed data summary

=======
V1.0.4:
=======

* Solved NMON data conversion resulting in events duplication within Splunk, if you previously indexed data with anterior version, please delete index and restart Splunk, data will be re-indexed with no duplicates

=======
V1.0.3:
=======

* Minor corrections of various views
* TOP Process section analysis corrections

=======
V1.0.2:
=======

* Documentation update

=======
V1.0.1:
=======

* Home page correction

============
V1.0.0 beta:
============

* First Beta Release, V1.0.0 Beta
