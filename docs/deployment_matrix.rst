#################
Deployment Matrix
#################

What goes where ?
-----------------

*Software components:*

* **Core App**: This is the full package you download in Splunk Base (tgz archive)

* **PA-nmon_light**: Available in the resources directory of the Core App (tgz archive)

* **TA-nmon**: Available in the resources directory of the Core App (tgz archive)

**The TA-nmon is also available for download as an independent application in Splunk base:** https://splunkbase.splunk.com/app/3248/

*Notes:*

* The TA-nmon_selfmode is deprecated since the unarchive_cmd feature isn't used anymore
* The PA-nmon is deprecated since the TA-nmon operates now in clustered indexers

**Standalone deployment: A single Splunk instance does all**

+--------------------------------------------+---------------------+---------------------+---------------------+
| Splunk Instance                            | Core App            | PA-nmon_light       | TA-nmon             |
| (role)                                     |                     |                     |                     |
+============================================+=====================+=====================+=====================+
| Standalone                                 |     X               |    X (optional)     |    X (optional)     |
+--------------------------------------------+---------------------+---------------------+---------------------+

*The TA-nmon provides performance and configuration collection for the host than runs the add-on, which is optional*

**Distributed deployment:**

+--------------------------------------------+---------------------+---------------------+---------------------+
| Splunk Instance                            | Core App            | PA-nmon_light       | TA-nmon             |
| (role)                                     |                     |                     |                     |
+============================================+=====================+=====================+=====================+
| Search head (single or clustered)          |     X               |                     |    X (optional)     |
+--------------------------------------------+---------------------+---------------------+---------------------+
| Indexer (single or clustered)              |                     |    X                |                     |
+--------------------------------------------+---------------------+---------------------+---------------------+
| Master node                                |                     |                     |    X (optional)     |
+--------------------------------------------+---------------------+---------------------+---------------------+
| Deployment servers                         |                     |                     |    X (optional)     |
+--------------------------------------------+---------------------+---------------------+---------------------+
| Heavy Forwarder                            |                     |                     |    X                |
+--------------------------------------------+---------------------+---------------------+---------------------+
| Universal Forwarder                        |                     |                     |    X                |
+--------------------------------------------+---------------------+---------------------+---------------------+

*The TA-nmon provides performance and configuration collection for the host than runs the add-on, which is optional*

**FAQ:**

* What is the difference between the PA-nmon_light and the TA-nmon ?

The PA-nmon_light does not contain any binaries, scripts or inputs. It is designed to be installed on indexers. (standalone or clustered)

This package will define the default "nmon" index and the relevant configuration items at indexing time.
