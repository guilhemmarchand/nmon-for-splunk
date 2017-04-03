
#########################################
About Nmon Performance monitor for Splunk
#########################################

* Author: Guilhem Marchand

* First release was published on starting 2014

* Purposes:

The Nmon Performance application for Splunk implements the excellent and powerful nmon binary known as Nigel's performance monitor.
Originally developed for IBM AIX performance monitoring and analysis, it is now an Open source project that made it available to many other systems.
It is fully available for any Linux flavor, and thanks to the excellent work of Guy Deffaux, it also available for Solaris 10/11 systems using the sarmon project.

The Nmon Performance monitor application for Splunk will generate performance and inventory data for your servers, and provides a rich number of monitors and tools to manage your AIX / Linux / Solaris systems.

.. image:: img/Octamis_Logo_v3_no_bg.png
   :alt: Octamis_Logo_v3_no_bg.png
   :align: right
   :target: http://www.octamis.com

**Nmon Performance is now associated with Octamis to provide professional solutions for your business, and professional support for the Nmon Performance solution.**

*For more information:* :ref:`octamis_support`

---------------
Splunk versions
---------------

It is recommended to use Splunk 6.5.x or superior to run the latest core application release. (in distributed deployments, only search heads may have this requirement)

The last release can be downloaded from Splunk base: https://splunkbase.splunk.com/app/1753

**Compatibility matrix for core application:**

* **Current major release Version 1.9.x:** Splunk 6.5.x or superior

**Stopped versions for older Splunk releases:**

* Last version compatible with Splunk 6.4.x with release 1.7.9 (Splunk certified): https://github.com/guilhemmarchand/nmon-for-splunk/releases

* Last version compatible with Splunk 6.2.x with release 1.6.15 (Splunk certified): https://github.com/guilhemmarchand/nmon-for-splunk/releases

* Last version compatible with Splunk 6.1.x, with release 1.4.902 (not Splunk certified): https://github.com/guilhemmarchand/nmon-for-splunk/blob/last_release_splunk_61x

**Compatibility matrix for TA-nmon addon:**

Consult the TA-nmon documentation: http://ta-nmon.readthedocs.io

* Both add-ons are compatible with any Splunk version 6.x (full instance of Universal Forwarder)

The TA-nmon add-on is available in the resources directory of the core application.

It is designed to be deployed on full Splunk instances or Universal Forwarders, **it is only compatible with Splunk 6.x.**

The PA-nmon_light add-on is a minimal addon designed to be installed on indexers (clusters or standalone), this package contains the default "nmon" index definition and parsing configuration. It excludes any kind of binaries, inputs or scripts, and does not collect nmon data.

---------------------
Index time operations
---------------------

The application operates index time operation, the PA-nmon_light add-on must be installed in indexers in order for the application to operate normally.

If there are any Heavy forwarders acting as intermediate forwarders between indexers and Universal Forwarders, the TA-nmon add-on must deployed on the intermediate forwarders to achieve successfully index time extractions.

--------------
Index creation
--------------

**The Nmon core application does not create any index at installation time.**

An index called "nmon" must be created manually by Splunk administrators to use the default TA-nmon indexing parameters. (this can be tuned)

However, deploying the PA-nmon_light will automatically defines the default "nmon" index. (pre-configured for clusters replication)

Note: The application supports any index starting with the "nmon*" name, however the default index for the TA-nmon inputs is set to "nmon" index.

In distributed deployments using clusters of indexers, the PA-nmon add-on will automatically creates the "nmon" replicated index.

----------------------------
Summarization implementation
----------------------------

Nmon for Splunk App intensively uses data model acceleration in almost every user interfaces, reports and dashboards.
The application provides multiple data models that have the acceleration activated by default using "All time" as the time range limit.

Splunk Accelerated data models provide a great and performer user experience.

The application does not use any accelerated reports.

------------------------------
About Nmon Performance Monitor
------------------------------

Nmon Performance Monitor for Splunk is provided in Open Source, you are totally free to use it for personal or professional use without any limitation,
and you are free to modify sources or participate in the development if you wish.

**Feedback and rating the application will be greatly appreciated.**

* Join the Google group: https://groups.google.com/d/forum/nmon-splunk-app

* App's Github page: https://github.com/guilhemmarchand/nmon-for-splunk

* Videos: https://www.youtube.com/channel/UCGWHd40x0A7wjk8qskyHQcQ

* Gallery: https://flic.kr/s/aHskFZcQBn