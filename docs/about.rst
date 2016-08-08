
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

---------------
Splunk versions
---------------

It is recommended to use Splunk 6.4.x or superior to run the core application. (in distributed deployments, only search heads will have this requirement)

The last release can be downloaded from Splunk base: https://splunkbase.splunk.com/app/1753

**Compatibility matrix for core application:**

* **Current major release Version 1.7.x:** Splunk 6.4.x or superior, limited compatibility with Splunk 6.3.x, see :any:`update_from_version_prior_17`

**Stopped versions for older Splunk releases:**

* Last version compatible with Splunk 6.2.x with release 1.6.15 (Splunk certified): https://github.com/guilhemmarchand/nmon-for-splunk/releases

* Last version compatible with Splunk 6.1.x, with release 1.4.902 (not Splunk certified): https://github.com/guilhemmarchand/nmon-for-splunk/blob/last_release_splunk_61x

**Compatibility matrix for TA-nmon and PA-nmon technical add-ons:**

* Both add-ons are compatible with any Splunk version 6.x (full instance of Universal Forwarder)

The TA-nmon add-on available in the resources directory of the core application is designed to be installed in Universal Forwarders end clients or Heavy Forwarders, it is only compatible with Splunk 6.x (Splunk 5.x and prior will not be able to extract fields definition from generated data, leading to the application being unable to analyse performance data)

The PA-nmon add-on available in the resources directory of the core application is designed to be installed in indexers (clusters or standalone), it is compatible with Splunk 6.x (Splunk 5.x shall not be used as the App intensively uses data model acceleration which is not available in Splunk 5.x and prior)

---------------------
Index time operations
---------------------

The application operates index time operation, the PA-nmon add-on must be installed in indexers in order for the application to operate normally.
In complex distributed deployments, Heavy Forwarders (which are full Splunk instances) can operate as intermediate collectors between indexers and Universal Forwarder clients, in such a case Heavy Forwarders with the TA-nmon add-on installed will operate index time parsing and will free indexers from these tasks.

--------------
Index creation
--------------

Since the major release V1.7, the core application does not create anymore any index at installation time.

An index called "nmon" must be created manually by Splunk administrators.

In distributed deployments using clusters of indexers, the PA-nmon add-on will automatically creates the "nmon" replicated index

----------------------------
Summarization implementation
----------------------------

Nmon for Splunk App intensively uses data model acceleration in almost every user interfaces, reports and dashboards.
The application provides multiple data models that have the acceleration activated by default using "All time" as the time range limit.

Because of the richness of Nmon monitors, and with large deployments, accelerated data model offers an improved user experience.
Note that some minor scheduled reports that keep users informed of the application activity in home page uses standard acceleration.

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