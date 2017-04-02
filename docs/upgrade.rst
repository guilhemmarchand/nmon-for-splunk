*******
Upgrade
*******

.. _upgrade_standalone:

--------------------------------
01 - Upgrade Standalone Instance
--------------------------------

**Upgrade or Update the Nmon Splunk App in a Splunk standalone instance**

*Updating the Nmon App on a minor release or upgrade to a major new release is totally transparent and uses Splunk standard.*

**IMPORTANT:** As for any other Splunk Application, do never modify configuration files in the default directory but create your own copy in the local directory, such that updating the Application will not overwrite your custom settings

**To update or upgrade Nmon Splunk App in a standalone installation, you can:**

* Use the Splunk App manage builtin, Splunk automatically notifies you when a new version is available, the update can be done on the air through the Manager
* Download the new version on Splunk base https://splunkbase.splunk.com/app/1753/ and use the Manager to proceed to update
* Uncompress directly the content of the tar.gz archive in $SPLUNK_HOME/etc/apps and restart Splunk


.. _upgrade_distributed:

-----------------------------------
02 - Upgrade Distributed Deployment
-----------------------------------

**Upgrade or Update the Nmon Splunk App in a Splunk Distributed Deployment**

Updating the Nmon App on a minor release or upgrade to a major new release is totally transparent and uses Splunk standard.

*IMPORTANT: As for any other Splunk Application, do never modify configuration files in the default directory but create your own copy in the local directory, such that updating the Application will not overwrite your custom settings*

**Updating the Application in a Distributed Deployment context follows the same tracking than initial deployment, with three major pieces of the App:**

.. image:: img/steps_summary_distributed.png
   :alt: steps_summary_distributed.png
   :align: center

**So, proceed in the order:**

* Update PA-nmon_light and TA-nmon (optional)
* Update Nmon Core App and TA-nmon (optinal)
* Update TA-nmon and reload your deployment server to update your end clients

Please consult the Distributed Deployment manual to get details instructions of each step for upgrade: :any:`distributed_deployment_guide`

.. _update_from_version_prior_17:

--------------------------------------------------
03 - Migrating from release prior to Version 1.7.x
--------------------------------------------------

**Upgrade notes**

**The release V1.7.x is a major release of the Nmon Performance Monitor application, follow this procedure when migrating from an existing installation running a version previous to the V1.7.x.**

**SUMMARY OF MAJOR CHANGES**

* The Nmon core application does not create anymore the "nmon" index at installation time (for app certification purposes), the index must be declared manually
* The Nmon core application does not implement anymore data collection, if you want to get performance data of your search heads you must deploy the TA-nmon
* The TA-nmon working directory has been migrated from $SPLUNK_HOME/var/run to $SPLUNK_HOME/var/log for certification purposes
* The nmon_inventory lookup table is now stored in a KVstore collection, after upgrade you must re-generate the nmon inventory data to fill the KVstore (or wait for the next auto iteration)
* Different old components were removed from the core application (such a the django views), extracting using tar will not clean these files
* The span definition macro "custom_inlinespan" where renamed to "nmon_span" for easier usage, if you used to customize the minimal span value previously, you must update your local configuration (the original macro still exists in case of users would be using it, but it is not used anymore in views)

**FILES AND DIRECTORY THAT WERE REMOVED FROM THE CORE APPLICATION**

Bellow is the list of files and directory that were removed in the Version 1.7.x, at the end of your update you can clean these files with no issue.

*If you are running standalone search head, remove them from:*

::

    $SPLUNK_HOME/etc/apps/nmon

If you are running a Search Head Cluster, remove them the deployer and apply the bundle configuration to the search head

::

    $SPLUNK_HOME/etc/shcluster/apps/nmon

**FILES AND DIRECTORIES TO BE REMOVED:**

* nmon/bin
* nmon/django
* nmon/default/inputs.conf
* nmon/default/inputs.conf_forWindows
* nmon/default/indexes.conf
* nmon/lookups/nmon_inventory.csv
* nmon/samples

*All these files, directories and sub-directories can be removed safety.*

