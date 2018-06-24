#################
Deployment Matrix
#################

What goes where ?
-----------------

Application stack components
++++++++++++++++++++++++++++

+--------------------------------------------+--------------------------------------------------------------+--------------------------------+
| Component name                             |                     Purpose                                  |   Installation                 |
|                                            |                                                              |                                |
+============================================+==============================================================+================================+
| nmon-for-splunk                            | Front-user core application                                  | Search Heads                   |
+--------------------------------------------+--------------------------------------------------------------+--------------------------------+
| PA-nmon_light                              | Support Add-on for index-time configurations                 | Indexers / intermediate HF     |
+--------------------------------------------+--------------------------------------------------------------+--------------------------------+
| TA-nmon                                    | Technical Add-on for metrics and inventory generation        | Each monitored server          |
+--------------------------------------------+--------------------------------------------------------------+--------------------------------+
| TA-nmon-hec                                | Technical Add-on for metrics and inventory generation        | Each monitored server          |
+--------------------------------------------+--------------------------------------------------------------+--------------------------------+

**ONLY** one technical addon must be deployed on the same host, **BUT** you can mix any both types of addons in your deployment.

Splunk Standalone deployment
++++++++++++++++++++++++++++

**A standalone Splunk installation means that all the Splunk roles are performed by the same instance, most likely for testing and development purposes.**

+--------------------------------------------+---------------------+------------------------+-------------------------+
| Splunk roles                               | nmon-for-splunk     | PA-nmon_light          |  TA-nmon-*              |
+============================================+=====================+========================+=========================+
| Standalone                                 |     X               |    X (optional)        |    X (optional)         |
+--------------------------------------------+---------------------+------------------------+-------------------------+

*The Technical Add-ons provide performance and configuration collection for the host than runs the add-on, which is optional*

Distributed deployment
++++++++++++++++++++++

**A Splunk distributed deployment is a Splunk infrastructure where specific Splunk roles are dedicated to specific instances.**

*For more information:*
http://docs.splunk.com/Documentation/Splunk/latest/Deploy/Indexercluster

The application stack is fully compatible with any kind of Splunk distributed deployment.

+----------------------+---------------------+----------------------------+-----------------------------+
| Splunk roles         | nmon-for-splunk     | PA-nmon_light              |  TA-nmon-*                  |
+======================+=====================+============================+=============================+
| Search head          |   X                 |                            |    X (optional)             |
+----------------------+---------------------+----------------------------+-----------------------------+
| Indexer              |                     |  X                         |    X (optional)             |
+----------------------+---------------------+----------------------------+-----------------------------+
| Master node          |                     |                            |    X (optional)             |
+----------------------+---------------------+----------------------------+-----------------------------+
| Deployment server    |                     |                            |    X (optional)             |
+----------------------+---------------------+----------------------------+-----------------------------+
| Heavy Forwarder      |                     | X (if TA is not installed) |    X                        |
+----------------------+---------------------+----------------------------+-----------------------------+
| Universal Forwarder  |                     |                            |    X                        |
+----------------------+---------------------+----------------------------+-----------------------------+

*The Technical Add-on provides performance and configuration collection for the host than runs the add-on, which is optional*
