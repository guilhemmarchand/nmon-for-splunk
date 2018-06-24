
======================
Deploy to Splunk Cloud
======================

Splunk Cloud compatibility and limitations
==========================================

In a nutshell, the "mnmon-for-splunk" application will be deployed to your ad-hoc search head and the "PA-nmon_light" will be deployed
by Splunk Cloud operations to your indexers stack.

To achieve this, submit a ticket to Splunk Cloud Ops to request the deployment of the Support Addon. (which gets deployed to the cluster master and then pushed to the indexers)

Then the application must be deployed on the Splunk Cloud search head, when an application has been vetted for Cloud Ops, this can be done as a self-service. (Otherwise submit the request to Cloud Ops teams)

Finally, you will use your own on premise tools to push and deploy the Technology Addon to your servers, which can forward either directly to your Splunk Cloud indexers (recommended) or through your on-prem intermediate forwarders.

The "nmon" index creation can be done as a self-service (Settings / Indexes) or requested to Cloud Ops in the same time.

Splunk Cloud deployment matrix
==============================

*Splunk Cloud components:*

+----------------------+---------------------+------------------------+-------------------------+
| Splunk roles         | nmon-for-splunk     | PA-nmon_light          |  TA-nmon-*              |
+======================+=====================+========================+=========================+
| Search head          |     X               |                        |                         |
+----------------------+---------------------+------------------------+-------------------------+
| Indexer              |                     |    X                   |                         |
+----------------------+---------------------+------------------------+-------------------------+

*The Support Add-on does not generate any collection, but defines the replicated nmon index and contains index time configuration settings.*


*On premise components: (you may not have all these roles on-premise depending on your configuration)*

+----------------------+---------------------+------------------------+-------------------------+
| Splunk roles         | nmon-for-splunk     | PA-nmon_light          |  TA-nmon-*              |
+======================+=====================+========================+=========================+
| Search head          |     X               |                        |    X (optional)         |
+----------------------+---------------------+------------------------+-------------------------+
| Indexer              |                     |    X                   |    X (optional)         |
+----------------------+---------------------+------------------------+-------------------------+
| Master node          |                     |                        |    X (optional)         |
+----------------------+---------------------+------------------------+-------------------------+
| Deployment server    |                     |         Conditional    |    Conditional          |
+----------------------+---------------------+------------------------+-------------------------+
| Heavy Forwarder      |                     |        Conditional     |      Conditional        |
+----------------------+---------------------+------------------------+-------------------------+
| Universal Forwarder  |                     |                        |    X                    |
+----------------------+---------------------+------------------------+-------------------------+

*The Technology Add-ons provide metrics and configuration collection for the host than runs the add-on, which is optional.*

*The Support Add-on does not generate any collection, but defines the replicated nmon index and contains index time configuration settings.*