**PRE-CHECK - HAVE YOU DECLARED YOUR INDEX ?**

The nmon core application does create anymore the "nmon" index at startup time.

This is a requirement for Splunk application certification, as this task should be managed by Splunk administrators.

If you running in Indexer cluster, then your index has necessarily be declared and you are not concerned.

If you running standalone instances, ensure you have set your index explicitly, you can create the "nmon" index the local/ directory of the Nmon core application for example.

**STEP 1. UPDATE THE CORE APPLICATION**

If you are running on a standalone installation only, you should declare the "nmon" index manually before upgrading, or at least before restarting.

Refer to the standalone installation guide: :any:`standalone_deployment_guide`

If you running the PA-nmon or an indexer cluster where you have already manually declared the nmon index, you are not affected by this change.

**Apply the installation procedure following your configuration, checkout:**

* Upgrade a standalone server: :any:`upgrade_standalone`
* Upgrade a distributed deployment: any:`upgrade_distributed`

**inputs.conf**

Clean the default/inputs.conf and local/inputs.conf on the search head
If you were generating performance and configuration data at the search head level using the Nmon core application, you should delete these files as they are not useful anymore.

**STEP 2. DEPLOY THE TA-NMON ON SEARCH HEADS IF RELEVANT**

Since the release V1.7.4, you must deploy the TA-nmon on the search head level if you want to collect performance and configuration data from the search heads

This will be easily achieved by the the deploying the TA-nmon along with the Nmon core application on the SHC deployer, checkout: :any:`distributed_deployment_guide`

**STEP 3. CHECKOUT YOUR LOCAL CONFIGURATION ACCORDING TO MAJOR CHANGES**

According to the summary of major changes, you may have to:

* Review your local/macros.conf if you are using a custom minimal value for the span definition, see :any:`custom_span`
* Manually re-generate the nmon inventory data by running the "Generate NMON Inventory Lookup Table" report, for more information, see: :any:`nmon_inventory`

--------------------------------------------------
04 - Migrating from release prior to Version 1.9.x
--------------------------------------------------

"""""""""""""""""""""""""""""""""""""""""""
Migrate from version 1.7.x to version 1.9.x
"""""""""""""""""""""""""""""""""""""""""""

**Please refer to:** :ref:`update_from_version_prior_17`

"""""""""""""""""""""""""""""""""""""""""""
Migrate from version 1.8.x to version 1.9.x
"""""""""""""""""""""""""""""""""""""""""""

**The release 1.9.x is new main release for Nmon Core application as well for the TA-nmon technical addon**

There are some changes in these releases than can require specific actions:

* The PA-nmon has been deprecated, it is now unified with the TA-nmon (the TA-nmon replaces the PA-nmon on indexers)
* The TA-nmon_selfmode has been deprecated, it is as well unified with the TA-nmon
* The TA-nmon introduces the fifo implementation which provides the lower level of foot print on servers

**What is the upgrade path then ?**

**If you have previously deployed the PA-nmon in your clustered indexers, follow these simple steps:**

* if you have defined any custom index in the PA-nmon, backup this configuration and backport it to the PA-nmon_light (see above)
* remove the PA-nmon from the "master-apps" of the master node
* extract the PA-nmon_light archive in the master node "master-apps" directory
* extract the TA-nmon archive in the master node "master-apps" directory if you want to collect performance statistics from your indexers
* apply the cluster bundle
* after the indexers rolling restart, kill any existing nmon processes, or wait their end and assume a gap of 2 hours maximum in the performance data

**If you have customized the interval and/or snapshot values in "nmon.conf":**

* the new TA-nmon does not use any move the same variables in nmon.conf (see http://ta-nmon.readthedocs.io/en/latest/nmon_config.html)
* the reason why is that with the fantastic gain in TA-nmon foot print, it is not required anymore to run short life nmon cycles to limit the CPU and other resources costs
* the default and recommended life time for an nmon process is 24 hours
* if you used to modify the "interval" value to reduce the volume of data (which is already very low!), back port this configuration in the new variables
