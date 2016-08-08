########
Download
########

Official Splunk certified release
=================================

The official and Splunk certified release of the Nmon core application can be downloaded from Splunk Base: https://splunkbase.splunk.com/app/1753

The official release of the TA-nmon can be downloaded from Splunk Base: https://splunkbase.splunk.com/app/3248

Github releases
===============

The Nmon Performance Monitor is hosted on a Github project, you can freely download the application from the Github project page: https://github.com/guilhemmarchand/nmon-for-splunk

The TA-nmon has also its own Github project: https://github.com/guilhemmarchand/TA-nmon

An alternative version of the TA-nmon called "TA-nmon_selfmode" is also available for download from Github: https://github.com/guilhemmarchand/TA-nmon_selfmode

*This TA-nmon alternative package is supported on Splunk instances and will implement an input script to monitor nmon files instead of the Splunk TailRead / ArchiveProcessor, you should only use in case of unexpected issue with Splunk.*


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

You can download and install Nmon Performance monitor App directly from git using the git command:

::

    git clone https://github.com/guilhemmarchand/nmon-for-splunk.git
    mv nmon-for-splunk nmon

And you can also download the project content as zip archives from the Github web page.

**IMPORTANT**:

When downloading from Github, you MUST rename the directory to "nmon" or the Application will be broken

Stopped releases for old Splunk versions
========================================

As the Nmon Performance Monitor attempts to get the better from Splunk new features, it is possible that new releases will stop being compatible with old Splunk versions.

*Currently, here are stopped versions for older Splunk releases:*

* Last version compatible with Splunk 6.1.x, with release 1.4.902 (not Splunk certified)

https://github.com/guilhemmarchand/nmon-for-splunk/blob/last_release_splunk_61x

* Last version compatible with Splunk 6.2.x with release 1.6.15 (Splunk certified)

https://github.com/guilhemmarchand/nmon-for-splunk/releases





