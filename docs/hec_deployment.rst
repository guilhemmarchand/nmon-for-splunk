.. _hec_deployment:

===================================
Splunk HEC / nmon-logger deployment
===================================

**The "nmon-logger" package for Splunk HEC provides a 100% agent less configuration using the Splunk http input:**

.. image:: img/splunk_hec_deployment.png
   :alt: splunk_hec_deployment.png
   :align: center

The nmon-logger is **not** a Splunk application, this is an independent package to be deployed to your Operating System.

**This deployment provides the following features:**

* **clients easy set up:** the nmon-logger is provided as deb/rpm package, easy and fast deployment
* **server easy set up:** Splunk http input is easy to configure and implement
* **100% agent less:** the nmon-logger uses only native system features (cron, logrotate...)
* **secure:** Splunk http traffic can easily be encrypted via SSL and integrated into any DMZ or similar restricted networking layer
* **resilient and scalable:** using load balancers and multiple nodes provides resiliency and horizontal scalability
* **network friendly:** as Web service, it can be easily used across wide networks and over the Internet
* **easy management:** since the http input is managed on a token basis, you can easily configure different token to ingest the data into different indexes without any package modification or complexity

*****************
Deployment matrix
*****************

+--------------------------------------------+---------------------+---------------------+---------------------+---------------------+
| Splunk Instance                            | Core App            | PA-nmon_light       | TA-nmon             | nmon-logger         |
| (role)                                     |                     |                     |                     |                     |
+============================================+=====================+=====================+=====================+=====================+
| Search head (single or clustered)          |     X               |                     |    X (optional)     |                     |
+--------------------------------------------+---------------------+---------------------+---------------------+---------------------+
| Indexer (single or clustered)              |                     |    X                |    X (optional)     |                     |
+--------------------------------------------+---------------------+---------------------+---------------------+---------------------+
| Master node                                |                     |                     |    X (optional)     |                     |
+--------------------------------------------+---------------------+---------------------+---------------------+---------------------+
| Deployment servers                         |                     |                     |    X (optional)     |                     |
+--------------------------------------------+---------------------+---------------------+---------------------+---------------------+
| Heavy Forwarder                            |                     |                     |    X                |                     |
+--------------------------------------------+---------------------+---------------------+---------------------+---------------------+
| Universal Forwarder                        |                     |                     |    X                |                     |
+--------------------------------------------+---------------------+---------------------+---------------------+---------------------+
| Client servers                             |                     |                     |                     |    X                |
+--------------------------------------------+---------------------+---------------------+---------------------+---------------------+

**Notes:**

* Indexing time parsing operations require the PA-nmon_light or the TA-nmon (or both) to be deployed on the host running the http input
* The Nmon core app **version 1.9.10** minimal, TA-nmon **version 1.3.27** minimal and PA-nmon_light **version 1.3.19** are required on the Splunk infrastructure
* The http input can run either on indexers, or one or more heavy forwarders

**Fast testing using Vagrant and Ansible:**

