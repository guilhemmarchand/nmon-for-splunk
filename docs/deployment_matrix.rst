#################
Deployment Matrix
#################

What goes where
---------------

*Software components:*

* **Core App**: This is the full package you download in Splunk Base (tgz archive)

* **PA-nmon**: Available in the resources directory of the Core App (tgz archive)

* **PA-nmon_light**: Available in the resources directory of the Core App (tgz archive)

* **TA-nmon**: Available in the resources directory of the Core App (tgz archive)

* **TA-nmon_selfmode**: Available in the resources directory of the Core App (tgz archive)

**Since July 2016, the TA-nmon is also available for download as en entire application in Splunk base:** https://splunkbase.splunk.com/app/3248/

**Standalone deployment: A single Splunk instance does all**

+------------------------+------------+---------------+---------------+
| Splunk Instance        | Core App   | PA-nmon       | TA-nmon       |
| (role)                 |            | (and derived) | (and derived) |
+========================+============+===============+===============+
| Standalone             |     X      |               | X (optional)  |
+------------------------+------------+---------------+---------------+

*The TA-nmon provides nmon performance and configuration collection for the host than runs the add-on, which is optional*

**Distributed deployment:**

+--------------------------------------------+------------+---------------------------+---------------------+
| Splunk Instance                            | Core App   | PA-nmon (and derived)     | TA-nmon             |
| (role)                                     |            |                           |                     |
+============================================+============+===========================+=====================+
| Search head (single instance or clustered) |     X      |                           |    X (optional)     |
+--------------------------------------------+------------+---------------------------+---------------------+
| Indexer (single instance or clustered)     |            |    X                      |                     |
+--------------------------------------------+------------+---------------------------+---------------------+
| Master node                                |            |                           |    X (optional)     |
+--------------------------------------------+------------+---------------------------+---------------------+
| Deployment servers                         |            |                           |    X (optional)     |
+--------------------------------------------+------------+---------------------------+---------------------+
| Heavy Forwarder                            |            |                           |    X                |
+--------------------------------------------+------------+---------------------------+---------------------+
| Universal Forwarder                        |            |                           |    X                |
+--------------------------------------------+------------+---------------------------+---------------------+

*The TA-nmon provides nmon performance and configuration collection for the host than runs the add-on, which is optional*

**FAQ:**

* What is the difference between the PA-nmon and the TA-nmon ?

*The PA-nmon is the light add-on dedicated for indexers, it is very closed to the TA-nmon, but it is adapted to
be able to automatically generate Nmon performance data for your distributed indexers.
The PA-nmon add-on will be included in the bundle configuration published to indexers by the master node.*

* What is the difference between the TA-nmon and the TA-nmon_selfmode ?

*The TA-nmon_selfmode is an alternative to the TA-nmon deployment. Instead of using a Splunk feature called "unarchive_cmd" to monitor nmon raw data files, this package implements a simple script that will run
every minute to monitor nmon raw files. If required, this script will take care of sending the file content to nmon2csv parsers.
Under normal conditions you should use the TA-nmon, but if you encounter any unexpected and unsolved issue with the Splunk unarchive processor, the TA-nmon_selfmode shall be used.
Note that the TA-nmon_selfmode will be able to monitor extra location of nmon files such as external repositories, as such it cannot be used in these scenarios of implementation.*

* What is the difference between the PA-nmon and the PA-nmon_light ?

*The PA-nmon_light does not contain any binaries, scripts or inputs. It is designed to be installed on indexers (standalone or clustered) that must not monitor performance of indexers, such as Splunk Cloud indexer instances.
As such, the PA-nmon_light can be used instead of the PA-nmon to ensure correct event indexing in your deployment.*
