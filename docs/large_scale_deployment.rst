
=====================================
Large scale deployment considerations
=====================================

**If you are planing to deploy Nmon in a large scale scenario for thousands of servers, please read carefully the following documentation.**

Nmon for Splunk Enterprise can easily be deployed to thousands and thousands of nodes, however there are things that should be considered to optimize at the best your Splunk and Nmon deployment.

Data model acceleration
"""""""""""""""""""""""

Accelerated data models are massively used in the application, this implementation provides exceptional performances of searches, and a great user experience.
However, data models have a cost in term of storage and system resources utilization for acceleration build and maintenance.

By default, all data models are accelerated over the "All time" period, these settings are managed in the following configuration file:

*nmon/default/datamodels.conf*

::

    acceleration.earliest_time = 0

Restricting the acceleration period will helping reducing:

- The amount of storage used per data model for the acceleration
- The amount of time required for initial build or total rebuild of the acceleration, as well as the amount of system resources (CPU, memory) that are temporarily required on indexers to build the acceleration

Note that The maintenance cost, which refers to operation that Splunk operates periodically to maintain the state of acceleration, will not necessary be different with a large or a small period.

Also, rolling restart of clustered indexers will generate a partial verification and/or rebuild of data model acceleration, with large set of data this can imply a temporarily high level of resource usage on indexers following the rolling restart.

Finally, take care of not reducing too much the acceleration period, searches out of the acceleration period are still possible but at the price of much more poor performances.

**Restricting the acceleration period of data models:**

*please refer to Splunk documentation:* https://docs.splunk.com/Documentation/Splunk/latest/Admin/Datamodelsconf

You can easily customize the acceleration period by creating a local copy of the datamodels.conf under the "local" directory.

Then, for each data model, ensure to set the required period, example with a 1 year period:

::

    acceleration.earliest_time = 1y

Acceleration setting of data models can also be managed directly in Splunk Web:

*Pivot / Manage data models:*

*Note: Since Splunk 6.5.x it might be a little bit more tricky to access to the data model manager, direct URL:* http://mysplunk.mydomain.com/en-US/app/nmon/data_model_manager

.. image:: img/manage_datamodels1.png
   :alt: manage_datamodels1.png
   :align: center

.. image:: img/manage_datamodels2.png
   :alt: manage_datamodels2.png
   :align: center



Indexes settings, retention and rolling buckets
"""""""""""""""""""""""""""""""""""""""""""""""

**Hot DB bucket size for large volume:**

If you are indexing 10GB or more per day, then you should set the maxDataSize, according to Splunk spec: https://docs.splunk.com/Documentation/Splunk/latest/Admin/Indexesconf

::

    maxDataSize = auto_high_volume

This settings can take place in a local/indexes.conf configuration file of the PA-nmon, or the indexes.conf if you arenot using the PA-nmon

**Retention:**

Ensure you set the retention of the nmon index according to your needs, See: http://docs.splunk.com/Documentation/Splunk/latest/Indexer/Setaretirementandarchivingpolicy

**Rolling buckets and buckets management:**

Ensure you set the better configuration possible according to your environment, such as using faster disks for hot and warm buckets.

For more information, See: https://docs.splunk.com/Documentation/Splunk/latest/Indexer/HowSplunkstoresindexes


Alerting customization
""""""""""""""""""""""

**By default, the Nmon Performance application has several alerting reports configured:**

- NMON - File System % usage exceeds 90% (5 consecutive minutes minimal duration)
- NMON - Real Memory % usage exceeds 90% (5 consecutive minutes minimal duration)
- NMON - Virtual Memory % usage exceeds 40% (5 consecutive minutes minimal duration)
- NMON - IBM PSERIES Pools CPU % usage exceeds 90% (5 consecutive minutes minimal duration)
- NMON - CPU % usage exceeds 90% (5 consecutive minutes minimal duration)
- NMON Collect - duplicated nmon instances may occur (excessive nbr of process launched)

These reports will run every five minutes.
Excepting the "NMON Collect", they all use the same variation of macros, by default these alerting reports will scan for all hosts.

For instance the CPU alert has the following definition:

::

    `alerting_cpu_usage(*,*,90,300,5m)`

Which stands for the macro definition:

::

    [alerting_cpu_usage(5)]
    args = frameID,hostname,alert_usage,min_duration,max_pause

As exposed, these alerts will scan for every host available, you may want to restrict them to a given list of hosts, such as your production servers only, and so on.

You can restrict the scope of the search using wildcard characters (*), such as restricting frameIDs or hostnames, you can even create your own macros based on the provided models if you need more complex restrictions. (such as using booleans)

Note: If you are not using IBM frames, you san safely disable the schedule of the "NMON - IBM PSERIES Pools CPU % usage exceeds 90% (5 consecutive minutes minimal duration)"

**Each customization must be achieved through Splunk Web, or stored in local version of configuration files to be upgrade resilient**


Splitting nmon indexes
""""""""""""""""""""""

**In a very large scale deployment, splitting the nmon data into multiple indexes can represents a great design depending on your needs and environments.**

Advantages of a split by index scenario:

- Manage different retention depending on your needs, like having a long term storage for production servers, and a shorter period for non production
- Manage different authorizations for your teams
- Optimize performances by splitting data into multiple indexes

An example of design is available in the userguide: :any:`split_by_index`

Because the application entirely uses eventtypes to define searches, only a very few customization are required to transparently use multiple indexes in the context of the application.