If you are interested in a very fast and automated way to test the Nmon Performance Application with an HEC nmon-logger deployment, checkout the provided configuration using the excellent Vagrant (https://www.vagrantup.com/) and Ansible configuration management (http://docs.ansible.com/ansible/index.html)

* Checkout: https://github.com/guilhemmarchand/nmon-logger/tree/master/vagrant-ansible-demo-splunk-hec

In about 5 minutes, have a running and automated deployment working !

******************************
HEC performance considerations
******************************

**For best HEC performance purposes, the nmon-logger works the following way:**

* performance and configuration data are streamed in "batch" mode, which means we only generate one HEC connection for each during an occurrence of the nmon_processing (which occurs every minute)
* collection, processing and other data being generated by the nmon-logger work as well in batch mode, one connection per processing streams the full data
* most of Metadata are part of each event sent to the HEC

**See:** http://dev.splunk.com/view/event-collector/SP-CAAAE73

*******************************************
Download the nmon-logger-splunk-hec package
*******************************************

**The nmon-logger-splunk-hec** package is available in the Github repository of the nmon-logger:

* https://github.com/guilhemmarchand/nmon-logger

The nmon-logger is provided as a deb and rpm package for Linux OS and AIX, it has been tested against:

* Ubuntu (x86 and Powerpc)
* Debian (x86)
* CentOS (x86)
* RHEL (x86 and Powerpc)
* Suse (x86 and Powerpc)
* OpenSuse (x86)
* AIX 7.1
* AIX 7.2

*************************************************
Activate the Splunk http input and create a token
*************************************************

**The Splunk configuration is really straightforward, it is all about:**

* Activating and the http input: configuring the http port, choosing between http and https
* Creating a token for the nmon data (1 token for all data, but you can create multiple tokens for different servers deployement)

**Notes:**

* http and https are supported
* indexer acknowledgment is not currently supported (configured per token)
* the nmon-logger will not explicitly specify an index, you choose the index to be used on a per token basis
* Any index name starting by "nmon" is natively taken in charge by the Nmon Performance application
* If you choose a different index name that does not match the rule above, you just need to customize the eventtypes.conf and macros.conf of the Nmon app
* it is not required to define any sourcetype / source by default

**In a nutshell:**

.. image:: img/hec_deployment_screen.png
   :alt: hec_deployment_screen.png
   :align: center

.. image:: img/hec_deployment_screen1.png
   :alt: hec_deployment_screen1.png
   :align: center

.. image:: img/hec_deployment_screen2.png
   :alt: hec_deployment_screen2.png
   :align: center

.. image:: img/hec_deployment_screen3.png
   :alt: hec_deployment_screen3.png
   :align: center

**Configuration files:**

* "$SPLUNK_HOME/etc/apps/splunk_http_input/local/inputs.conf":

::

    [http]
    disabled = 0

* "$SPLUNK_HOME/etc/apps/<appname>/local/inputs.conf":

*Notes: replace <appname> with the application context where you want to store the configuration inputs.conf file*

::

    # inputs.conf

    # Enable the HEC
    [http]
    disabled = 0
    enableSSL = 1

    # HEC endpoint for clients
    [http://nmon-hec-input]
    disabled = 0
    index = nmon_hec
    indexes = nmon_hec
    token = CEE56643-BA2D-48EE-94EF-AD0909718B2A

*****************************************
Deploying the nmon-logger to your servers
*****************************************

--------
Linux OS
--------

This is package (no arch) to be deployed, which is obviously straight forward:

**deb based OS:**

::

    dpkg -i nmon-logger-splunk-hec-*.deb

**rpm based OS:**

::

    rpm -i nmon-logger-splunk-hec-*.rpm

**Notes:**

- Host running SeLinux (likely RHEL for instance) need to have the "permissive mode" enabled for the rpm installation or the groupadd operation might fail:

::

    sudo setenforce 0

- Some systems (likely on RHEL), the perl-Time-HiRes may not be installed by default:

::

    yum install -y perl-Time-HiRes

------
AIX OS
------

Download the rpm package according to your version, and install as usual:

**rpm based OS:**

::

    rpm -i nmon-logger-splunk-hec-*.rpm

*Notes about AIX 6.1: the nmon-logger has not been tested against out of support AIX version but is expected to operate normally*

**Installing rpm package manager:**

See: https://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/ezinstall/ppc/README-yum

***************************
Configuring the nmon-logger
***************************

The data collection starts 1 minute maximum after the package deployment, as long as you don't have configured the URL and token, **the data is only generated locally on the file system**.

**Create a local directory:**

::

    mkdir /etc/nmon-logger/local

**Create a local/nmon.conf and insert your URL / Token:**

*/etc/nmon-logger/local/nmon.conf, example:*

::

    # HEC server configuration

    nmon2csv_options="--mode fifo --silent --splunk_http_url https://192.168.33.100:8088/services/collector/event --splunk_http_token CEE56643-BA2D-48EE-94EF-AD0909718B2A"

**Et voila!**

Once the nmon-logger package is configured and if the networking configuration is properly configured, Splunk will start receiving data through the http input !

***************************
Foot-print and benchmarking
***************************

The **nmon-logger** globally shares the same components than the **TA-nmon**, as the difference that the CSV data is being transformed into key value data and streamed to the Splunk http input. (nmon2csv parsers are nmon2kv!)

**See:**

* http://ta-nmon.readthedocs.io/en/latest/processing_overview.html
* http://ta-nmon.readthedocs.io/en/latest/data_processing.html
* http://ta-nmon.readthedocs.io/en/latest/footprint.html

The foot-print related to the generation, processing and streaming of the performance and configuration data is very low, it is actually even lower than the TA-nmon since there are no overhead due to the Splunk instance.

**Bellow are benchmarking generated via the IBM Power Development Platform (PDP), against various Linux and AIX flavour:**

LINUX BENCHMARKS:
-----------------

**SUSE Linux 12.2 LE (IBM POWER 8):**

*date 02/08/2017, nmon-logger release 2.0.05*

**Ubuntu Linux 14.04 LTS (IBM POWER 8):**

*date 02/08/2017, nmon-logger release 2.0.05*

**Redhat Linux 7.3 LE (IBM POWER 8):**

*date 02/08/2017, nmon-logger release 2.0.05*

**Redhat Linux 6.9 BE (IBM POWER 8):**

*date 02/08/2017, nmon-logger release 2.0.05*


IBM AIX BENCHMARKS:
-------------------

**IBM AIX 7.1 ON POWER8 / Entitled 0.2 / VirtualCPUs 1:**

*date 27/03/2013, nmon-logger release 2.0.05*


