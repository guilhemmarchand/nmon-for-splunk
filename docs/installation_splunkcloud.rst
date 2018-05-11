======================
Deploy to Splunk Cloud
======================

**Deploying Nmon Performance Monitor in Splunk Cloud**

Nmon Performance Monitor is entirely compatible with a Splunk Cloud deployment, offering 100% of application features to monitor your own servers.

However, please note that Splunk does not allow any application to monitor Cloud instances performances, such as the deployment matrix differs from on premise installations.

**Nmon Performance Monitor is a vetted Cloud application, that can be deployed by Cloud Ops teams or in self-service.**

**The PA-nmon_light is a simple package that contains indexing time parsing configuration for Splunk Cloud indexers, and should be deployed by Cloud Ops teams.**

**INDEX CREATION: The index must be created manually using self-services, or on behalf of you by Cloud Ops. The default index model uses an index called "nmon".**

*Matrix deployment for Splunk Cloud:*

+-----------------------------------+------------+---------------+
| Splunk Instance                   | Core App   | PA-nmon_light |
| (role)                            |            |               |
+===================================+============+===============+
| Search head (single or clustered) |     X      |               |
+-----------------------------------+------------+---------------+
| Indexer (single or clustered)     |            |    X          |
+-----------------------------------+------------+---------------+

*The TA-nmon must not be deployed on Splunk Cloud instances.*

As a consequence, you cannot use the Nmon application to monitor Splunk Cloud instances, and this is the only limitation in a Splunk Cloud deployment of the Nmon application for Splunk.

You will then deploy the TA-nmon addon to your servers to send nmon data to Splunk Cloud transparently.

Step 1: Deploy Nmon Core Application to Splunk Cloud
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Splunk Cloud staff will deploy the Nmon core application to your search head node, or if available the application can be deployed by self-services.

Step 2: Deploy the PA-nmon_light to indexers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The PA-nmon_light has to be deployed on Splunk indexers by Splunk Cloud Ops.
This package contains all required configurations for parsing at indexing time.

Step 3: Deploy the TA-nmon to Heavy or Universal Forwarders
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The last step is to deploy the TA-nmon (or derived) to your servers running a Splunk Universal forwarder.

Configure Forwarding to Splunk Cloud
""""""""""""""""""""""""""""""""""""

This step is part of a Splunk Cloud deployment, your Universal Forwarders instances have to be configured with the authentication application provded by Splunk Cloud staff.

Deploying the TA-nmon
"""""""""""""""""""""

**Finally deploy the TA-nmon to your Universal Forwarder instance(s):**

* Upload the TA-nmon package to your servers

* Install the TA-nmon:

**Manually:**

The TA-nmon tgz archive must be uncompressed and installed in the indexer in $SPLUNK_HOME/etc/deployment-apps/ (where $SPLUNK_HOME refers to the root directory of Splunk installation)

::

    cd /opt/splunkforwarder/etc/apps

    tar -xvzf /tmp/TA-nmon_*.tar.gz

And Restart the Universal Forwarder.

**Using Splunk CLI:**

You can install the TA-nmon using Splunk CLI:

::

    /opt/splunkforwarder/bin/splunk install app /tmp/TA-nmon_*.tar.gz -auth admin:changeme

Restart the Universal Forwarder

**Example:**

::

    [root@RHEL7 ~]# /opt/splunkforwarder/bin/splunk install app /media/BIGDATA/TA-nmon_V1.2.27.tar.gz -auth admin:changeme
    App '/media/BIGDATA/TA-nmon_V1.2.27.tar.gz' installed
    You need to restart the Splunk Server (splunkd) for your changes to take effect.

    [root@RHEL7 ~]# /opt/splunkforwarder/bin/splunk restart
    Stopping splunkd...
    Shutting down.  Please wait, as this may take a few minutes.
                                                               [  OK  ]
    Stopping splunk helpers...
                                                               [  OK  ]
    Done.

    Splunk> The Notorious B.I.G. D.A.T.A.

    Checking prerequisites...
        Checking mgmt port [8089]: open
        Checking conf files for problems...
        Done
    All preliminary checks passed.

    Starting splunk server daemon (splunkd)...
    Done
                                                               [  OK  ]
    [root@RHEL7 ~]#

Check your work and verify incoming Performance events
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A few minutes later you will immediately start to receive incoming Performance data from your servers:

.. image:: img/install_splunkcloud9.png
   :alt: install_splunkcloud9.png
   :align: center

And you will find incoming data from your host(s):

.. image:: img/install_splunkcloud10.png
   :alt: install_splunkcloud10.png
   :align: center

Recommended: After you added new hosts to your deployment, you can immediately update configuration information by running the dedicated report (this is operation is done by default every hour):

.. image:: img/install_splunkcloud11.png
   :alt: install_splunkcloud11.png
   :align: center

Et voilà !!! There you go, enjoy :-)
