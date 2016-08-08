#################
Deployment Matrix
#################

What goes where
---------------

* Core App: This is the full package you download in Splunk Base (tgz archive)

* PA-nmon: Is available in the resources directory of the Core App (tgz archive)

* TA-nmon: Is available in the resources directory of the Core App (tgz archive)

**Since July 2016, the TA-nmon is also available for download as en entire application in Splunk base:** https://splunkbase.splunk.com/app/3248/

**Standalone deployment: A single Splunk instance does all**

+------------------------+------------+----------+-------------------+
| Splunk Instance        | Core App   | PA-nmon  | TA-nmon           |
| (role description)     |            |          |                   |
+========================+============+==========+===================+
| Standalone             |     X      |          | X (optional)      |
+------------------------+------------+----------+-------------------+

*The TA-nmon provides nmon performance and configuration collection for the host than runs the add-on, which is optional*

**Distributed deployment:**

+--------------------------------------------+------------+----------+---------------------+
| Splunk Instance                            | Core App   | PA-nmon  | TA-nmon             |
| (role description)                         |            |          |                     |
+============================================+============+==========+=====================+
| Search head (single instance or clustered) |     X      |          |    X (optional)     |
+--------------------------------------------+------------+----------+---------------------+
| Indexer (single instance or clustered)     |            |    X     |                     |
+--------------------------------------------+------------+----------+---------------------+
| Master node                                |            |          |    X (optional)     |
+--------------------------------------------+------------+----------+---------------------+
| Deployment servers                         |            |          |    X (optional)     |
+--------------------------------------------+------------+----------+---------------------+
| Heavy Forwarder                            |            |          |    X                |
+--------------------------------------------+------------+----------+---------------------+
| Universal Forwarder                        |            |          |    X                |
+--------------------------------------------+------------+----------+---------------------+

*The TA-nmon provides nmon performance and configuration collection for the host than runs the add-on, which is optional*

**FAQ:**

* What is the difference between the PA-nmon and the TA-nmon ?

*The PA-nmon is the light addon dedicated for indexers, it is very closed to the TA-nmon, but it is adapted to
be able to automatically generate Nmon performance data for your distributed indexers.
The PA-nmon addon will be included in the bundle configuration published to indexers by the master node.*
