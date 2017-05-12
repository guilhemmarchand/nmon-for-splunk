########
Download
########

Official Splunk certified release
=================================

The official and Splunk certified release of the Nmon core application can be downloaded from Splunk Base: https://splunkbase.splunk.com/app/1753

TA-nmon
=======

The official release of the TA-nmon can be downloaded from Splunk Base: https://splunkbase.splunk.com/app/3248

Note: The TA-nmon is NOT Splunk certified for some reasons, specially because it contains various binaries, and this would restrict the TA-nmon features.

Github releases
===============

The Nmon Performance Monitor is hosted on a Github project, you can freely download the application from the Github project page: https://github.com/guilhemmarchand/nmon-for-splunk

The TA-nmon has also its own Github project: https://github.com/guilhemmarchand/TA-nmon

**About main branches and associated versions:**

+------------------------------------------------------------+------------+----------+----------+
| Github branch                                              | master     | release  | testing  |
|                                                            |            |          |          |
+============================================================+============+==========+==========+
| Stable and eligible for Splunk Base publication            |     X      |          |          |
+------------------------------------------------------------+------------+----------+----------+
| Pre-release under qualification cycle, can break things    |            |    X     |          |
+------------------------------------------------------------+------------+----------+----------+
| Unstable and under heaby testing, can break things         |            |          |     X    |
+------------------------------------------------------------+------------+----------+----------+

**Downloading and installing from Github:**

For the Nmon core application:

- Visit the Git repository: https://github.com/guilhemmarchand/nmon-for-splunk
- Download the latest tgz archive available at the root of the project page
- Install the application as usual

For the TA-nmon add-on:

- Visit the Git repository: https://github.com/guilhemmarchand/TA-nmon
- Download the latest tgz archive available at the root of the project page
- Install the application as usual

For the PA-nmon_light add-on:

- Visit the Git repository: https://github.com/guilhemmarchand/PA-nmon_light
- Download the latest tgz archive available at the root of the project page
- Install the application as usual

Stopped releases for old Splunk versions
========================================

As the Nmon Performance Monitor attempts to get the better from Splunk new features, it is possible that new releases will stop being compatible with old Splunk versions.

*Currently, here are stopped versions for older Splunk releases:*

* Last version compatible with Splunk 6.1.x, with release 1.4.902 (not Splunk certified)

https://github.com/guilhemmarchand/nmon-for-splunk/blob/last_release_splunk_61x

* Last version compatible with Splunk 6.2.x with release 1.6.15 (Splunk certified)

https://github.com/guilhemmarchand/nmon-for-splunk/releases

* Last version compatible with Splunk 6.4.x and Splunk 6.3.x with release 1.7.9 (Splunk certified)

https://github.com/guilhemmarchand/nmon-for-splunk/releases
